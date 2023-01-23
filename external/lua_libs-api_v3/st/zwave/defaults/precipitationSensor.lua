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
local capabilities = require "st.capabilities"
--- @type st.zwave.CommandClass
local cc = require "st.zwave.CommandClass"
--- @type st.zwave.CommandClass.Notification
local Notification = (require "st.zwave.CommandClass.Notification")({version=7})

--- Default handler for notification command class reports
---
--- This converts weather reports into precipitation events.
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.Notification.Report
local function notification_handler(self, device, cmd)
  local weather_notification_events_map = {
    [Notification.event.weather_alarm.RAIN_ALARM] = capabilities.precipitationSensor.precipitationIntensity.possiblePrecipitation(),
    [Notification.event.weather_alarm.STATE_IDLE] = capabilities.precipitationSensor.precipitationIntensity.none()
  }

  if (cmd.args.notification_type == Notification.notification_type.WEATHER_ALARM) then
    local event
    event = weather_notification_events_map[cmd.args.event]
    if (event ~= nil) then device:emit_event_for_endpoint(cmd.src_channel, event) end
  end
end

--- @class st.zwave.defaults.precipitationSensor
--- @alias precipitation_sensor_defaults st.zwave.defaults.precipitationSensor
--- @field public zwave_handlers table
local precipitation_sensor_defaults = {
  zwave_handlers = {
    [cc.NOTIFICATION] = {
      [Notification.REPORT] = notification_handler
    }
  }
}

return precipitation_sensor_defaults
