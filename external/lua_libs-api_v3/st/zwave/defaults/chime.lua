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
local SensorBinary = (require "st.zwave.CommandClass.SensorBinary")({version=2,strict=true})
--- @type st.zwave.CommandClass.SwitchBinary
local SwitchBinary = (require "st.zwave.CommandClass.SwitchBinary")({version=2,strict=true})
--- @type st.zwave.CommandClass.Notification
local Notification = (require "st.zwave.CommandClass.Notification")({version=3,strict=true})

local function determine_chime_cmd(value)
  local event
  if value == SwitchBinary.value.OFF_DISABLE then
    event = capabilities.chime.chime.off()
  else
    event = capabilities.chime.chime.chime()
  end
  return event
end

--- Default handler for notification command class reports
---
--- This converts notification reports into chime events.
--- If the device also supports Switch or Alarm capabilities - proper events are also generated
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.Notification.Report
local function notification_handler(self, device, cmd)
  if cmd.args.notification_type == Notification.notification_type.SIREN then
    if cmd.args.event == Notification.event.siren.ACTIVE then
      device:emit_event_for_endpoint(cmd.src_channel, capabilities.chime.chime.chime())
    elseif cmd.args.event == Notification.event.siren.STATE_IDLE then
      device:emit_event_for_endpoint(cmd.src_channel, capabilities.chime.chime.off())
    end
  elseif cmd.args.notification_type == Notification.notification_type.HOME_SECURITY then
    if cmd.args.event == Notification.event.home_security.INTRUSION_LOCATION_PROVIDED then
      device:emit_event_for_endpoint(cmd.src_channel, capabilities.chime.chime.chime())
    elseif cmd.args.event == Notification.event.home_security.STATE_IDLE then
      device:emit_event_for_endpoint(cmd.src_channel, capabilities.chime.chime.off())
    end
  end
end

--- Default handler for basic, sensor binary and switch binary reports for chime-implementing devices
---
--- This converts the command value from 0 -> Chime.chime.off
--- otherwise Chime.chime.chime
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.Basic.Report | st.zwave.CommandClass.SwitchBinary.Report | st.zwave.CommandClass.SensorBinary.Report
local function basic_and_sensor_binary_and_switch_binary_report_handler(driver, device, cmd)
  local event
  if cmd.args.sensor_value ~= nil then
    event = determine_chime_cmd(cmd.args.sensor_value)
  elseif cmd.args.target_value ~= nil then
    event = determine_chime_cmd(cmd.args.target_value)
  else
    event = determine_chime_cmd(cmd.args.value)
  end
  device:emit_event_for_endpoint(cmd.src_channel, event)
end

local function chime_set_helper(driver, device, value, command)
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

--- Issue a set chime command to the specified device.
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param command table ST level capability command
function capability_handlers.chime(driver, device, command)
  chime_set_helper(driver, device, SwitchBinary.value.ON_ENABLE, command)
end

--- Issue a set chime off command to the specified device.
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param command table ST level capability command
function capability_handlers.off(driver, device, command)
  chime_set_helper(driver, device, SwitchBinary.value.OFF_DISABLE, command)
end

--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param component string
--- @param endpoint integer
local function get_refresh_commands(driver, device, component, endpoint)
  if device:supports_capability_by_id(capabilities.chime.ID, component) and device:is_cc_supported(cc.BASIC, endpoint) then
    return {Basic:Get({}, {dst_channels = {endpoint}})}
  end
end

--- @class st.zwave.defaults.chime
--- @alias chime_defaults st.zwave.defaults.chime
--- @field public zwave_handlers table
--- @field public capability_handlers table
--- @field public get_refresh_commands function
local chime_defaults = {
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
    [capabilities.chime.commands.chime] = capability_handlers.chime,
    [capabilities.chime.commands.off] = capability_handlers.off
  },
  get_refresh_commands = get_refresh_commands
}

return chime_defaults
