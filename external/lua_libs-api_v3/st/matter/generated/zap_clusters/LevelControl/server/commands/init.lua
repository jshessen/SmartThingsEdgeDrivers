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

local command_mt = {}
command_mt.__command_cache = {}
command_mt.__index = function(self, key)
  if command_mt.__command_cache[key] == nil then
    local req_loc = string.format("st.matter.generated.zap_clusters.LevelControl.server.commands.%s", key)
    local raw_def = require(req_loc)
    local cluster = rawget(self, "_cluster")
    command_mt.__command_cache[key] = raw_def:set_parent_cluster(cluster)
  end
  return command_mt.__command_cache[key]
end

--- @class st.matter.generated.zap_clusters.LevelControlServerCommands
---
--- @field public MoveToLevel st.matter.generated.zap_clusters.LevelControl.MoveToLevel
--- @field public Move st.matter.generated.zap_clusters.LevelControl.Move
--- @field public Step st.matter.generated.zap_clusters.LevelControl.Step
--- @field public Stop st.matter.generated.zap_clusters.LevelControl.Stop
--- @field public MoveToLevelWithOnOff st.matter.generated.zap_clusters.LevelControl.MoveToLevelWithOnOff
--- @field public MoveWithOnOff st.matter.generated.zap_clusters.LevelControl.MoveWithOnOff
--- @field public StepWithOnOff st.matter.generated.zap_clusters.LevelControl.StepWithOnOff
--- @field public StopWithOnOff st.matter.generated.zap_clusters.LevelControl.StopWithOnOff
--- @field public MoveToClosestFrequency st.matter.generated.zap_clusters.LevelControl.MoveToClosestFrequency
local LevelControlServerCommands = {}

function LevelControlServerCommands:set_parent_cluster(cluster)
  self._cluster = cluster
  return self
end

setmetatable(LevelControlServerCommands, command_mt)

return LevelControlServerCommands

