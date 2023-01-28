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
local Notification = (require "st.zwave.CommandClass.Notification")({ version = 8 })

--- Default handler for notification command class reports
---
--- This converts notification reports into occupancy events
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd table st.zwave.CommandClass.Notification.Report
local function notification_handler(self, device, cmd)
  local home_monitoring_notification_events_map = {
    [Notification.event.home_monitoring.STATE_IDLE] =
      capabilities.occupancySensor.occupancy.unoccupied(),
    [Notification.event.home_monitoring.HOME_OCCUPIED_LOCATION_PROVIDED] =
      capabilities.occupancySensor.occupancy.occupied(),
    [Notification.event.home_monitoring.HOME_OCCUPIED] =
      capabilities.occupancySensor.occupancy.occupied()
  }

  if (cmd.args.notification_type == Notification.notification_type.HOME_MONITORING) then
    local event
    event = home_monitoring_notification_events_map[cmd.args.event]
    if (event ~= nil) then
      device:emit_event_for_endpoint(cmd.src_channel, event)
    end
    return
  end
end

--- @module st.zwave.defaults.occupancySensor
--- @alias occupancy_sensor_defaults st.zwave.defaults.occupancySensor
--- @field public zwave_handlers table
local occupancy_sensor_defaults = {
  zwave_handlers = {
    [cc.NOTIFICATION] = {
      [Notification.REPORT] = notification_handler
    }
  }
}

return occupancy_sensor_defaults