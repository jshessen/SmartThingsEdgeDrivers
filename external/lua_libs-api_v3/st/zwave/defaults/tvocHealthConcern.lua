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
local Notification = (require "st.zwave.CommandClass.Notification")({version=4})

local CLEAN_EVENT_PARAMETER = 0x01
local SLIGHTLY_POLLUTED_EVENT_PARAMETER = 0x02
local MODERATELY_POLLUTED_EVENT_PARAMETER = 0x03
local HIGHLY_POLLUTED_EVENT_PARAMETER = 0x04

--- Default handler for notification command class reports
---
--- This home health reports into tvoc health concern events.
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.Notification.Report
local function notification_handler(self, device, cmd)
  if cmd.args.notification_type == Notification.notification_type.HOME_HEALTH then
    local event
    if cmd.args.event == Notification.event.home_health.VOLATILE_ORGANIC_COMPOUND_LEVEL then
      local event_parameter = cmd.args.event_parameter:byte()
      if event_parameter == CLEAN_EVENT_PARAMETER then
        event = capabilities.tvocHealthConcern.tvocHealthConcern.good()
      elseif event_parameter == SLIGHTLY_POLLUTED_EVENT_PARAMETER then
        event = capabilities.tvocHealthConcern.tvocHealthConcern.slightlyUnhealthy()
      elseif event_parameter == MODERATELY_POLLUTED_EVENT_PARAMETER then
        event = capabilities.tvocHealthConcern.tvocHealthConcern.moderate()
      elseif event_parameter == HIGHLY_POLLUTED_EVENT_PARAMETER then
        event = capabilities.tvocHealthConcern.tvocHealthConcern.veryUnhealthy()
      end
    end
    if (event ~= nil) then device:emit_event_for_endpoint(cmd.src_channel, event) end
  end
end

--- @class st.zwave.defaults.tvocHealthConcern
--- @alias tvoc_health_concern_defaults st.zwave.defaults.tvocHealthConcern
--- @field public zwave_handlers table
local tvoc_health_concern_defaults = {
  zwave_handlers = {
    [cc.NOTIFICATION] = {
      [Notification.REPORT] = notification_handler
    }
  }
}

return tvoc_health_concern_defaults
