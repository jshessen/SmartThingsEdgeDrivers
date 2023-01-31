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
--- @type st.zwave.CommandClass.SensorBinary
local SensorBinary = (require "st.zwave.CommandClass.SensorBinary")({version=2})
--- @type st.zwave.CommandClass.Notification
local Notification = (require "st.zwave.CommandClass.Notification")({version=3})

local function determine_tamper_cmd(value)
  local event
  if value == SensorBinary.sensor_value.DETECTED_AN_EVENT then
    event = capabilities.tamperAlert.tamper.detected()
  elseif value == SensorBinary.sensor_value.IDLE then
    event = capabilities.tamperAlert.tamper.clear()
  end
  return event
end

--- Default handler for sensor binary reports for tamper-implementing devices
---
--- This converts the command value 0xFF to TamperAlert.tamper.detected()
--- otherwise TamperAlert.tamper.clear()
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.SensorBinary.Report
local function sensor_binary_report_handler(driver, device, cmd)
  if (cmd.args.sensor_type == SensorBinary.sensor_type.TAMPER) then
    local event
    if cmd.args.sensor_value ~= nil then
      event = determine_tamper_cmd(cmd.args.sensor_value)
    else
      event = determine_tamper_cmd(cmd.args.value)
    end
    if (event ~= nil) then
      device:emit_event_for_endpoint(cmd.src_channel, event)
    end
  end
end

--- Default handler for notification command class reports
---
--- This converts tamper reports across multiple notification types into tamper events.
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.Notification.Report
local function notification_handler(self, device, cmd)
  local home_security_notification_events_map = {
    [Notification.event.home_security.TAMPERING_PRODUCT_COVER_REMOVED] = capabilities.tamperAlert.tamper.detected(),
    [Notification.event.home_security.TAMPERING_INVALID_CODE] = capabilities.tamperAlert.tamper.detected(),
    [Notification.event.home_security.TAMPERING_PRODUCT_MOVED] = capabilities.tamperAlert.tamper.detected(),
    [Notification.event.home_security.STATE_IDLE] = capabilities.tamperAlert.tamper.clear(),
  }

  local event

  if (cmd.args.notification_type == Notification.notification_type.HOME_SECURITY) then
    event = home_security_notification_events_map[cmd.args.event]
  elseif (cmd.args.notification_type == Notification.notification_type.SYSTEM) then
    if (cmd.args.event == Notification.event.system.TAMPERING_PRODUCT_COVER_REMOVED) then
      event = capabilities.tamperAlert.tamper.detected()
    elseif (cmd.args.event == Notification.event.system.STATE_IDLE) then
      event = capabilities.tamperAlert.tamper.clear()
    end
  elseif (cmd.args.notification_type == Notification.notification_type.ACCESS_CONTROL) then
    if (cmd.args.event == Notification.event.access_control.KEYPAD_TEMPORARY_DISABLED or
        cmd.args.event == Notification.event.access_control.MANUALLY_ENTER_USER_ACCESS_CODE_EXCEEDS_CODE_LIMIT) then
      event = capabilities.tamperAlert.tamper.detected()
    elseif (cmd.args.event == Notification.event.access_control.STATE_IDLE) then
      event = capabilities.tamperAlert.tamper.clear()
    end
  elseif (cmd.args.notification_type == Notification.notification_type.EMERGENCY) then
    if (cmd.args.event == Notification.event.emergency.CONTACT_POLICE) then
      event = capabilities.tamperAlert.tamper.detected()
    elseif (cmd.args.event == Notification.event.emergency.STATE_IDLE) then
      event = capabilities.tamperAlert.tamper.clear()
    end
  end

  if (event ~= nil) then device:emit_event_for_endpoint(cmd.src_channel, event) end
end

--- @class st.zwave.defaults.tamperAlert
--- @alias tamper_alert_defaults st.zwave.defaults.tamperAlert
--- @field public zwave_handlers table
local tamper_alert_defaults = {
  zwave_handlers = {
    [cc.SENSOR_BINARY] = {
      [SensorBinary.REPORT] = sensor_binary_report_handler
    },
    [cc.NOTIFICATION] = {
      [Notification.REPORT] = notification_handler
    }
  }
}

return tamper_alert_defaults
