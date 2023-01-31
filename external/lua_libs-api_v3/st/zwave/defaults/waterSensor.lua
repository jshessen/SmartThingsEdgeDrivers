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
--- @type st.zwave.CommandClass.Basic
local Basic = (require "st.zwave.CommandClass.Basic")({version=1})
--- @type st.zwave.CommandClass.Notification
local Notification = (require "st.zwave.CommandClass.Notification")({version=3})
--- @type st.zwave.CommandClass.SensorAlarm
local SensorAlarm = (require "st.zwave.CommandClass.SensorAlarm")({version=1})
--- @type st.zwave.CommandClass.SensorBinary
local SensorBinary = (require "st.zwave.CommandClass.SensorBinary")({version=2})

local function water_report_factory(argument_field)
  return function(self, device, cmd)
    if (cmd.args[argument_field] ~= 0) then
      device:emit_event_for_endpoint(cmd.src_channel, capabilities.waterSensor.water.wet())
    else
      device:emit_event_for_endpoint(cmd.src_channel, capabilities.waterSensor.water.dry())
    end
  end
end

--- Default handler for binary sensor command class reports
---
--- This converts binary sensor reports to correct water wet/dry events
---
--- For a device that uses v1 of the binary sensor command class, all reports will be considered
--- water reports.
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.SensorBinary.Report
local function sensor_binary_report_handler(self, device, cmd)
  -- sensor_type will be nil if this is a v1 report
  if ((cmd.args.sensor_type ~= nil and cmd.args.sensor_type == SensorBinary.sensor_type.WATER) or
        cmd.args.sensor_type == nil) then
    if (cmd.args.sensor_value == SensorBinary.sensor_value.DETECTED_AN_EVENT) then
      device:emit_event_for_endpoint(cmd.src_channel, capabilities.waterSensor.water.wet())
    elseif (cmd.args.sensor_value == SensorBinary.sensor_value.IDLE) then
      device:emit_event_for_endpoint(cmd.src_channel, capabilities.waterSensor.water.dry())
    end
  end
end

--- Default handler for sensor alarm command class reports
---
--- This converts sensor alarm reports to correct water wet/dry events
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.SensorAlarm.Report
local function sensor_alarm_report_handler(self, device, cmd)
  if (cmd.args.sensor_type == SensorAlarm.sensor_type.WATER_LEAK_ALARM) then
    if (cmd.args.sensor_state == SensorAlarm.sensor_state.ALARM) then
      device:emit_event_for_endpoint(cmd.src_channel, capabilities.waterSensor.water.wet())
    elseif (cmd.args.sensor_state == SensorAlarm.sensor_state.NO_ALARM) then
      device:emit_event_for_endpoint(cmd.src_channel, capabilities.waterSensor.water.dry())
    end
  end
end

--- Default handler for notification command class reports
---
--- This converts leak reports into contact open/closed events.
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.Notification.Report
local function notification_handler(self, device, cmd)
  local water_notification_events_map = {
    [Notification.event.water.LEAK_DETECTED_LOCATION_PROVIDED] = capabilities.waterSensor.water.wet(),
    [Notification.event.water.LEAK_DETECTED] = capabilities.waterSensor.water.wet(),
    [Notification.event.water.STATE_IDLE] = capabilities.waterSensor.water.dry(),
    [Notification.event.water.UNKNOWN_EVENT_STATE] = capabilities.waterSensor.water.dry(),
  }

  if (cmd.args.notification_type == Notification.notification_type.WATER) then
    local event
    event = water_notification_events_map[cmd.args.event]
    if (event ~= nil) then device:emit_event_for_endpoint(cmd.src_channel, event) end
  end
end

--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param component string
--- @param endpoint integer
local function get_refresh_commands(driver, device, component, endpoint)
  if device:supports_capability_by_id(capabilities.waterSensor.ID, component) and device:is_cc_supported(cc.SENSOR_BINARY, endpoint) then
    return {SensorBinary:Get({sensor_type = SensorBinary.sensor_type.WATER}, {dst_channels = {endpoint}})}
  end
end

--- @class st.zwave.defaults.waterSensor
--- @alias water_sensor_defaults st.zwave.defaults.waterSensor
--- @field public zwave_handlers table
--- @field public get_refresh_commands function
local water_sensor_defaults = {
  zwave_handlers = {
    [cc.BASIC] = {
      [Basic.REPORT] = water_report_factory("value")
    },
    [cc.SENSOR_BINARY] = {
      [SensorBinary.REPORT] = sensor_binary_report_handler
    },
    [cc.SENSOR_ALARM] = {
      [SensorAlarm.REPORT] = sensor_alarm_report_handler
    },
    [cc.NOTIFICATION] = {
      [Notification.REPORT] = notification_handler
    }
  },
  get_refresh_commands = get_refresh_commands
}

return water_sensor_defaults
