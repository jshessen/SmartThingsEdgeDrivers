-- Copyright 2022 SmartThings
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
local utils = require "st.utils"
local im = require "st.matter.interaction_model"
--- @type Driver
local Driver = require "st.driver"
--- @type MatterMessageDispatcher
local MatterDispatcher = require "st.matter.dispatcher"
local socket = require "cosock.socket"

--- @class MatterDriver: Driver
---
--- @field public matter_channel message_channel the communication channel for Matter devices
--- @field public matter_dispatcher table Dispatcher for matter InteractionResponses received from the device.
--- @field public matter_handlers table A structure definining different matter handlers mapped to InteractionResponses that they handle (only used on creation)
--- @field public subscribed_attributes table A list of attributes mapped to capabilities for a device subscription
--- @field public subscribed_events table A list of events mapped to capabilities for a device subscription
local MatterDriver = {}
MatterDriver.__index = MatterDriver

--- Handler function for the raw matter channel message receive
---
--- The default registered handler for the Matter message_channel receive callback.
--- It dispatches messages using the driver's MatterDispatcher which sends it to the drivers
--- proper MatterHandler based on the response's Path.
---
--- @param driver Driver the driver context
--- @param message_channel message_channel the Matter message_channel with a message ready to be read
local function matter_rx_handler(driver, message_channel)
  assert(type(message_channel) == "table", "message channel must be a table")
  local raw = message_channel:receive()
  local device = driver:get_device_info(raw.device_uuid)
  local response = im.InteractionResponse.deserialize(raw)
  log.info_with(
    {hub_logs = true}, string.format("received matter InteractionResponse: %s", response)
  )
  for _, ib in ipairs(response.info_blocks or {}) do -- dispatch each info block, but include full context of the device message
    device.thread:queue_event(
      driver.matter_dispatcher.dispatch, driver.matter_dispatcher, driver, device, ib, response
    )
  end
end


local matter_child_device = require "st.matter.child"
function MatterDriver:build_child_device(raw_device_table)
  return matter_child_device.MatterChildDevice(self, raw_device_table)
end

--- Add a number of child handlers that override the top level driver behavior
---
--- Each handler set can contain a `handlers` field that follow exactly the same
--- pattern as the base driver format. It must also contain a
--- `can_handle(driver, device, zb_rx)` function that returns true if the
--- corresponding handlers should be considered.
---
--- This will recursively follow the `sub_drivers` and build a structure that will
--- correctly find and execute a handler that matches.  It should be noted that a child handler
--- will always be preferred over a handler at the same level, but that if multiple child
--- handlers report that they can handle a message, it will be sent to each handler that reports
--- it can handle the message.
---
--- @param driver Driver the executing matter driver (or sub handler set)
function MatterDriver.populate_matter_dispatcher_from_sub_drivers(driver)
  for _, sub_driver in ipairs(driver.sub_drivers) do
    sub_driver.matter_handlers = sub_driver.matter_handlers or {}
    sub_driver.matter_dispatcher = MatterDispatcher(
                                     sub_driver.NAME, sub_driver.can_handle,
                                       sub_driver.matter_handlers
                                   )
    driver.matter_dispatcher:register_child_dispatcher(sub_driver.matter_dispatcher)

    MatterDriver.populate_matter_dispatcher_from_sub_drivers(sub_driver)
  end
end

--- Wrap our default device refresh method with the standard interface we
--- expect in the driver table.
---
--- @param driver st.matter.Driver
--- @param device st.matter.Device
local function device_refresh(driver, device)
  device:refresh()
end

--- Build a Matter driver from the specified template
---
--- This can be used to, given a template, build a Matter driver that can be run to support devices.  The name field is
--- used for logging and other debugging purposes.  The driver template should also include a set of
--- capability_handlers and matter_handlers to handle messages for the corresponding message types.  It is recommended
--- that you use the call syntax on the MatterDriver to execute this (e.g. MatterDriver("my_driver", {}) )
---
--- @param cls table the class to be instantiated (MatterDriver)
--- @param name string the name of this driver
--- @param driver_template table a template providing information on the driver and it's handlers
--- @return Driver the constructed MatterDriver instance
function MatterDriver.init(cls, name, driver_template)
  local out_driver = driver_template or {}

  -- Set matter device interaction channel allowing for override
  out_driver.matter_channel = out_driver.matter_channel or socket.matter()
  out_driver.matter_handlers = out_driver.matter_handlers or {}

  out_driver.matter_dispatcher = MatterDispatcher(
                                   name, function(...) return true end, out_driver.matter_handlers
                                 )

  -- Add device lifecycle handler functions
  out_driver.lifecycle_handlers = out_driver.lifecycle_handlers or {}
  utils.merge(
    out_driver.lifecycle_handlers, {
      -- doConfigure = subscription_config.configure, --TODO define default subscription behavior on configure event (CHAD-7942)
      driverSwitched = Driver.default_capability_match_driverSwitched_handler,
    }
  )

  out_driver.capability_handlers = out_driver.capability_handlers or {}
  utils.merge(
    out_driver.capability_handlers,
    {
      refresh = {
        refresh = device_refresh
      }
    }
  )

  out_driver = Driver.init(cls, name, out_driver)
  out_driver:_register_channel_handler(out_driver.matter_channel, matter_rx_handler, "matter")
  MatterDriver.populate_matter_dispatcher_from_sub_drivers(out_driver)
  log.trace_with(
    {hub_logs = true}, string.format(
      "Setup driver %s with Matter handlers:\n%s", out_driver.NAME, out_driver.matter_dispatcher
    )
  )
  return out_driver
end

setmetatable(MatterDriver, {__index = Driver, __call = MatterDriver.init})

return MatterDriver
