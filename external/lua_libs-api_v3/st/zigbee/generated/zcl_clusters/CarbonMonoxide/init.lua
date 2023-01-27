local cluster_base = require "st.zigbee.cluster_base"
local CarbonMonoxideClientAttributes = require "st.zigbee.generated.zcl_clusters.CarbonMonoxide.client.attributes" 
local CarbonMonoxideServerAttributes = require "st.zigbee.generated.zcl_clusters.CarbonMonoxide.server.attributes" 
local CarbonMonoxideClientCommands = require "st.zigbee.generated.zcl_clusters.CarbonMonoxide.client.commands"
local CarbonMonoxideServerCommands = require "st.zigbee.generated.zcl_clusters.CarbonMonoxide.server.commands"
local CarbonMonoxideTypes = require "st.zigbee.generated.zcl_clusters.CarbonMonoxide.types"

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

--- @class st.zigbee.zcl.clusters.CarbonMonoxide
--- @alias CarbonMonoxide
---
--- @field public ID number 0x040C the ID of this cluster
--- @field public NAME string "CarbonMonoxide" the name of this cluster
--- @field public attributes st.zigbee.zcl.clusters.CarbonMonoxideServerAttributes | st.zigbee.zcl.clusters.CarbonMonoxideClientAttributes
--- @field public commands st.zigbee.zcl.clusters.CarbonMonoxideServerCommands | st.zigbee.zcl.clusters.CarbonMonoxideClientCommands
--- @field public types st.zigbee.zcl.clusters.CarbonMonoxideTypes
local CarbonMonoxide = {}

CarbonMonoxide.ID = 0x040C
CarbonMonoxide.NAME = "CarbonMonoxide"
CarbonMonoxide.server = {}
CarbonMonoxide.client = {}
CarbonMonoxide.server.attributes = CarbonMonoxideServerAttributes:set_parent_cluster(CarbonMonoxide) 
CarbonMonoxide.client.attributes = CarbonMonoxideClientAttributes:set_parent_cluster(CarbonMonoxide) 
CarbonMonoxide.server.commands = CarbonMonoxideServerCommands:set_parent_cluster(CarbonMonoxide)
CarbonMonoxide.client.commands = CarbonMonoxideClientCommands:set_parent_cluster(CarbonMonoxide)
CarbonMonoxide.types = CarbonMonoxideTypes

--- Find an attribute by id
---
--- @param attr_id number
function CarbonMonoxide:get_attribute_by_id(attr_id)
  local attr_id_map = {
    [0x0000] = "MeasuredValue",
    [0x0001] = "MinMeasuredValue",
    [0x0002] = "MaxMeasuredValue",
    [0x0003] = "Tolerance",
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
function CarbonMonoxide:get_server_command_by_id(command_id)
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
function CarbonMonoxide:get_client_command_by_id(command_id)
  local client_id_map = {
  }
  if client_id_map[command_id] ~= nil then
    return self.client.commands[client_id_map[command_id]]
  end
  return nil
end

CarbonMonoxide.attribute_direction_map = {
  ["MeasuredValue"] = "server",
  ["MinMeasuredValue"] = "server",
  ["MaxMeasuredValue"] = "server",
  ["Tolerance"] = "server",
}
CarbonMonoxide.command_direction_map = {}

local attribute_helper_mt = {}
attribute_helper_mt.__index = function(self, key)
  local direction = CarbonMonoxide.attribute_direction_map[key]
  if direction == nil then
    error(string.format("Referenced unknown attribute %s on cluster %s", key, CarbonMonoxide.NAME))
  end
  return CarbonMonoxide[direction].attributes[key] 
end
CarbonMonoxide.attributes = {}
setmetatable(CarbonMonoxide.attributes, attribute_helper_mt)

local command_helper_mt = {}
command_helper_mt.__index = function(self, key)
  local direction = CarbonMonoxide.command_direction_map[key]
  if direction == nil then
    error(string.format("Referenced unknown command %s on cluster %s", key, CarbonMonoxide.NAME))
  end
  return CarbonMonoxide[direction].commands[key] 
end
CarbonMonoxide.commands = {}
setmetatable(CarbonMonoxide.commands, command_helper_mt)

setmetatable(CarbonMonoxide, {__index = cluster_base})

return CarbonMonoxide