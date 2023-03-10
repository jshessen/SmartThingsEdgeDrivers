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
local ThermostatServerAttributes = require "st.matter.generated.zap_clusters.Thermostat.server.attributes"
local ThermostatServerCommands = require "st.matter.generated.zap_clusters.Thermostat.server.commands"
local ThermostatClientCommands = require "st.matter.generated.zap_clusters.Thermostat.client.commands"
local ThermostatTypes = require "st.matter.generated.zap_clusters.Thermostat.types"

--- @class st.matter.generated.zap_clusters.Thermostat
--- @alias Thermostat
---
--- @field public ID number 0x0201 the ID of this cluster
--- @field public NAME string "Thermostat" the name of this cluster
--- @field public attributes st.matter.generated.zap_clusters.ThermostatServerAttributes | st.matter.generated.zap_clusters.ThermostatClientAttributes
--- @field public commands st.matter.generated.zap_clusters.ThermostatServerCommands | st.matter.generated.zap_clusters.ThermostatClientCommands
--- @field public types st.matter.generated.zap_clusters.ThermostatTypes

local Thermostat = {}

Thermostat.ID = 0x0201
Thermostat.NAME = "Thermostat"
Thermostat.server = {}
Thermostat.client = {}
Thermostat.server.attributes = ThermostatServerAttributes:set_parent_cluster(Thermostat)
Thermostat.server.commands = ThermostatServerCommands:set_parent_cluster(Thermostat)
Thermostat.client.commands = ThermostatClientCommands:set_parent_cluster(Thermostat)
Thermostat.types = ThermostatTypes

-- Global Attributes Metadata
local GLOBAL_CLUSTER_REVISION_ATTRIBUTE = 0xFFFD

-- Represent the global attributes
local global_attr_id_map = {
  [GLOBAL_CLUSTER_REVISION_ATTRIBUTE] = {"cluster revision"},
}

