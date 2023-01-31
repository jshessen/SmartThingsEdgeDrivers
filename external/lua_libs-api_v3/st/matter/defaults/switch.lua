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
local clusters = require "st.matter.generated.zap_clusters.init"

--- @class st.matter.defaults.switch
--- @field public matter_handlers table
--- @field public subscribed_attributes table
--- @field public capability_handlers table
local switch_defaults = {}

local function on_off_attr_handler(driver, device, ib, response)
  if ib.data.value then
    device:emit_event_for_endpoint(ib.endpoint_id, capabilities.switch.switch.on())
  else
    device:emit_event_for_endpoint(ib.endpoint_id, capabilities.switch.switch.off())
  end
end

local function handle_switch_on(driver, device, cmd)
  local endpoint_id = device:component_to_endpoint(cmd.component)
  local req = clusters.OnOff.server.commands.On(device, endpoint_id)
  device:send(req)
end

local function handle_switch_off(driver, device, cmd)
  local endpoint_id = device:component_to_endpoint(cmd.component)
  local req = clusters.OnOff.server.commands.Off(device, endpoint_id)
  device:send(req)
end

switch_defaults.matter_handlers = {
  attr = {[clusters.OnOff.ID] = {[clusters.OnOff.attributes.OnOff.ID] = on_off_attr_handler}},
}
switch_defaults.capability_handlers = {
  [capabilities.switch.commands.on] = handle_switch_on,
  [capabilities.switch.commands.off] = handle_switch_off,
}
switch_defaults.subscribed_attributes = {clusters.OnOff.attributes.OnOff}

return switch_defaults
