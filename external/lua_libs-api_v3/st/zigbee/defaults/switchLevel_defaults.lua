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

--- @class st.zigbee.defaults.switchLevel
--- @field public zigbee_handlers table
--- @field public attribute_configurations table
--- @field public capability_handlers table
--- @field public default_current_level_configuration st.zigbee.defaults.switchLevel.CurrentLevelConfiguration
local switch_level_defaults = {}

--- Default handler for current level attribute on the level control cluster
---
--- This converts the Uint8 value from 0-254 to SwitchLevel.level(0-100)
---
--- @param driver Driver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param value st.zigbee.data_types.Uint8 the value of the current level attribute of the level control cluster
--- @param zb_rx st.zigbee.ZigbeeMessageRx the full message this report came in
function switch_level_defaults.level_attr_handler(driver, device, value, zb_rx)
  local level = value.value
  if level > 0 then
    level = math.max(1, math.floor((level / 254.0 * 100) + 0.5))
  end
  device:emit_event_for_endpoint(zb_rx.address_header.src_endpoint.value, capabilities.switchLevel.level(level))
end

--- Default handler for the SwitchLevel.setLevel command
---
--- This will send the move to level with on off command to the level control cluster
---
--- @param driver Driver The current driver running containing necessary context for execution
--- @param device st.Device The device this message was received from containing identifying information
--- @param command table The capability command table
function switch_level_defaults.set_level(driver, device, command)
  local level = math.floor(command.args.level/100.0 * 254)
  device:send_to_component(command.component, zcl_clusters.Level.server.commands.MoveToLevelWithOnOff(device, level, command.args.rate or 0xFFFF))
end

switch_level_defaults.zigbee_handlers = {
  global = {},
  cluster = {},
  attr = {
    [zcl_clusters.Level] = {
      [zcl_clusters.Level.attributes.CurrentLevel] = switch_level_defaults.level_attr_handler
    }
  }
}
switch_level_defaults.capability_handlers = {
  [capabilities.switchLevel.commands.setLevel.NAME] = switch_level_defaults.set_level
}

--- @class st.zigbee.defaults.switchLevel.CurrentLevelConfiguration
--- @field public cluster number LevelCluster cluster ID 0x0008
--- @field public attribute number CurrentLevel attribute ID 0x0000
--- @field public minimum_interval number 1 second
--- @field public maximum_interval number 3600 seconds (1 hour)
--- @field public data_type st.zigbee.data_types.Uint8 the Uint8 class
--- @field public reportable_change number 1
local current_level_configuration =   {
  cluster = zcl_clusters.Level.ID,
  attribute = zcl_clusters.Level.attributes.CurrentLevel.ID,
  minimum_interval = 1,
  maximum_interval = 3600,
  data_type = zcl_clusters.Level.attributes.CurrentLevel.base_type,
  reportable_change = 1
}

switch_level_defaults.default_current_level_configuration = current_level_configuration

switch_level_defaults.attribute_configurations = {
  current_level_configuration
}

return switch_level_defaults
