-- Copyright 2021 SmartThings
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
local log = require "log"
--- @type Driver
local Driver = require "st.driver"
local socket = require "cosock.socket"
--- @type st.zwave.Dispatcher
local ZwaveDispatcher = require "st.zwave.dispatcher"
--- @type st.zwave
local zw = require "st.zwave"
local utils = require "st.utils"
local cc = require "st.zwave.CommandClass"
--- @type st.zwave.CommandClass.WakeUp
local WakeUp = require "st.zwave.CommandClass.WakeUp"
local constants = require "st.zwave.constants"

--- @class st.zwave.Driver:Driver
--- @alias ZwaveDriver st.zwave.Driver
---
--- @field public zwave_channel message_channel the communication channel for Z-Wave devices
--- @field public zwave_dispatcher st.zwave.Dispatcher
local ZwaveDriver = {}
ZwaveDriver.__index = ZwaveDriver

--- Handler function for the raw zwave channel message receive
---
--- This will be the default registered handler for the Zigbee message_channel
--- receive callback.  It will parse the raw serialized message into an
--- st.zw.Command and then use the zwave_dispatcher to find a handler that can deal
--- with it.
---
--- @param driver st.zwave.Driver
--- @param message_channel table Z-Wave message channel object
local function zw_cmd_handler(driver, message_channel)
  assert(type(message_channel) == "table", "message channel must be a table")
  local uuid, encap, src_channel, dst_channels, cmd_class, cmd_id, payload = message_channel:receive()
  local device = driver:get_device_info(uuid)
  local cmd = zw.Command(cmd_class, cmd_id, payload,
    { encap=encap, src_channel=src_channel, dst_channels=dst_channels })
  device.log.info_with({ hub_logs = true }, string.format("received Z-Wave command: %s", cmd))
  device.thread:queue_event(driver.zwave_dispatcher.dispatch, driver.zwave_dispatcher, driver, device, cmd)
end

--- Wrap wake up notification handler to call a devices `update_preferences` function if there is one set on the device.
--- This function will be given a table of the previous preference values
---
--- This is used by sleepy device drivers when preferences are updated when the device is
--- asleep.
---
--- @param driver st.zwave.Driver
local function extend_wakeup_handler(driver)
  local existing_wakeup_notification_handler
  if driver.zwave_handlers[cc.WAKE_UP] ~= nil then
    existing_wakeup_notification_handler = driver.zwave_handlers[cc.WAKE_UP][WakeUp.NOTIFICATION]
  end

  if existing_wakeup_notification_handler ~= nil then
    local wakeup_preference_handler = function(inner_driver, device, cmd)
      local update_prefs_fn = device:get_field(constants.UPDATE_PREFERENCES_FUNC)
      if update_prefs_fn ~= nil then
        update_prefs_fn(inner_driver, device)
      end
    end
    if type(existing_wakeup_notification_handler) == "table" then
      table.insert(driver.zwave_handlers[cc.WAKE_UP][WakeUp.NOTIFICATION], 1, wakeup_preference_handler)
    elseif type(existing_wakeup_notification_handler) == "function" then
      driver.zwave_handlers[cc.WAKE_UP][WakeUp.NOTIFICATION] = {wakeup_preference_handler, existing_wakeup_notification_handler}
    end
  end
end

--- Add a number of child handlers that override the top level driver behavior
---
--- Each handler set can contain a `handlers` field that follows exactly the same
--- pattern as the base driver format. It must also contain a
--- `zwave_can_handle(driver, device, cmd_class, cmd_id)` function that returns
--- true if the corresponding handlers should be considered.
---
--- This will recursively follow the `sub_drivers` and build a structure
--- that will correctly find and execute a handler that matches.  It should be
--- noted that a child handler will always be preferred over a handler at the
--- same level, but that if multiple child handlers report that they can handle
--- a message, it will be sent to each handler that reports it can handle the
--- message.
---
--- @param driver st.zwave.Driver
local function populate_zwave_dispatcher_from_sub_drivers(driver)
  for _, sub_driver in ipairs(driver.sub_drivers) do
    sub_driver.zwave_handlers = sub_driver.zwave_handlers or {}
    extend_wakeup_handler(sub_driver)
    sub_driver.zwave_dispatcher =
      ZwaveDispatcher(sub_driver.NAME, sub_driver.can_handle, sub_driver.zwave_handlers)
    driver.zwave_dispatcher:register_child_dispatcher(sub_driver.zwave_dispatcher)
    populate_zwave_dispatcher_from_sub_drivers(sub_driver)
  end
end

local zwave_child_device = require "st.zwave.child"
function ZwaveDriver:build_child_device(raw_device_table)
  return zwave_child_device.ZwaveChildDevice(self, raw_device_table)
end


