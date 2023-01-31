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
local capabilities = require "st.capabilities"
local constants = require "st.zwave.constants"
--- @type st.zwave.CommandClass
local cc  = require "st.zwave.CommandClass"
--- @type st.zwave.CommandClass.Basic
local Basic = (require "st.zwave.CommandClass.Basic")({version=1,strict=true})
--- @type st.zwave.CommandClass.SensorBinary
local SensorBinary = (require "st.zwave.CommandClass.SensorBinary")({version=2})
--- @type st.zwave.CommandClass.SwitchBinary
local SwitchBinary = (require "st.zwave.CommandClass.SwitchBinary")({version=2,strict=true})
--- @type st.zwave.CommandClass.Notification
local Notification = (require "st.zwave.CommandClass.Notification")({version=3,strict=true})

local BASIC_AND_SWITCH_BINARY_REPORT_STROBE_LIMIT = 33
local BASIC_AND_SWITCH_BINARY_REPORT_SIREN_LIMIT = 66
local BASIC_REPORT_SIREN_ACTIVE = 0xFF
local BASIC_REPORT_SIREN_IDLE = 0x00

local zwave_handlers = {}

local function determine_siren_cmd(value)
  local event
  if value == SwitchBinary.value.OFF_DISABLE then
    event = capabilities.alarm.alarm.off()
  elseif value <= BASIC_AND_SWITCH_BINARY_REPORT_STROBE_LIMIT then
    event = capabilities.alarm.alarm.strobe()
  elseif value <= BASIC_AND_SWITCH_BINARY_REPORT_SIREN_LIMIT then
    event = capabilities.alarm.alarm.siren()
  else
    event = capabilities.alarm.alarm.both()
  end
  return event
end

--- Default handler for notification command class reports
---
--- This converts notification reports across siren types into alarm events.
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.Notification.Report
local function notification_handler(self, device, cmd)
  if cmd.args.notification_type == Notification.notification_type.SIREN then
    if cmd.args.event == Notification.event.siren.ACTIVE then
      device:emit_event_for_endpoint(cmd.src_channel, capabilities.alarm.alarm.both())
      if device:supports_capability_by_id(capabilities.switch.ID) then
        device:emit_event_for_endpoint(cmd.src_channel, capabilities.switch.switch.on())
      end
    elseif cmd.args.event == Notification.event.siren.STATE_IDLE then
      device:emit_event_for_endpoint(cmd.src_channel, capabilities.alarm.alarm.off())
      if device:supports_capability_by_id(capabilities.switch.ID) then
        device:emit_event_for_endpoint(cmd.src_channel, capabilities.switch.switch.off())
      end
    end
  elseif cmd.args.notification_type == Notification.notification_type.HOME_SECURITY then
    if cmd.args.event == Notification.event.home_security.TAMPERING_PRODUCT_COVER_REMOVED then
      device:emit_event_for_endpoint(cmd.src_channel, capabilities.alarm.alarm.both())
    end
  end
end

--- Default handler for basic, switch binary reports for siren-implementing devices
---
--- This converts the command value from 0 -> Alarm.alarm.off
--- less than 33 -> Alarm.alarm.strobe, less than 66 -> Alarm.alarm.siren,
--- otherwise Alarm.alarm.off
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.Basic.Report | st.zwave.CommandClass.SwitchBinary.Report
local function basic_and_sensor_binary_and_switch_binary_report_handler(driver, device, cmd)
  local event
  if cmd.args.sensor_value ~= nil then
    event = determine_siren_cmd(cmd.args.sensor_value)
  else
    event = determine_siren_cmd(cmd.args.value)
  end
  if (event ~= nil) then
    device:emit_event_for_endpoint(cmd.src_channel, event)
  end
end

local function siren_set_helper(driver, device, value, command)
  local delay = constants.DEFAULT_GET_STATUS_DELAY
  local set = Basic:Set({
    value=value
  })
  local get = Basic:Get({})
  device:send_to_component(set, command.component)
  local query_device = function()
    device:send_to_component(get, command.component)
  end
  device.thread:call_with_delay(delay, query_device)
end

local capability_handlers = {}

--- Issue a set siren command to the specified device.
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param command table ST level capability command
function capability_handlers.siren(driver, device, command)
  siren_set_helper(driver, device, SwitchBinary.value.ON_ENABLE, command)
end

--- Issue a set strobe command to the specified device.
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param command table ST level capability command
function capability_handlers.strobe(driver, device, command)
  siren_set_helper(driver, device, SwitchBinary.value.ON_ENABLE, command)
end

--- Issue a set both siren and strobe command to the specified device.
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param command table ST level capability command
function capability_handlers.both(driver, device, command)
  siren_set_helper(driver, device, SwitchBinary.value.ON_ENABLE, command)
end

--- Issue a set siren off command to the specified device.
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param command table ST level capability command
function capability_handlers.off(driver, device, command)
  siren_set_helper(driver, device, SwitchBinary.value.OFF_DISABLE, command)
end

--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param component string
--- @param endpoint integer
local function get_refresh_commands(driver, device, component, endpoint)
  if device:supports_capability_by_id(capabilities.alarm.ID, component) and device:is_cc_supported(cc.BASIC, endpoint) then
    return {Basic:Get({}, {dst_channels = {endpoint}})}
  end
end

--- @class st.zwave.defaults.alarm
--- @alias alarm_defaults st.zwave.defaults.alarm
--- @field public zwave_handlers table
--- @field public capability_handlers table
--- @field public get_refresh_commands function
local alarm_defaults = {
  zwave_handlers = {
    [cc.BASIC] = {
      [Basic.REPORT] = basic_and_sensor_binary_and_switch_binary_report_handler
    },
    [cc.SENSOR_BINARY] = {
      [SensorBinary.REPORT] = basic_and_sensor_binary_and_switch_binary_report_handler
    },
    [cc.SWITCH_BINARY] = {
      [SwitchBinary.REPORT] = basic_and_sensor_binary_and_switch_binary_report_handler
    },
    [cc.NOTIFICATION] = {
      [Notification.REPORT] = notification_handler
    }
  },
  capability_handlers = {
    [capabilities.alarm.commands.both] = capability_handlers.both,
    [capabilities.alarm.commands.off] = capability_handlers.off,
    [capabilities.alarm.commands.siren] = capability_handlers.siren,
    [capabilities.alarm.commands.strobe] = capability_handlers.strobe
  },
  get_refresh_commands = get_refresh_commands,
}

return alarm_defaults
