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

--- @class st.zigbee.defaults.windowShadePreset
--- @field public capability_handlers table
--- @field public PRESET_LEVEL number default value for preset level ex: 50
--- @field public PRESET_LEVEL_KEY string Key for preset level
local windowShadePreset_defaults = {}

windowShadePreset_defaults.PRESET_LEVEL = 50
windowShadePreset_defaults.PRESET_LEVEL_KEY = "_presetLevel"

--- Default Command handler for Window Shade Preset
---
--- Going to read from a field on the device if not found then default value PRESET_LEVEL
--- @param driver Driver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param command CapabilityCommand The capability command table
function windowShadePreset_defaults.window_shade_preset_cmd(driver, device, command)
  local level = device.preferences.presetPosition or device:get_field(windowShadePreset_defaults.PRESET_LEVEL_KEY) or windowShadePreset_defaults.PRESET_LEVEL
  device:send_to_component(command.component, zcl_clusters.WindowCovering.server.commands.GoToLiftPercentage(device, level))
end

windowShadePreset_defaults.capability_handlers = {
  [capabilities.windowShadePreset.commands.presetPosition.NAME] = windowShadePreset_defaults.window_shade_preset_cmd
}

return windowShadePreset_defaults
