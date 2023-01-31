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

local function motion_report_factory(argument_field)
  return function(self, device, cmd)
    if (cmd.args[argument_field] ~= 0) then
      device:emit_event_for_endpoint(cmd.src_channel, capabilities.motionSensor.motion.active())
    else
      device:emit_event_for_endpoint(cmd.src_channel, capabilities.motionSensor.motion.inactive())
    end
  end
end

--- Default handler for binary sensor command class reports
---
--- This converts binary sensor reports to correct motion active/inactive events
---
--- For a device that uses v1 of the binary sensor command class, all reports will be considered
--- motion reports.
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.SensorBinary.Report
local function sensor_binary_report_handler(self, device, cmd)
  -- sensor_type will be nil if this is a v1 report
  if ((cmd.args.sensor_type ~= nil and cmd.args.sensor_type == SensorBinary.sensor_type.MOTION) or
        cmd.args.sensor_type == nil) then
    if (cmd.args.sensor_value == SensorBinary.sensor_value.DETECTED_AN_EVENT) then
      device:emit_event_for_endpoint(cmd.src_channel, capabilities.motionSensor.motion.active())
    elseif (cmd.args.sensor_value == SensorBinary.sensor_value.IDLE) then
      device:emit_event_for_endpoint(cmd.src_channel, capabilities.motionSensor.motion.inactive())
    end
  end
end

--- Default handler for sensor alarm command class reports
---
--- This converts sensor alarm reports to correct motion active/inactive events
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.SensorAlarm.Report
local function sensor_alarm_report_handler(self, device, cmd)
  if (cmd.args.sensor_type == SensorAlarm.sensor_type.GENERAL_PURPOSE_ALARM) then
    if (cmd.args.sensor_state == SensorAlarm.sensor_state.ALARM) then
      device:emit_event_for_endpoint(cmd.src_channel, capabilities.motionSensor.motion.active())
    elseif (cmd.args.sensor_state == SensorAlarm.sensor_state.NO_ALARM) then
      device:emit_event_for_endpoint(cmd.src_channel, capabilities.motionSensor.motion.inactive())
    end
  end
end

--- Default handler for notification command class reports
---
--- This converts motion home security reports into contact open/closed events
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.Notification.Report
local function notification_handler(self, device, cmd)
  local motion_notification_events_map = {
    [Notification.event.home_security.INTRUSION_LOCATION_PROVIDED] = capabilities.motionSensor.motion.active(),
    [Notification.event.home_security.INTRUSION] = capabilities.motionSensor.motion.active(),
    [Notification.event.home_security.MOTION_DETECTION_LOCATION_PROVIDED] = capabilities.motionSensor.motion.active(),
    [Notification.event.home_security.MOTION_DETECTION] = capabilities.motionSensor.motion.active(),
    [Notification.event.home_security.STATE_IDLE] = capabilities.motionSensor.motion.inactive(),
  }

  if (cmd.args.notification_type == Notification.notification_type.HOME_SECURITY) then
    local event
    event = motion_notification_events_map[cmd.args.event]
    if (event ~= nil) then
      device:emit_event_for_endpoint(cmd.src_channel, event)
    end
  end
end

--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param component string
--- @param endpoint integer
local function get_refresh_commands(driver, device, component, endpoint)
  if device:supports_capability_by_id(capabilities.motionSensor.ID, component) and device:is_cc_supported(cc.SENSOR_BINARY, endpoint) then
    return {SensorBinary:Get({sensor_type = SensorBinary.sensor_type.MOTION}, {dst_channels = {endpoint}})}
  end
end

--- @class st.zwave.defaults.motionSensor
--- @alias motion_sensor_defaults st.zwave.defaults.motionSensor
--- @field public zwave_handlers table
--- @field public get_refresh_commands function
local motion_sensor_defaults = {
  zwave_handlers = {
    [cc.BASIC] = {
      [Basic.REPORT] = motion_report_factory("value")
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

return motion_sensor_defaults
