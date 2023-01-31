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
local MediaPlaybackServerAttributes = require "st.matter.generated.zap_clusters.MediaPlayback.server.attributes"
local MediaPlaybackServerCommands = require "st.matter.generated.zap_clusters.MediaPlayback.server.commands"
local MediaPlaybackClientCommands = require "st.matter.generated.zap_clusters.MediaPlayback.client.commands"
local MediaPlaybackTypes = require "st.matter.generated.zap_clusters.MediaPlayback.types"

--- @class st.matter.generated.zap_clusters.MediaPlayback
--- @alias MediaPlayback
---
--- @field public ID number 0x0506 the ID of this cluster
--- @field public NAME string "MediaPlayback" the name of this cluster
--- @field public attributes st.matter.generated.zap_clusters.MediaPlaybackServerAttributes | st.matter.generated.zap_clusters.MediaPlaybackClientAttributes
--- @field public commands st.matter.generated.zap_clusters.MediaPlaybackServerCommands | st.matter.generated.zap_clusters.MediaPlaybackClientCommands
--- @field public types st.matter.generated.zap_clusters.MediaPlaybackTypes

local MediaPlayback = {}

MediaPlayback.ID = 0x0506
MediaPlayback.NAME = "MediaPlayback"
MediaPlayback.server = {}
MediaPlayback.client = {}
MediaPlayback.server.attributes = MediaPlaybackServerAttributes:set_parent_cluster(MediaPlayback)
MediaPlayback.server.commands = MediaPlaybackServerCommands:set_parent_cluster(MediaPlayback)
MediaPlayback.client.commands = MediaPlaybackClientCommands:set_parent_cluster(MediaPlayback)
MediaPlayback.types = MediaPlaybackTypes

-- Global Attributes Metadata
local GLOBAL_CLUSTER_REVISION_ATTRIBUTE = 0xFFFD

-- Represent the global attributes
local global_attr_id_map = {
  [GLOBAL_CLUSTER_REVISION_ATTRIBUTE] = {"cluster revision"},
}

--- Find an attribute by id
---
--- @param attr_id number
function MediaPlayback:get_attribute_by_id(attr_id)
  local attr_id_map = {
    [0x0000] = "CurrentState",
    [0x0001] = "StartTime",
    [0x0002] = "Duration",
    [0x0003] = "SampledPosition",
    [0x0004] = "PlaybackSpeed",
    [0x0005] = "SeekRangeEnd",
    [0x0006] = "SeekRangeStart",
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
function MediaPlayback:get_server_command_by_id(command_id)
  local server_id_map = {
    [0x0000] = "Play",
    [0x0001] = "Pause",
    [0x0002] = "StopPlayback",
    [0x0003] = "StartOver",
    [0x0004] = "Previous",
    [0x0005] = "Next",
    [0x0006] = "Rewind",
    [0x0007] = "FastForward",
    [0x0008] = "SkipForward",
    [0x0009] = "SkipBackward",
    [0x000B] = "Seek",
  }
  if server_id_map[command_id] ~= nil then
    return self.server.commands[server_id_map[command_id]]
  end
  return nil
end

--- Find a client command by id
---
--- @param command_id number
function MediaPlayback:get_client_command_by_id(command_id)
  local client_id_map = {
    [0x000A] = "PlaybackResponse",
  }
  if client_id_map[command_id] ~= nil then
    return self.client.commands[client_id_map[command_id]]
  end
  return nil
end

-- Attribute Mapping
MediaPlayback.attribute_direction_map = {
  ["CurrentState"] = "server",
  ["StartTime"] = "server",
  ["Duration"] = "server",
  ["SampledPosition"] = "server",
  ["PlaybackSpeed"] = "server",
  ["SeekRangeEnd"] = "server",
  ["SeekRangeStart"] = "server",
  ["AcceptedCommandList"] = "server",
  ["AttributeList"] = "server",
}

-- Command Mapping
MediaPlayback.command_direction_map = {
  ["Play"] = "server",
  ["Pause"] = "server",
  ["StopPlayback"] = "server",
  ["StartOver"] = "server",
  ["Previous"] = "server",
  ["Next"] = "server",
  ["Rewind"] = "server",
  ["FastForward"] = "server",
  ["SkipForward"] = "server",
  ["SkipBackward"] = "server",
  ["Seek"] = "server",
  ["PlaybackResponse"] = "client",
}

MediaPlayback.FeatureMap = MediaPlayback.types.MediaPlaybackFeature

function MediaPlayback.are_features_supported(feature, feature_map)
  if (MediaPlayback.FeatureMap.bits_are_valid(feature)) then
    return (feature & feature_map) == feature
  end
  return false
end

-- Cluster Completion
local attribute_helper_mt = {}
attribute_helper_mt.__index = function(self, key)
  local direction = MediaPlayback.attribute_direction_map[key]
  if direction == nil then
    error(string.format("Referenced unknown attribute %s on cluster %s", key, MediaPlayback.NAME))
  end
  return MediaPlayback[direction].attributes[key]
end
MediaPlayback.attributes = {}
setmetatable(MediaPlayback.attributes, attribute_helper_mt)

local command_helper_mt = {}
command_helper_mt.__index = function(self, key)
  local direction = MediaPlayback.command_direction_map[key]
  if direction == nil then
    error(string.format("Referenced unknown command %s on cluster %s", key, MediaPlayback.NAME))
  end
  return MediaPlayback[direction].commands[key] 
end
MediaPlayback.commands = {}
setmetatable(MediaPlayback.commands, command_helper_mt)

local event_helper_mt = {}
event_helper_mt.__index = function(self, key)
  return MediaPlayback.server.events[key]
end
MediaPlayback.events = {}
setmetatable(MediaPlayback.events, event_helper_mt)

setmetatable(MediaPlayback, {__index = cluster_base})  

return MediaPlayback

