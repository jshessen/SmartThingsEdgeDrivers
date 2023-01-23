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

local types_mt = {}
types_mt.__types_cache = {}
types_mt.__index = function(self, key)
  if types_mt.__types_cache[key] == nil then
    local req_loc = string.format("st.matter.generated.zap_clusters.ColorControl.types.%s", key)
    local cluster_type = require(req_loc)
    types_mt.__types_cache[key] = cluster_type
  end
  return types_mt.__types_cache[key]
end

--- @class st.matter.generated.zap_clusters.ColorControlTypes
---
--- @field public ColorLoopAction st.matter.generated.zap_clusters.ColorControl.types.ColorLoopAction
--- @field public ColorLoopDirection st.matter.generated.zap_clusters.ColorControl.types.ColorLoopDirection
--- @field public ColorMode st.matter.generated.zap_clusters.ColorControl.types.ColorMode
--- @field public HueDirection st.matter.generated.zap_clusters.ColorControl.types.HueDirection
--- @field public HueMoveMode st.matter.generated.zap_clusters.ColorControl.types.HueMoveMode
--- @field public HueStepMode st.matter.generated.zap_clusters.ColorControl.types.HueStepMode
--- @field public SaturationMoveMode st.matter.generated.zap_clusters.ColorControl.types.SaturationMoveMode
--- @field public SaturationStepMode st.matter.generated.zap_clusters.ColorControl.types.SaturationStepMode

--- @field public ColorCapabilities st.matter.generated.zap_clusters.ColorControl.types.ColorCapabilities
--- @field public ColorControlFeature st.matter.generated.zap_clusters.ColorControl.types.ColorControlFeature
--- @field public ColorLoopUpdateFlags st.matter.generated.zap_clusters.ColorControl.types.ColorLoopUpdateFlags
local ColorControlTypes = {}

setmetatable(ColorControlTypes, types_mt)

return ColorControlTypes