--- Validate command callbacks.  At runtime, the driver requires a callback
--- registration structure as:
---
--- driver = {
---   zwave_handlers = {
---     [cmd_class] = {
---       [cmd_id] = callback
---     }
---   }
--- }
---
--- @param driver st.zwave.Driver
local function validate_cmd_callbacks(driver)
  driver.zwave_handlers = driver.zwave_handlers or {}
  assert(type(driver.zwave_handlers) == "table", "driver.zwave_handlers must be of type table")
  for cmd_class, v in pairs(driver.zwave_handlers) do
    assert(type(cmd_class) == "number" and type(v) == "table",
           "zwave handler registrations must be of form [cmd_class] = { [cmd_id] = callback } or " ..
           "{ [cmd_class] = { [cmd_id] = { callback, callback, ... } }")
    -- The handlers table must contain numerically-indexed entries keyed on
    -- command class and enclosing numerically-indexed sub-tables keyed on
    -- command code literals.
    for cmd_id, callback in pairs(driver.zwave_handlers[cmd_class]) do
      assert(     type(cmd_id) == "number"
              and (    type(callback) == "function"
                    or (     type(callback) == "table"
                         and (    type(callback[1] == "function")
                               or type(callback[1] == nil)))),
           "zwave handler registrations must be of form [cmd_class] = { [cmd_id] = callback } or " ..
           "{ [cmd_class] = { [cmd_id] = { callback, callback, ... } }")
    end
  end
end

--- Wrap our default device configure method with the standard interface we
--- expect in the driver table.
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param event table configure lifecycle event
local function device_configure(driver, device, event)
  device:default_configure()
end

--- Wrap our default device refresh method with the standard interface we
--- expect in the driver table.
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param command table ST refresh capability command
local function device_refresh(driver, device, command)
  device:default_refresh()
end

--- @class st.zwave.Driver.Template
--- @alias Template st.zwave.Driver.Template
---
--- @field public supported_capabilities table flat list of SmartThings capabilities supported by the driver
--- @field public zwave_handlers table Z-Wave command handlers, indexed by [cmd_class][cmd_id]
--- @field public capability_handlers table capability handlers, indexed by capability ID
--- @field public lifecycle_handlers table device-configure and device-added lifecycle event callbacks
--- @field public sub_drivers table device-specific sub-drivers
local template = {}

---   * set Z-Wave command version overrides
---   * set Z-Wave receive channel override
---   * execute base Driver init
---   * parse zwave_handlers callback table
---   * set Z-Wave default handler override
---   * register RX on the Z-Wave socket
---   * register lifecycle callbacks
---
--- @param cls st.zwave.Driver Z-Wave driver definition table
--- @param name string driver name
--- @param driver_template st.zwave.Driver.Template driver-specific template
--- @return st.zwave.Driver driver instance on which :run() method may be called
function ZwaveDriver.init(cls, name, driver_template)
  local out_driver = driver_template or {}

  -- Init the cache.
  out_driver.cache = {}

  -- Set versions override.
  zw._deserialization_versions = driver_template.deserialization_versions or {}

  -- Set library versions fallback.
  setmetatable(zw._deserialization_versions, { __index = zw._versions })

  -- Set the Z-Wave socket in the driver, allowing for override.
  out_driver.zwave_channel = out_driver.zwave_channel or socket.zwave()


  -- Add device management functions
  out_driver.lifecycle_handlers = out_driver.lifecycle_handlers or {}
  utils.merge(
      out_driver.lifecycle_handlers,
      {
        doConfigure = device_configure,
        driverSwitched = Driver.default_capability_match_driverSwitched_handler,
      }
  )

  out_driver.capability_handlers = out_driver.capability_handlers or {}
  -- use default refresh if explicit handler not set
  utils.merge(
      out_driver.capability_handlers,
      {
        refresh = {
          refresh = device_refresh
        }
      }
  )

  extend_wakeup_handler(out_driver)

  -- Call base Driver init.
  out_driver = Driver.init(cls, name, out_driver)

  --  Create our dispatcher.
  out_driver.zwave_handlers = out_driver.zwave_handlers or {}
  out_driver.zwave_dispatcher = ZwaveDispatcher(out_driver.NAME,
    function(...) return true end, out_driver.zwave_handlers)

  -- Validate command subscriptions.
  validate_cmd_callbacks(out_driver)

  -- Register zwave RX handler.
  Driver._register_channel_handler(out_driver, out_driver.zwave_channel, zw_cmd_handler)

  --  Add child handler overrides.
  populate_zwave_dispatcher_from_sub_drivers(out_driver)

  log.trace_with({ hub_logs = true }, string.format("Setup driver %s with Z-Wave handlers:\n%s", out_driver.NAME, out_driver.zwave_dispatcher))
  return out_driver
end

setmetatable(ZwaveDriver, {
  __index = Driver,
  __call = ZwaveDriver.init
})

return ZwaveDriver
