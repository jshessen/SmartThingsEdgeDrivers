local cluster_base = require "st.zigbee.cluster_base"
local AnalogInputClientAttributes = require "st.zigbee.generated.zcl_clusters.AnalogInput.client.attributes" 
local AnalogInputServerAttributes = require "st.zigbee.generated.zcl_clusters.AnalogInput.server.attributes" 
local AnalogInputClientCommands = require "st.zigbee.generated.zcl_clusters.AnalogInput.client.commands"
local AnalogInputServerCommands = require "st.zigbee.generated.zcl_clusters.AnalogInput.server.commands"
local AnalogInputTypes = require "st.zigbee.generated.zcl_clusters.AnalogInput.types"

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

--- @class st.zigbee.zcl.clusters.AnalogInput
--- @alias AnalogInput
---
--- @field public ID number 0x000C the ID of this cluster
--- @field public NAME string "AnalogInput" the name of this cluster
--- @field public attributes st.zigbee.zcl.clusters.AnalogInputServerAttributes | st.zigbee.zcl.clusters.AnalogInputClientAttributes
--- @field public commands st.zigbee.zcl.clusters.AnalogInputServerCommands | st.zigbee.zcl.clusters.AnalogInputClientCommands
--- @field public types st.zigbee.zcl.clusters.AnalogInputTypes
local AnalogInput = {}

AnalogInput.ID = 0x000C
AnalogInput.NAME = "AnalogInput"
AnalogInput.server = {}
AnalogInput.client = {}
AnalogInput.server.attributes = AnalogInputServerAttributes:set_parent_cluster(AnalogInput) 
AnalogInput.client.attributes = AnalogInputClientAttributes:set_parent_cluster(AnalogInput) 
AnalogInput.server.commands = AnalogInputServerCommands:set_parent_cluster(AnalogInput)
AnalogInput.client.commands = AnalogInputClientCommands:set_parent_cluster(AnalogInput)
AnalogInput.types = AnalogInputTypes

--- Find an attribute by id
---
--- @param attr_id number
function AnalogInput:get_attribute_by_id(attr_id)
  local attr_id_map = {
    [0x001C] = "Description",
    [0x0041] = "MaxPresentValue",
    [0x0045] = "MinPresentValue",
    [0x0051] = "OutOfService",
    [0x0055] = "PresentValue",
    [0x0067] = "Reliability",
    [0x006A] = "Resolution",
    [0x006F] = "StatusFlags",
    [0x0075] = "EngineeringUnits",
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
function AnalogInput:get_server_command_by_id(command_id)
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
function AnalogInput:get_client_command_by_id(command_id)
  local client_id_map = {
  }
  if client_id_map[command_id] ~= nil then
    return self.client.commands[client_id_map[command_id]]
  end
  return nil
end

AnalogInput.attribute_direction_map = {
  ["Description"] = "server",
  ["MaxPresentValue"] = "server",
  ["MinPresentValue"] = "server",
  ["OutOfService"] = "server",
  ["PresentValue"] = "server",
  ["Reliability"] = "server",
  ["Resolution"] = "server",
  ["StatusFlags"] = "server",
  ["EngineeringUnits"] = "server",
  ["ApplicationType"] = "server",
}
AnalogInput.command_direction_map = {}

local attribute_helper_mt = {}
attribute_helper_mt.__index = function(self, key)
  local direction = AnalogInput.attribute_direction_map[key]
  if direction == nil then
    error(string.format("Referenced unknown attribute %s on cluster %s", key, AnalogInput.NAME))
  end
  return AnalogInput[direction].attributes[key] 
end
AnalogInput.attributes = {}
setmetatable(AnalogInput.attributes, attribute_helper_mt)

local command_helper_mt = {}
command_helper_mt.__index = function(self, key)
  local direction = AnalogInput.command_direction_map[key]
  if direction == nil then
    error(string.format("Referenced unknown command %s on cluster %s", key, AnalogInput.NAME))
  end
  return AnalogInput[direction].commands[key] 
end
AnalogInput.commands = {}
setmetatable(AnalogInput.commands, command_helper_mt)

setmetatable(AnalogInput, {__index = cluster_base})

return AnalogInput