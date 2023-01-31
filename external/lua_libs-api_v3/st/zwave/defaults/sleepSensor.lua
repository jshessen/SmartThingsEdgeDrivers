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
local Notification = (require "st.zwave.CommandClass.Notification")({version=8})

--- Default handler for notification command class reports
---
--- This home health reports into sleep events.
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.Notification.Report
local function notification_handler(self, device, cmd)
  local home_health_notification_events_map = {
    [Notification.event.home_health.SLEEP_STAGE_0_DETECTED_DREAMING_REM] = capabilities.sleepSensor.sleeping.sleeping(),
    [Notification.event.home_health.SLEEP_STAGE_1_DETECTED_LIGHT_SLEEP_NON_REM_1] = capabilities.sleepSensor.sleeping.sleeping(),
    [Notification.event.home_health.SLEEP_STAGE_2_DETECTED_MEDIUM_SLEEP_NON_REM_2] = capabilities.sleepSensor.sleeping.sleeping(),
    [Notification.event.home_health.SLEEP_STAGE_3_DETECTED_DEEP_SLEEP_NON_REM_3] = capabilities.sleepSensor.sleeping.sleeping(),
    [Notification.event.home_health.STATE_IDLE] = capabilities.sleepSensor.sleeping("not sleeping")
  }

  if (cmd.args.notification_type == Notification.notification_type.HOME_HEALTH) then
    local event
    event = home_health_notification_events_map[cmd.args.event]
    if (event ~= nil) then device:emit_event_for_endpoint(cmd.src_channel, event) end
  end
end

--- @class st.zwave.defaults.sleepSensor
--- @alias sleep_sensor_defaults st.zwave.defaults.sleepSensor
--- @field public zwave_handlers table
local sleep_sensor_defaults = {
  zwave_handlers = {
    [cc.NOTIFICATION] = {
      [Notification.REPORT] = notification_handler
    }
  }
}

return sleep_sensor_defaults
