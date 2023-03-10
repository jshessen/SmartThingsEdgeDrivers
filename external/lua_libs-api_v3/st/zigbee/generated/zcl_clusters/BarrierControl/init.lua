local cluster_base = require "st.zigbee.cluster_base"
local BarrierControlClientAttributes = require "st.zigbee.generated.zcl_clusters.BarrierControl.client.attributes" 
local BarrierControlServerAttributes = require "st.zigbee.generated.zcl_clusters.BarrierControl.server.attributes" 
local BarrierControlClientCommands = require "st.zigbee.generated.zcl_clusters.BarrierControl.client.commands"
local BarrierControlServerCommands = require "st.zigbee.generated.zcl_clusters.BarrierControl.server.commands"
local BarrierControlTypes = require "st.zigbee.generated.zcl_clusters.BarrierControl.types"

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

--- @class st.zigbee.zcl.clusters.BarrierControl
--- @alias BarrierControl
---
--- @field public ID number 0x0103 the ID of this cluster
--- @field public NAME string "BarrierControl" the name of this cluster
--- @field public attributes st.zigbee.zcl.clusters.BarrierControlServerAttributes | st.zigbee.zcl.clusters.BarrierControlClientAttributes
--- @field public commands st.zigbee.zcl.clusters.BarrierControlServerCommands | st.zigbee.zcl.clusters.BarrierControlClientCommands
--- @field public types st.zigbee.zcl.clusters.BarrierControlTypes
local BarrierControl = {}

BarrierControl.ID = 0x0103
BarrierControl.NAME = "BarrierControl"
BarrierControl.server = {}
BarrierControl.client = {}
BarrierControl.server.attributes = BarrierControlServerAttributes:set_parent_cluster(BarrierControl) 
BarrierControl.client.attributes = BarrierControlClientAttributes:set_parent_cluster(BarrierControl) 
BarrierControl.server.commands = BarrierControlServerCommands:set_parent_cluster(BarrierControl)
BarrierControl.client.commands = BarrierControlClientCommands:set_parent_cluster(BarrierControl)
BarrierControl.types = BarrierControlTypes

--- Find an attribute by id
---
--- @param attr_id number
function BarrierControl:get_attribute_by_id(attr_id)
  local attr_id_map = {
    [0x0001] = "MovingState",
    [0x0002] = "SafetyStatus",
    [0x0003] = "Capabilities",
    [0x0004] = "OpenEvents",
    [0x0005] = "CloseEvents",
    [0x0006] = "CommandOpenEvents",
    [0x0007] = "CommandCloseEvents",
    [0x0008] = "OpenPeriod",
    [0x0009] = "ClosePeriod",
    [0x000A] = "BarrierPosition",
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
function BarrierControl:get_server_command_by_id(command_id)
  local server_id_map = {
    [0x00] = "GoToPercent",
    [0x01] = "Stop",
  }
  if server_id_map[command_id] ~= nil then
    return self.server.commands[server_id_map[command_id]]
  end
  return nil
end

--- Find a client command by id
---
--- @param command_id number
function BarrierControl:get_client_command_by_id(command_id)
  local client_id_map = {
  }
  if client_id_map[command_id] ~= nil then
    return self.client.commands[client_id_map[command_id]]
  end
  return nil
end

BarrierControl.attribute_direction_map = {
  ["MovingState"] = "server",
  ["SafetyStatus"] = "server",
  ["Capabilities"] = "server",
  ["OpenEvents"] = "server",
  ["CloseEvents"] = "server",
  ["CommandOpenEvents"] = "server",
  ["CommandCloseEvents"] = "server",
  ["OpenPeriod"] = "server",
  ["ClosePeriod"] = "server",
  ["BarrierPosition"] = "server",
}
BarrierControl.command_direction_map = {
  ["GoToPercent"] = "server",
  ["Stop"] = "server",
}

local attribute_helper_mt = {}
attribute_helper_mt.__index = function(self, key)
  local direction = BarrierControl.attribute_direction_map[key]
  if direction == nil then
    error(string.format("Referenced unknown attribute %s on cluster %s", key, BarrierControl.NAME))
  end
  return BarrierControl[direction].attributes[key] 
end
BarrierControl.attributes = {}
setmetatable(BarrierControl.attributes, attribute_helper_mt)

local command_helper_mt = {}
command_helper_mt.__index = function(self, key)
  local direction = BarrierControl.command_direction_map[key]
  if direction == nil then
    error(string.format("Referenced unknown command %s on cluster %s", key, BarrierControl.NAME))
  end
  return BarrierControl[direction].commands[key] 
end
BarrierControl.commands = {}
setmetatable(BarrierControl.commands, command_helper_mt)

setmetatable(BarrierControl, {__index = cluster_base})

return BarrierControl
