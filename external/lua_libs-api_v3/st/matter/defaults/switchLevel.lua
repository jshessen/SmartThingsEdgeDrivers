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

--- @class st.matter.defaults.switchLevel
--- @field public matter_handlers table
--- @field public subscribed_attributes table
--- @field public capability_handlers table
local switch_level_defaults = {}

local function level_attr_handler(driver, device, ib, response)
  if ib.data.value ~= nil then
    local level = ib.data.value.value
    if level > 0 then
      level = math.max(1, math.floor((level / 254.0 * 100) + 0.5))
    end
    device:emit_event_for_endpoint(ib.endpoint_id, capabilities.switchLevel.level(level))
  end
end

local function handle_set_level(driver, device, cmd)
  local endpoint_id = device:component_to_endpoint(cmd.component)
  local level = math.floor(cmd.args.level/100.0 * 254)
  local req = clusters.LevelControl.server.commands.MoveToLevelWithOnOff(
    device,
    endpoint_id,
    level,
    cmd.args.rate or 0,
    0,
    0
  )
  device:send(req)
end

switch_level_defaults.matter_handlers = {
  attr = {
    [clusters.LevelControl.ID] = {
      [clusters.LevelControl.attributes.CurrentLevel.ID] = level_attr_handler,
    },
  },
}
switch_level_defaults.capability_handlers = {
  [capabilities.switchLevel.commands.setLevel] = handle_set_level,
}
switch_level_defaults.subscribed_attributes = {clusters.LevelControl.attributes.CurrentLevel}

return switch_level_defaults
