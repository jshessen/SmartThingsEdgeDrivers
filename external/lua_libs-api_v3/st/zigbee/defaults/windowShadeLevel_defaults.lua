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
local zcl_clusters = require "st.zigbee.zcl.clusters"
local capabilities = require "st.capabilities"

--- @class st.zigbee.defaults.windowShadeLevel
--- @field public capability_handlers table
local windowShadeLevel_defaults = {}

--- Default Command handler for Window Shade Level
---
--- @param driver Driver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param command CapabilityCommand The capability command table
function windowShadeLevel_defaults.window_shade_level_cmd(driver, device, command)
  local level = command.args.shadeLevel
  device:send_to_component(command.component, zcl_clusters.WindowCovering.server.commands.GoToLiftPercentage(device, level))
end

windowShadeLevel_defaults.capability_handlers = {
  [capabilities.windowShadeLevel.commands.setShadeLevel.NAME] = windowShadeLevel_defaults.window_shade_level_cmd
}

return windowShadeLevel_defaults
