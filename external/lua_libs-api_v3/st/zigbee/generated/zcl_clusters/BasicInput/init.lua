local cluster_base = require "st.zigbee.cluster_base"
local BasicInputClientAttributes = require "st.zigbee.generated.zcl_clusters.BasicInput.client.attributes" 
local BasicInputServerAttributes = require "st.zigbee.generated.zcl_clusters.BasicInput.server.attributes" 
local BasicInputClientCommands = require "st.zigbee.generated.zcl_clusters.BasicInput.client.commands"
local BasicInputServerCommands = require "st.zigbee.generated.zcl_clusters.BasicInput.server.commands"
local BasicInputTypes = require "st.zigbee.generated.zcl_clusters.BasicInput.types"

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
-- This is generated from an incomplete definition and is not a complete description of the cluster.

--- @class st.zigbee.zcl.clusters.BasicInput
--- @alias BasicInput
---
--- @field public ID number 0x000f the ID of this cluster
--- @field public NAME string "BasicInput" the name of this cluster
--- @field public attributes st.zigbee.zcl.clusters.BasicInputServerAttributes | st.zigbee.zcl.clusters.BasicInputClientAttributes
--- @field public commands st.zigbee.zcl.clusters.BasicInputServerCommands | st.zigbee.zcl.clusters.BasicInputClientCommands
--- @field public types st.zigbee.zcl.clusters.BasicInputTypes
local BasicInput = {}

BasicInput.ID = 0x000f
BasicInput.NAME = "BasicInput"
BasicInput.server = {}
BasicInput.client = {}
BasicInput.server.attributes = BasicInputServerAttributes:set_parent_cluster(BasicInput) 
BasicInput.client.attributes = BasicInputClientAttributes:set_parent_cluster(BasicInput) 
BasicInput.server.commands = BasicInputServerCommands:set_parent_cluster(BasicInput)
BasicInput.client.commands = BasicInputClientCommands:set_parent_cluster(BasicInput)
BasicInput.types = BasicInputTypes

--- Find an attribute by id
---
--- @param attr_id number
function BasicInput:get_attribute_by_id(attr_id)
  local attr_id_map = {
    [0x0004] = "ActiveText",
    [0x001C] = "Description",
    [0x002E] = "InactiveText",
    [0x0051] = "OutOfService",
    [0x0054] = "Polarity",
    [0x0055] = "PresentValue",
    [0x0067] = "Reliability",
    [0x006F] = "StatusFlags",
    [0x0100] = "ApplicationType",
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
function BasicInput:get_server_command_by_id(command_id)
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
function BasicInput:get_client_command_by_id(command_id)
  local client_id_map = {
  }
  if client_id_map[command_id] ~= nil then
    return self.client.commands[client_id_map[command_id]]
  end
  return nil
end

BasicInput.attribute_direction_map = {
  ["ActiveText"] = "server",
  ["Description"] = "server",
  ["InactiveText"] = "server",
  ["OutOfService"] = "server",
  ["Polarity"] = "server",
  ["PresentValue"] = "server",
  ["Reliability"] = "server",
  ["StatusFlags"] = "server",
  ["ApplicationType"] = "server",
}
BasicInput.command_direction_map = {}

local attribute_helper_mt = {}
attribute_helper_mt.__index = function(self, key)
  local direction = BasicInput.attribute_direction_map[key]
  if direction == nil then
    error(string.format("Referenced unknown attribute %s on cluster %s", key, BasicInput.NAME))
  end
  return BasicInput[direction].attributes[key] 
end
BasicInput.attributes = {}
setmetatable(BasicInput.attributes, attribute_helper_mt)

local command_helper_mt = {}
command_helper_mt.__index = function(self, key)
  local direction = BasicInput.command_direction_map[key]
  if direction == nil then
    error(string.format("Referenced unknown command %s on cluster %s", key, BasicInput.NAME))
  end
  return BasicInput[direction].commands[key] 
end
BasicInput.commands = {}
setmetatable(BasicInput.commands, command_helper_mt)

setmetatable(BasicInput, {__index = cluster_base})

return BasicInput
