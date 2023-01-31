local cluster_base = require "st.zigbee.cluster_base"
local ThermostatUserInterfaceConfigurationClientAttributes = require "st.zigbee.generated.zcl_clusters.ThermostatUserInterfaceConfiguration.client.attributes" 
local ThermostatUserInterfaceConfigurationServerAttributes = require "st.zigbee.generated.zcl_clusters.ThermostatUserInterfaceConfiguration.server.attributes" 
local ThermostatUserInterfaceConfigurationClientCommands = require "st.zigbee.generated.zcl_clusters.ThermostatUserInterfaceConfiguration.client.commands"
local ThermostatUserInterfaceConfigurationServerCommands = require "st.zigbee.generated.zcl_clusters.ThermostatUserInterfaceConfiguration.server.commands"
local ThermostatUserInterfaceConfigurationTypes = require "st.zigbee.generated.zcl_clusters.ThermostatUserInterfaceConfiguration.types"

-- Copyright 2023 SmartThings
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

-- DO NOT EDIT: this code is automatically generated by tools/zigbee-lib_generator/generate_clusters_from_xml.py
-- Script version: b'b65edec6f2fbd53d4aeed6ab08ac6f3b5ae73520'
-- ZCL XML version: 7.2

--- @class st.zigbee.zcl.clusters.ThermostatUserInterfaceConfiguration
--- @alias ThermostatUserInterfaceConfiguration
---
--- @field public ID number 0x0204 the ID of this cluster
--- @field public NAME string "ThermostatUserInterfaceConfiguration" the name of this cluster
--- @field public attributes st.zigbee.zcl.clusters.ThermostatUserInterfaceConfigurationServerAttributes | st.zigbee.zcl.clusters.ThermostatUserInterfaceConfigurationClientAttributes
--- @field public commands st.zigbee.zcl.clusters.ThermostatUserInterfaceConfigurationServerCommands | st.zigbee.zcl.clusters.ThermostatUserInterfaceConfigurationClientCommands
--- @field public types st.zigbee.zcl.clusters.ThermostatUserInterfaceConfigurationTypes
local ThermostatUserInterfaceConfiguration = {}

ThermostatUserInterfaceConfiguration.ID = 0x0204
ThermostatUserInterfaceConfiguration.NAME = "ThermostatUserInterfaceConfiguration"
ThermostatUserInterfaceConfiguration.server = {}
ThermostatUserInterfaceConfiguration.client = {}
ThermostatUserInterfaceConfiguration.server.attributes = ThermostatUserInterfaceConfigurationServerAttributes:set_parent_cluster(ThermostatUserInterfaceConfiguration) 
ThermostatUserInterfaceConfiguration.client.attributes = ThermostatUserInterfaceConfigurationClientAttributes:set_parent_cluster(ThermostatUserInterfaceConfiguration) 
ThermostatUserInterfaceConfiguration.server.commands = ThermostatUserInterfaceConfigurationServerCommands:set_parent_cluster(ThermostatUserInterfaceConfiguration)
ThermostatUserInterfaceConfiguration.client.commands = ThermostatUserInterfaceConfigurationClientCommands:set_parent_cluster(ThermostatUserInterfaceConfiguration)
ThermostatUserInterfaceConfiguration.types = ThermostatUserInterfaceConfigurationTypes

--- Find an attribute by id
---
--- @param attr_id number
function ThermostatUserInterfaceConfiguration:get_attribute_by_id(attr_id)
  local attr_id_map = {
    [0x0000] = "TemperatureDisplayMode",
    [0x0001] = "KeypadLockout",
    [0x0002] = "ScheduleProgrammingVisibility",
  }
  local attr_name = attr_id_map[attr_id]
  if attr_name ~= nil then
    return self.attributes[attr_name]
  end
  return nil
end
  
--- Find a server command by id
---
--- @param command_id number
function ThermostatUserInterfaceConfiguration:get_server_command_by_id(command_id)
  local server_id_map = {
  }
  if server_id_map[command_id] ~= nil then
    return self.server.commands[server_id_map[command_id]]
  end
  return nil
end

--- Find a client command by id
---
--- @param command_id number
function ThermostatUserInterfaceConfiguration:get_client_command_by_id(command_id)
  local client_id_map = {
  }
  if client_id_map[command_id] ~= nil then
    return self.client.commands[client_id_map[command_id]]
  end
  return nil
end

ThermostatUserInterfaceConfiguration.attribute_direction_map = {
  ["TemperatureDisplayMode"] = "server",
  ["KeypadLockout"] = "server",
  ["ScheduleProgrammingVisibility"] = "server",
}
ThermostatUserInterfaceConfiguration.command_direction_map = {}

local attribute_helper_mt = {}
attribute_helper_mt.__index = function(self, key)
  local direction = ThermostatUserInterfaceConfiguration.attribute_direction_map[key]
  if direction == nil then
    error(string.format("Referenced unknown attribute %s on cluster %s", key, ThermostatUserInterfaceConfiguration.NAME))
  end
  return ThermostatUserInterfaceConfiguration[direction].attributes[key] 
end
ThermostatUserInterfaceConfiguration.attributes = {}
setmetatable(ThermostatUserInterfaceConfiguration.attributes, attribute_helper_mt)

local command_helper_mt = {}
command_helper_mt.__index = function(self, key)
  local direction = ThermostatUserInterfaceConfiguration.command_direction_map[key]
  if direction == nil then
    error(string.format("Referenced unknown command %s on cluster %s", key, ThermostatUserInterfaceConfiguration.NAME))
  end
  return ThermostatUserInterfaceConfiguration[direction].commands[key] 
end
ThermostatUserInterfaceConfiguration.commands = {}
setmetatable(ThermostatUserInterfaceConfiguration.commands, command_helper_mt)

setmetatable(ThermostatUserInterfaceConfiguration, {__index = cluster_base})

return ThermostatUserInterfaceConfiguration
