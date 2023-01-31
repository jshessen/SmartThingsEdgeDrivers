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
--- @type st.zwave.CommandClass
local cc = require "st.zwave.CommandClass"
--- @type st.zwave.CommandClass.Notification
local Notification = (require "st.zwave.CommandClass.Notification")({version=3})
--- @type st.zwave.CommandClass.SensorBinary
local SensorBinary = (require "st.zwave.CommandClass.SensorBinary")({version=2})

--- Default handler for notification command class reports
---
--- This converts temperature reports across multiple notification types into temperature alarm events.
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.Notification.Report
local function notification_handler(self, device, cmd)
  local heat_notification_events_map = {
    [Notification.event.heat.OVERDETECTED_LOCATION_PROVIDED] = capabilities.temperatureAlarm.temperatureAlarm.heat(),
    [Notification.event.heat.OVERDETECTED] = capabilities.temperatureAlarm.temperatureAlarm.heat(),
    [Notification.event.heat.UNDER_DETECTED_LOCATION_PROVIDED] = capabilities.temperatureAlarm.temperatureAlarm.freeze(),
    [Notification.event.heat.UNDER_DETECTED] = capabilities.temperatureAlarm.temperatureAlarm.freeze(),
    [Notification.event.heat.RAPID_TEMPERATURE_RISE_LOCATION_PROVIDED] = capabilities.temperatureAlarm.temperatureAlarm.heat(),
    [Notification.event.heat.ALARM_TEST] = capabilities.temperatureAlarm.temperatureAlarm.heat(),
    [Notification.event.heat.STATE_IDLE] = capabilities.temperatureAlarm.temperatureAlarm.cleared(),
    [Notification.event.heat.ALARM_SILENCED] = capabilities.temperatureAlarm.temperatureAlarm.cleared(),
    [Notification.event.heat.UNKNOWN_EVENT_STATE] = capabilities.temperatureAlarm.temperatureAlarm.cleared()
  }

  local event

  if (cmd.args.notification_type == Notification.notification_type.HEAT) then
    event = heat_notification_events_map[cmd.args.event]
  end

  if (event ~= nil) then device:emit_event(event) end
end

--- Default handler for binary sensor command class reports
---
--- This converts binary sensor reports to correct temperatureAlarm freeze/cleared events
---
--- For a device that uses v1 of the binary sensor command class, all reports will be considered
--- temperatureAlarm reports.
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.SensorBinary.Report
local function sensor_binary_report_handler(self, device, cmd)
  -- sensor_type will be nil if this is a v1 report
  if ((cmd.args.sensor_type ~= nil and cmd.args.sensor_type == SensorBinary.sensor_type.FREEZE) or
        cmd.args.sensor_type == nil) then
    if (cmd.args.sensor_value == SensorBinary.sensor_value.DETECTED_AN_EVENT) then
      device:emit_event(capabilities.temperatureAlarm.temperatureAlarm.freeze())
    elseif (cmd.args.sensor_value == SensorBinary.sensor_value.IDLE) then
      device:emit_event(capabilities.temperatureAlarm.temperatureAlarm.cleared())
    end
  end
end

--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param component string
--- @param endpoint integer
local function get_refresh_commands(driver, device, component, endpoint)
  if device:supports_capability_by_id(capabilities.temperatureAlarm.ID, component) and device:is_cc_supported(cc.SENSOR_BINARY, endpoint) then
    return {SensorBinary:Get({sensor_type = SensorBinary.sensor_type.FREEZE}, {dst_channels = {endpoint}})}
  end
end

--- @class st.zwave.defaults.temperatureAlarm
--- @alias temperature_alarm_defaults st.zwave.defaults.temperatureAlarm
--- @field public zwave_handlers table
--- @field public get_refresh_commands function
local temperature_alarm_defaults = {
  zwave_handlers = {
    [cc.NOTIFICATION] = {
      [Notification.REPORT] = notification_handler
    },
    [cc.SENSOR_BINARY] = {
      [SensorBinary.REPORT] = sensor_binary_report_handler
    }
  },
  get_refresh_commands = get_refresh_commands
}

return temperature_alarm_defaults
