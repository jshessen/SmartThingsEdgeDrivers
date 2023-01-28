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
local messages = require "st.zigbee.messages"
local Driver = require "st.driver"
local device_management = require "st.zigbee.device_management"
local ZigbeeMessageDispatcher = require "st.zigbee.dispatcher"
local buf_lib = require "st.buf"
local socket = require "cosock.socket"
local utils = require "st.utils"

--- @class st.zigbee.AttributeConfiguration
---
--- @field public cluster number Cluster ID this attribute is a part of
--- @field public attribute number the attribute ID
--- @field public minimum_interval number the minimum reporting interval for this configuration
--- @field public maximum_interval number the maximum reporting interval for this configuration
--- @field public data_type st.zigbee.data_types.DataType the data type class for this attribute
--- @field public reportable_change st.zigbee.data_types.DataType (optional) the amount of change needed to trigger a report.  Only necessary for non-discrete attributes
--- @field public configurable boolean (optional default = true) Should this result in a Configure Reporting command to the device
--- @field public monitored boolean (optional default = true) Should this result in a expected report monitoring
local attribute_config = {}


---@alias ZigbeeHandler fun(type: Driver, type: Device, ...):void

--- @class ZigbeeDriver: Driver
---
--- @field public zigbee_channel message_channel the communication channel for Zigbee devices
--- @field public cluster_configurations st.zigbee.AttributeConfiguration[] A list of configurations for reporting attributes
--- @field public zigbee_handlers table A structure definining different ZigbeeHandlers mapped to what they handle (only used on creation)
local ZigbeeDriver = {}
ZigbeeDriver.__index = ZigbeeDriver

--- Handler function for the raw zigbee channel message receive
---
--- This will be the default registered handler for the Zigbee message_channel receive callback.  It will parse the
--- raw serialized message into a ZigbeeMessageRx and then use the zigbee_message_dispatcher to find a handler that
--- can deal with it.
---
--- Handlers have various levels of specificity.  Global handlers are for global ZCL commands, and are specified with a
--- cluster, then command ID.  Cluster handlers are for cluster specific commands and are again defined by cluster, then
--- command id.  Attr handlers are used for an attribute report, or read response for a specific cluster, attribute ID.
--- and finally zdo handlers are for ZDO commands and are defined by the "cluster" of the command.
---
--- @param self Driver the driver context
--- @param message_channel message_channel the Zigbee message_channel with a message ready to be read
function ZigbeeDriver:zigbee_message_handler(message_channel)
  local device_uuid, data = message_channel:receive()
  local buf = buf_lib.Reader(data)
  local zb_rx = messages.ZigbeeMessageRx.deserialize(buf, {additional_zcl_profiles = self.additional_zcl_profiles})
  local device = self:get_device_info(device_uuid)
  if zb_rx ~= nil then
    device.log.info_with({ hub_logs = true }, string.format("received Zigbee message: %s", zb_rx:pretty_print()))
    device:attribute_monitor(zb_rx)
    device.thread:queue_event(self.zigbee_message_dispatcher.dispatch, self.zigbee_message_dispatcher, self, device, zb_rx)
  end
end

--- Add a number of child handlers that override the top level driver behavior
---
--- Each handler set can contain a `handlers` field that follow exactly the same
--- pattern as the base driver format. It must also contain a
--- `zigbee_can_handle(driver, device, zb_rx)` function that returns true if the
--- corresponding handlers should be considered.
---
--- This will recursively follow the `sub_drivers` and build a structure that will
--- correctly find and execute a handler that matches.  It should be noted that a child handler
--- will always be preferred over a handler at the same level, but that if multiple child
--- handlers report that they can handle a message, it will be sent to each handler that reports
--- it can handle the message.
---
--- @param driver Driver the executing zigbee driver (or sub handler set)
function ZigbeeDriver.populate_zigbee_dispatcher_from_sub_drivers(driver)
  for _, sub_driver in ipairs(driver.sub_drivers) do
    sub_driver.zigbee_handlers = sub_driver.zigbee_handlers or {}
    sub_driver.zigbee_message_dispatcher =
      ZigbeeMessageDispatcher(sub_driver.NAME, sub_driver.can_handle, sub_driver.zigbee_handlers)
    driver.zigbee_message_dispatcher:register_child_dispatcher(sub_driver.zigbee_message_dispatcher)

    ZigbeeDriver.populate_zigbee_dispatcher_from_sub_drivers(sub_driver)
  end
end

function ZigbeeDriver:add_hub_to_zigbee_group(group_id)
  self.zigbee_channel:add_hub_to_group(group_id)
end

local zigbee_child_device = require "st.zigbee.child"
function ZigbeeDriver:build_child_device(raw_device_table)
  return zigbee_child_device.ZigbeeChildDevice(self, raw_device_table)
end

--- Build a Zigbee driver from the specified template
---
--- This can be used to, given a template, build a Zigbee driver that can be run to support devices.  The name field is
--- used for logging and other debugging purposes.  The driver should also include a set of
--- capability_handlers and zigbee_handlers to handle messages for the corresponding message types.  It is recommended
--- that you use the call syntax on the ZigbeeDriver to execute this (e.g. ZigbeeDriver("my_driver", {}) )
---
--- @param cls table the class to be instantiated (ZigbeeDriver)
--- @param name string the name of this driver
--- @param driver_template table a template providing information on the driver and it's handlers
--- @return Driver the constructed Zigbee driver
function ZigbeeDriver.init(cls, name, driver_template)
  local out_driver = driver_template or {}
  math.randomseed(os.time())

  out_driver.zigbee_channel = out_driver.zigbee_channel or socket.zigbee()
  out_driver.zigbee_handlers = out_driver.zigbee_handlers or {}

  out_driver.zigbee_message_dispatcher = ZigbeeMessageDispatcher(name, function(...) return true end, out_driver.zigbee_handlers)

  -- Add device lifecycle handler functions
  out_driver.lifecycle_handlers = out_driver.lifecycle_handlers or {}

  utils.merge(
      out_driver.lifecycle_handlers,
      {
        doConfigure = device_management.configure,
        driverSwitched = Driver.default_capability_match_driverSwitched_handler,
      }
  )

  out_driver.capability_handlers = out_driver.capability_handlers or {}
  -- use default refresh if explicit handler not set
  utils.merge(
      out_driver.capability_handlers,
      {
        refresh = {
          refresh = device_management.refresh
        }
      }
  )

  out_driver = Driver.init(cls, name, out_driver)
  out_driver:_register_channel_handler(out_driver.zigbee_channel, out_driver.zigbee_message_handler, "zigbee")
  ZigbeeDriver.populate_zigbee_dispatcher_from_sub_drivers(out_driver)
  log.trace_with({ hub_logs = true }, string.format("Setup driver %s with Zigbee handlers:\n%s", out_driver.NAME, out_driver.zigbee_message_dispatcher))
  ------------------------------------------------------------------------------------
  -- Set up local state
  ------------------------------------------------------------------------------------
  out_driver.health_check = out_driver.health_check == nil and true or out_driver.health_check
  if (out_driver.health_check) then
    device_management.init_device_health(out_driver)
  end

  return out_driver
end

setmetatable(ZigbeeDriver, {
  __index = Driver,
  __call = ZigbeeDriver.init
})

return ZigbeeDriver