--- Find an attribute by id
---
--- @param attr_id number
function Thermostat:get_attribute_by_id(attr_id)
  local attr_id_map = {
    [0x0000] = "LocalTemperature",
    [0x0001] = "OutdoorTemperature",
    [0x0002] = "Occupancy",
    [0x0003] = "AbsMinHeatSetpointLimit",
    [0x0004] = "AbsMaxHeatSetpointLimit",
    [0x0005] = "AbsMinCoolSetpointLimit",
    [0x0006] = "AbsMaxCoolSetpointLimit",
    [0x0007] = "PICoolingDemand",
    [0x0008] = "PIHeatingDemand",
    [0x0009] = "HVACSystemTypeConfiguration",
    [0x0010] = "LocalTemperatureCalibration",
    [0x0011] = "OccupiedCoolingSetpoint",
    [0x0012] = "OccupiedHeatingSetpoint",
    [0x0013] = "UnoccupiedCoolingSetpoint",
    [0x0014] = "UnoccupiedHeatingSetpoint",
    [0x0015] = "MinHeatSetpointLimit",
    [0x0016] = "MaxHeatSetpointLimit",
    [0x0017] = "MinCoolSetpointLimit",
    [0x0018] = "MaxCoolSetpointLimit",
    [0x0019] = "MinSetpointDeadBand",
    [0x001A] = "RemoteSensing",
    [0x001B] = "ControlSequenceOfOperation",
    [0x001C] = "SystemMode",
    [0x001E] = "ThermostatRunningMode",
    [0x0020] = "StartOfWeek",
    [0x0021] = "NumberOfWeeklyTransitions",
    [0x0022] = "NumberOfDailyTransitions",
    [0x0023] = "TemperatureSetpointHold",
    [0x0024] = "TemperatureSetpointHoldDuration",
    [0x0025] = "ThermostatProgrammingOperationMode",
    [0x0029] = "ThermostatRunningState",
    [0x0030] = "SetpointChangeSource",
    [0x0031] = "SetpointChangeAmount",
    [0x0032] = "SetpointChangeSourceTimestamp",
    [0x0034] = "OccupiedSetback",
    [0x0035] = "OccupiedSetbackMin",
    [0x0036] = "OccupiedSetbackMax",
    [0x0037] = "UnoccupiedSetback",
    [0x0038] = "UnoccupiedSetbackMin",
    [0x0039] = "UnoccupiedSetbackMax",
    [0x003A] = "EmergencyHeatDelta",
    [0x0040] = "ACType",
    [0x0041] = "ACCapacity",
    [0x0042] = "ACRefrigerantType",
    [0x0043] = "ACCompressorType",
    [0x0044] = "ACErrorCode",
    [0x0045] = "ACLouverPosition",
    [0x0046] = "ACCoilTemperature",
    [0x0047] = "ACCapacityformat",
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
function Thermostat:get_server_command_by_id(command_id)
  local server_id_map = {
    [0x0000] = "SetpointRaiseLower",
    [0x0001] = "SetWeeklySchedule",
    [0x0002] = "GetWeeklySchedule",
    [0x0003] = "ClearWeeklySchedule",
  }
  if server_id_map[command_id] ~= nil then
    return self.server.commands[server_id_map[command_id]]
  end
  return nil
end

--- Find a client command by id
---
--- @param command_id number
function Thermostat:get_client_command_by_id(command_id)
  local client_id_map = {
    [0x0000] = "GetWeeklyScheduleResponse",
  }
  if client_id_map[command_id] ~= nil then
    return self.client.commands[client_id_map[command_id]]
  end
  return nil
end

-- Attribute Mapping
Thermostat.attribute_direction_map = {
  ["LocalTemperature"] = "server",
  ["OutdoorTemperature"] = "server",
  ["Occupancy"] = "server",
  ["AbsMinHeatSetpointLimit"] = "server",
  ["AbsMaxHeatSetpointLimit"] = "server",
  ["AbsMinCoolSetpointLimit"] = "server",
  ["AbsMaxCoolSetpointLimit"] = "server",
  ["PICoolingDemand"] = "server",
  ["PIHeatingDemand"] = "server",
  ["HVACSystemTypeConfiguration"] = "server",
  ["LocalTemperatureCalibration"] = "server",
  ["OccupiedCoolingSetpoint"] = "server",
  ["OccupiedHeatingSetpoint"] = "server",
  ["UnoccupiedCoolingSetpoint"] = "server",
  ["UnoccupiedHeatingSetpoint"] = "server",
  ["MinHeatSetpointLimit"] = "server",
  ["MaxHeatSetpointLimit"] = "server",
  ["MinCoolSetpointLimit"] = "server",
  ["MaxCoolSetpointLimit"] = "server",
  ["MinSetpointDeadBand"] = "server",
  ["RemoteSensing"] = "server",
  ["ControlSequenceOfOperation"] = "server",
  ["SystemMode"] = "server",
  ["ThermostatRunningMode"] = "server",
  ["StartOfWeek"] = "server",
  ["NumberOfWeeklyTransitions"] = "server",
  ["NumberOfDailyTransitions"] = "server",
  ["TemperatureSetpointHold"] = "server",
  ["TemperatureSetpointHoldDuration"] = "server",
  ["ThermostatProgrammingOperationMode"] = "server",
  ["ThermostatRunningState"] = "server",
  ["SetpointChangeSource"] = "server",
  ["SetpointChangeAmount"] = "server",
  ["SetpointChangeSourceTimestamp"] = "server",
  ["OccupiedSetback"] = "server",
  ["OccupiedSetbackMin"] = "server",
  ["OccupiedSetbackMax"] = "server",
  ["UnoccupiedSetback"] = "server",
  ["UnoccupiedSetbackMin"] = "server",
  ["UnoccupiedSetbackMax"] = "server",
  ["EmergencyHeatDelta"] = "server",
  ["ACType"] = "server",
  ["ACCapacity"] = "server",
  ["ACRefrigerantType"] = "server",
  ["ACCompressorType"] = "server",
  ["ACErrorCode"] = "server",
  ["ACLouverPosition"] = "server",
  ["ACCoilTemperature"] = "server",
  ["ACCapacityformat"] = "server",
  ["AcceptedCommandList"] = "server",
  ["AttributeList"] = "server",
}

-- Command Mapping
Thermostat.command_direction_map = {
  ["SetpointRaiseLower"] = "server",
  ["SetWeeklySchedule"] = "server",
  ["GetWeeklySchedule"] = "server",
  ["ClearWeeklySchedule"] = "server",
  ["GetWeeklyScheduleResponse"] = "client",
}

Thermostat.FeatureMap = Thermostat.types.ThermostatFeature

function Thermostat.are_features_supported(feature, feature_map)
  if (Thermostat.FeatureMap.bits_are_valid(feature)) then
    return (feature & feature_map) == feature
  end
  return false
end

-- Cluster Completion
local attribute_helper_mt = {}
attribute_helper_mt.__index = function(self, key)
  local direction = Thermostat.attribute_direction_map[key]
  if direction == nil then
    error(string.format("Referenced unknown attribute %s on cluster %s", key, Thermostat.NAME))
  end
  return Thermostat[direction].attributes[key]
end
Thermostat.attributes = {}
setmetatable(Thermostat.attributes, attribute_helper_mt)

local command_helper_mt = {}
command_helper_mt.__index = function(self, key)
  local direction = Thermostat.command_direction_map[key]
  if direction == nil then
    error(string.format("Referenced unknown command %s on cluster %s", key, Thermostat.NAME))
  end
  return Thermostat[direction].commands[key] 
end
Thermostat.commands = {}
setmetatable(Thermostat.commands, command_helper_mt)

local event_helper_mt = {}
event_helper_mt.__index = function(self, key)
  return Thermostat.server.events[key]
end
Thermostat.events = {}
setmetatable(Thermostat.events, event_helper_mt)

setmetatable(Thermostat, {__index = cluster_base})  

return Thermostat

