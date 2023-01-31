local cluster_base = require "st.zigbee.cluster_base"
local DehumidificationControlClientAttributes = require "st.zigbee.generated.zcl_clusters.DehumidificationControl.client.attributes" 
local DehumidificationControlServerAttributes = require "st.zigbee.generated.zcl_clusters.DehumidificationControl.server.attributes" 
local DehumidificationControlClientCommands = require "st.zigbee.generated.zcl_clusters.DehumidificationControl.client.commands"
local DehumidificationControlServerCommands = require "st.zigbee.generated.zcl_clusters.DehumidificationControl.server.commands"
local DehumidificationControlTypes = require "st.zigbee.generated.zcl_clusters.DehumidificationControl.types"

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

--- @class st.zigbee.zcl.clusters.DehumidificationControl
--- @alias DehumidificationControl
---
--- @field public ID number 0x0203 the ID of this cluster
--- @field public NAME string "DehumidificationControl" the name of this cluster
--- @field public attributes st.zigbee.zcl.clusters.DehumidificationControlServerAttributes | st.zigbee.zcl.clusters.DehumidificationControlClientAttributes
--- @field public commands st.zigbee.zcl.clusters.DehumidificationControlServerCommands | st.zigbee.zcl.clusters.DehumidificationControlClientCommands
--- @field public types st.zigbee.zcl.clusters.DehumidificationControlTypes
local DehumidificationControl = {}

DehumidificationControl.ID = 0x0203
DehumidificationControl.NAME = "DehumidificationControl"
DehumidificationControl.server = {}
DehumidificationControl.client = {}
DehumidificationControl.server.attributes = DehumidificationControlServerAttributes:set_parent_cluster(DehumidificationControl) 
DehumidificationControl.client.attributes = DehumidificationControlClientAttributes:set_parent_cluster(DehumidificationControl) 
DehumidificationControl.server.commands = DehumidificationControlServerCommands:set_parent_cluster(DehumidificationControl)
DehumidificationControl.client.commands = DehumidificationControlClientCommands:set_parent_cluster(DehumidificationControl)
DehumidificationControl.types = DehumidificationControlTypes

--- Find an attribute by id
---
--- @param attr_id number
function DehumidificationControl:get_attribute_by_id(attr_id)
  local attr_id_map = {
    [0x0000] = "RelativeHumidity",
    [0x0001] = "DehumidificationCooling",
    [0x0010] = "RHDehumidificationSetpoint",
    [0x0011] = "RelativeHumidityMode",
    [0x0012] = "DehumidificationLockout",
    [0x0013] = "DehumidificationHysteresis",
    [0x0014] = "DehumidificationMaxCool",
    [0x0015] = "RelativeHumidityDisplay",
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
function DehumidificationControl:get_server_command_by_id(command_id)
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
function DehumidificationControl:get_client_command_by_id(command_id)
  local client_id_map = {
  }
  if client_id_map[command_id] ~= nil then
    return self.client.commands[client_id_map[command_id]]
  end
  return nil
end

DehumidificationControl.attribute_direction_map = {
  ["RelativeHumidity"] = "server",
  ["DehumidificationCooling"] = "server",
  ["RHDehumidificationSetpoint"] = "server",
  ["RelativeHumidityMode"] = "server",
  ["DehumidificationLockout"] = "server",
  ["DehumidificationHysteresis"] = "server",
  ["DehumidificationMaxCool"] = "server",
  ["RelativeHumidityDisplay"] = "server",
}
DehumidificationControl.command_direction_map = {}

local attribute_helper_mt = {}
attribute_helper_mt.__index = function(self, key)
  local direction = DehumidificationControl.attribute_direction_map[key]
  if direction == nil then
    error(string.format("Referenced unknown attribute %s on cluster %s", key, DehumidificationControl.NAME))
  end
  return DehumidificationControl[direction].attributes[key] 
end
DehumidificationControl.attributes = {}
setmetatable(DehumidificationControl.attributes, attribute_helper_mt)

local command_helper_mt = {}
command_helper_mt.__index = function(self, key)
  local direction = DehumidificationControl.command_direction_map[key]
  if direction == nil then
    error(string.format("Referenced unknown command %s on cluster %s", key, DehumidificationControl.NAME))
  end
  return DehumidificationControl[direction].commands[key] 
end
DehumidificationControl.commands = {}
setmetatable(DehumidificationControl.commands, command_helper_mt)

setmetatable(DehumidificationControl, {__index = cluster_base})

return DehumidificationControl
