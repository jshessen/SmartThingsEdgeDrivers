-- Copyright 2022 SmartThings
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

-- DO NOT EDIT: this code is automatically generated by ZCL Advanced Platform generator.

local cluster_base = require "st.matter.cluster_base"
local TemperatureMeasurementServerAttributes = require "st.matter.generated.zap_clusters.TemperatureMeasurement.server.attributes"
local TemperatureMeasurementServerCommands = require "st.matter.generated.zap_clusters.TemperatureMeasurement.server.commands"
local TemperatureMeasurementTypes = require "st.matter.generated.zap_clusters.TemperatureMeasurement.types"

--- @class st.matter.generated.zap_clusters.TemperatureMeasurement
--- @alias TemperatureMeasurement
---
--- @field public ID number 0x0402 the ID of this cluster
--- @field public NAME string "TemperatureMeasurement" the name of this cluster
--- @field public attributes st.matter.generated.zap_clusters.TemperatureMeasurementServerAttributes | st.matter.generated.zap_clusters.TemperatureMeasurementClientAttributes
--- @field public commands st.matter.generated.zap_clusters.TemperatureMeasurementServerCommands | st.matter.generated.zap_clusters.TemperatureMeasurementClientCommands
--- @field public types st.matter.generated.zap_clusters.TemperatureMeasurementTypes

local TemperatureMeasurement = {}

TemperatureMeasurement.ID = 0x0402
TemperatureMeasurement.NAME = "TemperatureMeasurement"
TemperatureMeasurement.server = {}
TemperatureMeasurement.client = {}
TemperatureMeasurement.server.attributes = TemperatureMeasurementServerAttributes:set_parent_cluster(TemperatureMeasurement)
TemperatureMeasurement.server.commands = TemperatureMeasurementServerCommands:set_parent_cluster(TemperatureMeasurement)
TemperatureMeasurement.types = TemperatureMeasurementTypes

-- Global Attributes Metadata
local GLOBAL_CLUSTER_REVISION_ATTRIBUTE = 0xFFFD

-- Represent the global attributes
local global_attr_id_map = {
  [GLOBAL_CLUSTER_REVISION_ATTRIBUTE] = {"cluster revision"},
}

--- Find an attribute by id
---
--- @param attr_id number
function TemperatureMeasurement:get_attribute_by_id(attr_id)
  local attr_id_map = {
    [0x0000] = "MeasuredValue",
    [0x0001] = "MinMeasuredValue",
    [0x0002] = "MaxMeasuredValue",
    [0x0003] = "Tolerance",
    [0xFFF9] = "AcceptedCommandList",
    [0xFFFB] = "AttributeList",
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
function TemperatureMeasurement:get_server_command_by_id(command_id)
  local server_id_map = {
  }
  if server_id_map[command_id] ~= nil then
    return self.server.commands[server_id_map[command_id]]
  end
  return nil
end


-- Attribute Mapping
TemperatureMeasurement.attribute_direction_map = {
  ["MeasuredValue"] = "server",
  ["MinMeasuredValue"] = "server",
  ["MaxMeasuredValue"] = "server",
  ["Tolerance"] = "server",
  ["AcceptedCommandList"] = "server",
  ["AttributeList"] = "server",
}

-- Command Mapping
TemperatureMeasurement.command_direction_map = {
}

-- Cluster Completion
local attribute_helper_mt = {}
attribute_helper_mt.__index = function(self, key)
  local direction = TemperatureMeasurement.attribute_direction_map[key]
  if direction == nil then
    error(string.format("Referenced unknown attribute %s on cluster %s", key, TemperatureMeasurement.NAME))
  end
  return TemperatureMeasurement[direction].attributes[key]
end
TemperatureMeasurement.attributes = {}
setmetatable(TemperatureMeasurement.attributes, attribute_helper_mt)

local command_helper_mt = {}
command_helper_mt.__index = function(self, key)
  local direction = TemperatureMeasurement.command_direction_map[key]
  if direction == nil then
    error(string.format("Referenced unknown command %s on cluster %s", key, TemperatureMeasurement.NAME))
  end
  return TemperatureMeasurement[direction].commands[key] 
end
TemperatureMeasurement.commands = {}
setmetatable(TemperatureMeasurement.commands, command_helper_mt)

local event_helper_mt = {}
event_helper_mt.__index = function(self, key)
  return TemperatureMeasurement.server.events[key]
end
TemperatureMeasurement.events = {}
setmetatable(TemperatureMeasurement.events, event_helper_mt)

setmetatable(TemperatureMeasurement, {__index = cluster_base})  

return TemperatureMeasurement
