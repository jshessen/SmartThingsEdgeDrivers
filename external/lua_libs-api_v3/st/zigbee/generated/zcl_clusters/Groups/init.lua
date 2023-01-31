local cluster_base = require "st.zigbee.cluster_base"
local GroupsClientAttributes = require "st.zigbee.generated.zcl_clusters.Groups.client.attributes" 
local GroupsServerAttributes = require "st.zigbee.generated.zcl_clusters.Groups.server.attributes" 
local GroupsClientCommands = require "st.zigbee.generated.zcl_clusters.Groups.client.commands"
local GroupsServerCommands = require "st.zigbee.generated.zcl_clusters.Groups.server.commands"
local GroupsTypes = require "st.zigbee.generated.zcl_clusters.Groups.types"

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

--- @class st.zigbee.zcl.clusters.Groups
--- @alias Groups
---
--- @field public ID number 0x0004 the ID of this cluster
--- @field public NAME string "Groups" the name of this cluster
--- @field public attributes st.zigbee.zcl.clusters.GroupsServerAttributes | st.zigbee.zcl.clusters.GroupsClientAttributes
--- @field public commands st.zigbee.zcl.clusters.GroupsServerCommands | st.zigbee.zcl.clusters.GroupsClientCommands
--- @field public types st.zigbee.zcl.clusters.GroupsTypes
local Groups = {}

Groups.ID = 0x0004
Groups.NAME = "Groups"
Groups.server = {}
Groups.client = {}
Groups.server.attributes = GroupsServerAttributes:set_parent_cluster(Groups) 
Groups.client.attributes = GroupsClientAttributes:set_parent_cluster(Groups) 
Groups.server.commands = GroupsServerCommands:set_parent_cluster(Groups)
Groups.client.commands = GroupsClientCommands:set_parent_cluster(Groups)
Groups.types = GroupsTypes

--- Find an attribute by id
---
--- @param attr_id number
function Groups:get_attribute_by_id(attr_id)
  local attr_id_map = {
    [0x0000] = "NameSupport",
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
function Groups:get_server_command_by_id(command_id)
  local server_id_map = {
    [0x00] = "AddGroup",
    [0x01] = "ViewGroup",
    [0x02] = "GetGroupMembership",
    [0x03] = "RemoveGroup",
    [0x04] = "RemoveAllGroups",
    [0x05] = "AddGroupIfIdentifying",
  }
  if server_id_map[command_id] ~= nil then
    return self.server.commands[server_id_map[command_id]]
  end
  return nil
end

--- Find a client command by id
---
--- @param command_id number
function Groups:get_client_command_by_id(command_id)
  local client_id_map = {
    [0x00] = "AddGroupResponse",
    [0x01] = "ViewGroupResponse",
    [0x02] = "GetGroupMembershipResponse",
    [0x03] = "RemoveGroupResponse",
  }
  if client_id_map[command_id] ~= nil then
    return self.client.commands[client_id_map[command_id]]
  end
  return nil
end

Groups.attribute_direction_map = {
  ["NameSupport"] = "server",
}
Groups.command_direction_map = {
  ["AddGroupResponse"] = "client",
  ["ViewGroupResponse"] = "client",
  ["GetGroupMembershipResponse"] = "client",
  ["RemoveGroupResponse"] = "client",
  ["AddGroup"] = "server",
  ["ViewGroup"] = "server",
  ["GetGroupMembership"] = "server",
  ["RemoveGroup"] = "server",
  ["RemoveAllGroups"] = "server",
  ["AddGroupIfIdentifying"] = "server",
}

local attribute_helper_mt = {}
attribute_helper_mt.__index = function(self, key)
  local direction = Groups.attribute_direction_map[key]
  if direction == nil then
    error(string.format("Referenced unknown attribute %s on cluster %s", key, Groups.NAME))
  end
  return Groups[direction].attributes[key] 
end
Groups.attributes = {}
setmetatable(Groups.attributes, attribute_helper_mt)

local command_helper_mt = {}
command_helper_mt.__index = function(self, key)
  local direction = Groups.command_direction_map[key]
  if direction == nil then
    error(string.format("Referenced unknown command %s on cluster %s", key, Groups.NAME))
  end
  return Groups[direction].commands[key] 
end
Groups.commands = {}
setmetatable(Groups.commands, command_helper_mt)

setmetatable(Groups, {__index = cluster_base})

return Groups
