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
local log = require "log"
--- @type st.zwave.CommandClass
local cc = require "st.zwave.CommandClass"
--- @type st.zwave.CommandClass.Battery
local Battery = (require "st.zwave.CommandClass.Battery")({ version=1 })
--- @type st.zwave.CommandClass.Notification
local Notification = (require "st.zwave.CommandClass.Notification")({ version=3 })
--- @type st.zwave.CommandClass.WakeUp
local WakeUp = (require "st.zwave.CommandClass.WakeUp")({ version=1 })

--- Default handler for WakeUp.Notification.  On wakeup, execute refresh
--- to collect current state.
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.WakeUp.Notification
local function wakeup_notification(self, device, cmd)
  device:refresh()
end

--- Default handler for battery command class reports
---
--- This converts the command battery level from 0-100 -> Battery.battery(value), 0xFF -> Battery.battery(1)
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.Battery.Report
local function battery_report_handler(self, device, cmd)
  local battery_level = cmd.args.battery_level or 1
  if (battery_level == Battery.battery_level.BATTERY_LOW_WARNING) then
    battery_level = 1
  end

  if battery_level > 100 then
    log.error_with({ hub_logs = true }, "Z-Wave battery report handler: invalid battery level " .. battery_level)
  else
    device:emit_event_for_endpoint(cmd.src_channel, capabilities.battery.battery(battery_level))
  end
end

--- Default handler for power management notification reports
---
--- These notification events are mostly generated by lock devices and either indicate the batteries have
--- been changed and need to be polled, or that the batteries are very low
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.Notification.Report
local function notification_report_handler(self, device, cmd)
  if (cmd.args.notification_type == Notification.notification_type.POWER_MANAGEMENT) then
    if (cmd.args.event == Notification.event.power_management.POWER_HAS_BEEN_APPLIED) then
      -- this means the batteries were replaced and we should poll them in a few seconds
      local follow_up_poll = function()
        device:send(Battery:Get({}))
      end

      device.thread:call_with_delay(10, follow_up_poll)
    elseif (cmd.args.event == Notification.event.power_management.REPLACE_BATTERY_SOON) then
      device:emit_event_for_endpoint(cmd.src_channel, capabilities.battery.battery(1))
    elseif (cmd.args.event == Notification.event.power_management.REPLACE_BATTERY_NOW) then
      device:emit_event_for_endpoint(cmd.src_channel, capabilities.battery.battery(0))
    end
  end
end

--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param component string
--- @param endpoint integer
local function get_refresh_commands(driver, device, component, endpoint)
  if device:supports_capability_by_id(capabilities.battery.ID, component) and device:is_cc_supported(cc.BATTERY, endpoint) then
    return {Battery:Get({}, {dst_channels = {endpoint}})}
  end
end

--- @class st.zwave.defaults.battery
--- @alias battery_defaults st.zwave.defaults.battery
--- @field public zwave_handlers table
--- @field public get_refresh_commands function
local battery_defaults = {
  zwave_handlers = {
    [cc.BATTERY] = {
      [Battery.REPORT] = battery_report_handler
    },
    [cc.NOTIFICATION] = {
      [Notification.REPORT] = notification_report_handler
    },
    [cc.WAKE_UP] = {
      [WakeUp.NOTIFICATION] = wakeup_notification
    }
  },
  get_refresh_commands = get_refresh_commands
}

return battery_defaults
