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
local cc  = require "st.zwave.CommandClass"
--- @type st.zwave.CommandClass.Notification
local Notification = (require "st.zwave.CommandClass.Notification")({version=3,strict=true})

--- Default handler for pest control and home security notification reports
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.Notification.Report
local function notification_handler(self, device, cmd)
  local notification_type = cmd.args.notification_type
  local event = cmd.args.event
  local pest_control = capabilities.pestControl.pestControl

  if notification_type == Notification.notification_type.HOME_SECURITY then
    if event == Notification.event.home_security.STATE_IDLE then
      device:emit_event_for_endpoint(cmd.src_channel, pest_control.idle())
    elseif event == Notification.event.home_security.MOTION_DETECTION_LOCATION_PROVIDED then
      device:emit_event_for_endpoint(cmd.src_channel, pest_control.pestExterminated())
    end
  elseif notification_type == Notification.notification_type.PEST_CONTROL then
    if event == Notification.event.pest_control.STATE_IDLE then
      device:emit_event_for_endpoint(cmd.src_channel, pest_control.idle())
    elseif event == Notification.event.pest_control.TRAP_ARMED or
            event == Notification.event.pest_control.TRAP_ARMED_LOCATION_PROVIDED then
      device:emit_event_for_endpoint(cmd.src_channel, pest_control.trapArmed())
    elseif event == Notification.event.pest_control.TRAP_RE_ARM_REQUIRED then
      device:emit_event_for_endpoint(cmd.src_channel, pest_control.trapRearmRequired())
    elseif event == Notification.event.pest_control.PEST_DETECTED or
            event == Notification.event.pest_control.PEST_DETECTED_LOCATION_PROVIDED then
      device:emit_event_for_endpoint(cmd.src_channel, pest_control.pestDetected())
    elseif event == Notification.event.pest_control.PEST_EXTERMINATED then
      device:emit_event_for_endpoint(cmd.src_channel, pest_control.pestExterminated())
    elseif event == Notification.event.pest_control.UNKNOWN_EVENT_STATE then
      device:emit_event_for_endpoint(cmd.src_channel, pest_control.idle())
    end
  end
end

--- @class st.zwave.defaults.pestControl
--- @alias pest_control_defaults st.zwave.defaults.pestControl
--- @field public zwave_handlers table
local pest_control_defaults = {
  zwave_handlers = {
    [cc.NOTIFICATION] = {
      [Notification.REPORT] = notification_handler
    }
  }
}

return pest_control_defaults
