local cluster_base = require "st.zigbee.cluster_base"
local BasicClientAttributes = require "st.zigbee.generated.zcl_clusters.Basic.client.attributes" 
local BasicServerAttributes = require "st.zigbee.generated.zcl_clusters.Basic.server.attributes" 
local BasicClientCommands = require "st.zigbee.generated.zcl_clusters.Basic.client.commands"
local BasicServerCommands = require "st.zigbee.generated.zcl_clusters.Basic.server.commands"
local BasicTypes = require "st.zigbee.generated.zcl_clusters.Basic.types"

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

--- @class st.zigbee.zcl.clusters.Basic
--- @alias Basic
---
--- @field public ID number 0x0000 the ID of this cluster
--- @field public NAME string "Basic" the name of this cluster
--- @field public attributes st.zigbee.zcl.clusters.BasicServerAttributes | st.zigbee.zcl.clusters.BasicClientAttributes
--- @field public commands st.zigbee.zcl.clusters.BasicServerCommands | st.zigbee.zcl.clusters.BasicClientCommands
--- @field public types st.zigbee.zcl.clusters.BasicTypes
local Basic = {}

Basic.ID = 0x0000
Basic.NAME = "Basic"
Basic.server = {}
Basic.client = {}
Basic.server.attributes = BasicServerAttributes:set_parent_cluster(Basic) 
Basic.client.attributes = BasicClientAttributes:set_parent_cluster(Basic) 
Basic.server.commands = BasicServerCommands:set_parent_cluster(Basic)
Basic.client.commands = BasicClientCommands:set_parent_cluster(Basic)
Basic.types = BasicTypes

--- Find an attribute by id
---
--- @param attr_id number
function Basic:get_attribute_by_id(attr_id)
  local attr_id_map = {
    [0x0000] = "ZCLVersion",
    [0x0001] = "ApplicationVersion",
    [0x0002] = "StackVersion",
    [0x0003] = "HWVersion",
    [0x0004] = "ManufacturerName",
    [0x0005] = "ModelIdentifier",
    [0x0006] = "DateCode",
    [0x0007] = "PowerSource",
    [0x0008] = "GenericDeviceClass",
    [0x0009] = "GenericDeviceType",
    [0x000A] = "ProductCode",
    [0x000B] = "ProductURL",
    [0x000C] = "ManufacturerVersionDetails",
    [0x000D] = "SerialNumber",
    [0x000E] = "ProductLabel",
    [0x0010] = "LocationDescription",
    [0x0011] = "PhysicalEnvironment",
    [0x0012] = "DeviceEnabled",
    [0x0013] = "AlarmMask",
    [0x0014] = "DisableLocalConfig",
    [0x4000] = "SWBuildID",
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
function Basic:get_server_command_by_id(command_id)
  local server_id_map = {
    [0x00] = "ResetToFactoryDefaults",
  }
  if server_id_map[command_id] ~= nil then
    return self.server.commands[server_id_map[command_id]]
  end
  return nil
end

--- Find a client command by id
---
--- @param command_id number
function Basic:get_client_command_by_id(command_id)
  local client_id_map = {
  }
  if client_id_map[command_id] ~= nil then
    return self.client.commands[client_id_map[command_id]]
  end
  return nil
end

Basic.attribute_direction_map = {
  ["ZCLVersion"] = "server",
  ["ApplicationVersion"] = "server",
  ["StackVersion"] = "server",
  ["HWVersion"] = "server",
  ["ManufacturerName"] = "server",
  ["ModelIdentifier"] = "server",
  ["DateCode"] = "server",
  ["PowerSource"] = "server",
  ["GenericDeviceClass"] = "server",
  ["GenericDeviceType"] = "server",
  ["ProductCode"] = "server",
  ["ProductURL"] = "server",
  ["ManufacturerVersionDetails"] = "server",
  ["SerialNumber"] = "server",
  ["ProductLabel"] = "server",
  ["LocationDescription"] = "server",
  ["PhysicalEnvironment"] = "server",
  ["DeviceEnabled"] = "server",
  ["AlarmMask"] = "server",
  ["DisableLocalConfig"] = "server",
  ["SWBuildID"] = "server",
}
Basic.command_direction_map = {
  ["ResetToFactoryDefaults"] = "server",
}

local attribute_helper_mt = {}
attribute_helper_mt.__index = function(self, key)
  local direction = Basic.attribute_direction_map[key]
  if direction == nil then
    error(string.format("Referenced unknown attribute %s on cluster %s", key, Basic.NAME))
  end
  return Basic[direction].attributes[key] 
end
Basic.attributes = {}
setmetatable(Basic.attributes, attribute_helper_mt)

local command_helper_mt = {}
command_helper_mt.__index = function(self, key)
  local direction = Basic.command_direction_map[key]
  if direction == nil then
    error(string.format("Referenced unknown command %s on cluster %s", key, Basic.NAME))
  end
  return Basic[direction].commands[key] 
end
Basic.commands = {}
setmetatable(Basic.commands, command_helper_mt)

setmetatable(Basic, {__index = cluster_base})

return Basic
