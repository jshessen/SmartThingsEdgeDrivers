local cluster_base = require "st.zigbee.cluster_base"
local TimeClientAttributes = require "st.zigbee.generated.zcl_clusters.Time.client.attributes" 
local TimeServerAttributes = require "st.zigbee.generated.zcl_clusters.Time.server.attributes" 
local TimeClientCommands = require "st.zigbee.generated.zcl_clusters.Time.client.commands"
local TimeServerCommands = require "st.zigbee.generated.zcl_clusters.Time.server.commands"
local TimeTypes = require "st.zigbee.generated.zcl_clusters.Time.types"

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

--- @class st.zigbee.zcl.clusters.Time
--- @alias Time
---
--- @field public ID number 0x000A the ID of this cluster
--- @field public NAME string "Time" the name of this cluster
--- @field public attributes st.zigbee.zcl.clusters.TimeServerAttributes | st.zigbee.zcl.clusters.TimeClientAttributes
--- @field public commands st.zigbee.zcl.clusters.TimeServerCommands | st.zigbee.zcl.clusters.TimeClientCommands
--- @field public types st.zigbee.zcl.clusters.TimeTypes
local Time = {}

Time.ID = 0x000A
Time.NAME = "Time"
Time.server = {}
Time.client = {}
Time.server.attributes = TimeServerAttributes:set_parent_cluster(Time) 
Time.client.attributes = TimeClientAttributes:set_parent_cluster(Time) 
Time.server.commands = TimeServerCommands:set_parent_cluster(Time)
Time.client.commands = TimeClientCommands:set_parent_cluster(Time)
Time.types = TimeTypes

--- Find an attribute by id
---
--- @param attr_id number
function Time:get_attribute_by_id(attr_id)
  local attr_id_map = {
    [0x0000] = "Time",
    [0x0001] = "TimeStatus",
    [0x0002] = "TimeZone",
    [0x0003] = "DstStart",
    [0x0004] = "DstEnd",
    [0x0005] = "DstShift",
    [0x0006] = "StandardTime",
    [0x0007] = "LocalTime",
    [0x0008] = "LastSetTime",
    [0x0009] = "ValidUntilTime",
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
function Time:get_server_command_by_id(command_id)
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
function Time:get_client_command_by_id(command_id)
  local client_id_map = {
  }
  if client_id_map[command_id] ~= nil then
    return self.client.commands[client_id_map[command_id]]
  end
  return nil
end

Time.attribute_direction_map = {
  ["Time"] = "server",
  ["TimeStatus"] = "server",
  ["TimeZone"] = "server",
  ["DstStart"] = "server",
  ["DstEnd"] = "server",
  ["DstShift"] = "server",
  ["StandardTime"] = "server",
  ["LocalTime"] = "server",
  ["LastSetTime"] = "server",
  ["ValidUntilTime"] = "server",
}
Time.command_direction_map = {}

local attribute_helper_mt = {}
attribute_helper_mt.__index = function(self, key)
  local direction = Time.attribute_direction_map[key]
  if direction == nil then
    error(string.format("Referenced unknown attribute %s on cluster %s", key, Time.NAME))
  end
  return Time[direction].attributes[key] 
end
Time.attributes = {}
setmetatable(Time.attributes, attribute_helper_mt)

local command_helper_mt = {}
command_helper_mt.__index = function(self, key)
  local direction = Time.command_direction_map[key]
  if direction == nil then
    error(string.format("Referenced unknown command %s on cluster %s", key, Time.NAME))
  end
  return Time[direction].commands[key] 
end
Time.commands = {}
setmetatable(Time.commands, command_helper_mt)

setmetatable(Time, {__index = cluster_base})

return Time