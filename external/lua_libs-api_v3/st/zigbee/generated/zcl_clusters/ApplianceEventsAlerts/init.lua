local cluster_base = require "st.zigbee.cluster_base"
local ApplianceEventsAlertsClientAttributes = require "st.zigbee.generated.zcl_clusters.ApplianceEventsAlerts.client.attributes" 
local ApplianceEventsAlertsServerAttributes = require "st.zigbee.generated.zcl_clusters.ApplianceEventsAlerts.server.attributes" 
local ApplianceEventsAlertsClientCommands = require "st.zigbee.generated.zcl_clusters.ApplianceEventsAlerts.client.commands"
local ApplianceEventsAlertsServerCommands = require "st.zigbee.generated.zcl_clusters.ApplianceEventsAlerts.server.commands"
local ApplianceEventsAlertsTypes = require "st.zigbee.generated.zcl_clusters.ApplianceEventsAlerts.types"

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

--- @class st.zigbee.zcl.clusters.ApplianceEventsAlerts
--- @alias ApplianceEventsAlerts
---
--- @field public ID number 0x0B02 the ID of this cluster
--- @field public NAME string "ApplianceEventsAlerts" the name of this cluster
--- @field public attributes st.zigbee.zcl.clusters.ApplianceEventsAlertsServerAttributes | st.zigbee.zcl.clusters.ApplianceEventsAlertsClientAttributes
--- @field public commands st.zigbee.zcl.clusters.ApplianceEventsAlertsServerCommands | st.zigbee.zcl.clusters.ApplianceEventsAlertsClientCommands
--- @field public types st.zigbee.zcl.clusters.ApplianceEventsAlertsTypes
local ApplianceEventsAlerts = {}

ApplianceEventsAlerts.ID = 0x0B02
ApplianceEventsAlerts.NAME = "ApplianceEventsAlerts"
ApplianceEventsAlerts.server = {}
ApplianceEventsAlerts.client = {}
ApplianceEventsAlerts.server.attributes = ApplianceEventsAlertsServerAttributes:set_parent_cluster(ApplianceEventsAlerts) 
ApplianceEventsAlerts.client.attributes = ApplianceEventsAlertsClientAttributes:set_parent_cluster(ApplianceEventsAlerts) 
ApplianceEventsAlerts.server.commands = ApplianceEventsAlertsServerCommands:set_parent_cluster(ApplianceEventsAlerts)
ApplianceEventsAlerts.client.commands = ApplianceEventsAlertsClientCommands:set_parent_cluster(ApplianceEventsAlerts)
ApplianceEventsAlerts.types = ApplianceEventsAlertsTypes

--- Find an attribute by id
---
--- @param attr_id number
function ApplianceEventsAlerts:get_attribute_by_id(attr_id)
  local attr_id_map = {
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
function ApplianceEventsAlerts:get_server_command_by_id(command_id)
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
function ApplianceEventsAlerts:get_client_command_by_id(command_id)
  local client_id_map = {
    [0x00] = "GetAlertsResponse",
    [0x01] = "AlertsNotification",
    [0x02] = "EventNotification",
  }
  if client_id_map[command_id] ~= nil then
    return self.client.commands[client_id_map[command_id]]
  end
  return nil
end

ApplianceEventsAlerts.attribute_direction_map = {}
ApplianceEventsAlerts.command_direction_map = {
  ["GetAlertsResponse"] = "client",
  ["AlertsNotification"] = "client",
  ["EventNotification"] = "client",
}

local attribute_helper_mt = {}
attribute_helper_mt.__index = function(self, key)
  local direction = ApplianceEventsAlerts.attribute_direction_map[key]
  if direction == nil then
    error(string.format("Referenced unknown attribute %s on cluster %s", key, ApplianceEventsAlerts.NAME))
  end
  return ApplianceEventsAlerts[direction].attributes[key] 
end
ApplianceEventsAlerts.attributes = {}
setmetatable(ApplianceEventsAlerts.attributes, attribute_helper_mt)

local command_helper_mt = {}
command_helper_mt.__index = function(self, key)
  local direction = ApplianceEventsAlerts.command_direction_map[key]
  if direction == nil then
    error(string.format("Referenced unknown command %s on cluster %s", key, ApplianceEventsAlerts.NAME))
  end
  return ApplianceEventsAlerts[direction].commands[key] 
end
ApplianceEventsAlerts.commands = {}
setmetatable(ApplianceEventsAlerts.commands, command_helper_mt)

setmetatable(ApplianceEventsAlerts, {__index = cluster_base})

return ApplianceEventsAlerts
