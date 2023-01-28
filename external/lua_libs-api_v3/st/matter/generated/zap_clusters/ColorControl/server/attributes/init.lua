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

local attr_mt = {}
attr_mt.__attr_cache = {}
attr_mt.__index = function(self, key)
  if attr_mt.__attr_cache[key] == nil then
    local req_loc = string.format("st.matter.generated.zap_clusters.ColorControl.server.attributes.%s", key)
    local raw_def = require(req_loc)
    local cluster = rawget(self, "_cluster")
    raw_def:set_parent_cluster(cluster)
    attr_mt.__attr_cache[key] = raw_def
  end
  return attr_mt.__attr_cache[key]
end

--- @class st.matter.generated.zap_clusters.ColorControlServerAttributes
---
--- @field public CurrentHue st.matter.generated.zap_clusters.ColorControl.server.attributes.CurrentHue
--- @field public CurrentSaturation st.matter.generated.zap_clusters.ColorControl.server.attributes.CurrentSaturation
--- @field public RemainingTime st.matter.generated.zap_clusters.ColorControl.server.attributes.RemainingTime
--- @field public CurrentX st.matter.generated.zap_clusters.ColorControl.server.attributes.CurrentX
--- @field public CurrentY st.matter.generated.zap_clusters.ColorControl.server.attributes.CurrentY
--- @field public DriftCompensation st.matter.generated.zap_clusters.ColorControl.server.attributes.DriftCompensation
--- @field public CompensationText st.matter.generated.zap_clusters.ColorControl.server.attributes.CompensationText
--- @field public ColorTemperatureMireds st.matter.generated.zap_clusters.ColorControl.server.attributes.ColorTemperatureMireds
--- @field public ColorMode st.matter.generated.zap_clusters.ColorControl.server.attributes.ColorMode
--- @field public Options st.matter.generated.zap_clusters.ColorControl.server.attributes.Options
--- @field public NumberOfPrimaries st.matter.generated.zap_clusters.ColorControl.server.attributes.NumberOfPrimaries
--- @field public Primary1X st.matter.generated.zap_clusters.ColorControl.server.attributes.Primary1X
--- @field public Primary1Y st.matter.generated.zap_clusters.ColorControl.server.attributes.Primary1Y
--- @field public Primary1Intensity st.matter.generated.zap_clusters.ColorControl.server.attributes.Primary1Intensity
--- @field public Primary2X st.matter.generated.zap_clusters.ColorControl.server.attributes.Primary2X
--- @field public Primary2Y st.matter.generated.zap_clusters.ColorControl.server.attributes.Primary2Y
--- @field public Primary2Intensity st.matter.generated.zap_clusters.ColorControl.server.attributes.Primary2Intensity
--- @field public Primary3X st.matter.generated.zap_clusters.ColorControl.server.attributes.Primary3X
--- @field public Primary3Y st.matter.generated.zap_clusters.ColorControl.server.attributes.Primary3Y
--- @field public Primary3Intensity st.matter.generated.zap_clusters.ColorControl.server.attributes.Primary3Intensity
--- @field public Primary4X st.matter.generated.zap_clusters.ColorControl.server.attributes.Primary4X
--- @field public Primary4Y st.matter.generated.zap_clusters.ColorControl.server.attributes.Primary4Y
--- @field public Primary4Intensity st.matter.generated.zap_clusters.ColorControl.server.attributes.Primary4Intensity
--- @field public Primary5X st.matter.generated.zap_clusters.ColorControl.server.attributes.Primary5X
--- @field public Primary5Y st.matter.generated.zap_clusters.ColorControl.server.attributes.Primary5Y
--- @field public Primary5Intensity st.matter.generated.zap_clusters.ColorControl.server.attributes.Primary5Intensity
--- @field public Primary6X st.matter.generated.zap_clusters.ColorControl.server.attributes.Primary6X
--- @field public Primary6Y st.matter.generated.zap_clusters.ColorControl.server.attributes.Primary6Y
--- @field public Primary6Intensity st.matter.generated.zap_clusters.ColorControl.server.attributes.Primary6Intensity
--- @field public WhitePointX st.matter.generated.zap_clusters.ColorControl.server.attributes.WhitePointX
--- @field public WhitePointY st.matter.generated.zap_clusters.ColorControl.server.attributes.WhitePointY
--- @field public ColorPointRX st.matter.generated.zap_clusters.ColorControl.server.attributes.ColorPointRX
--- @field public ColorPointRY st.matter.generated.zap_clusters.ColorControl.server.attributes.ColorPointRY
--- @field public ColorPointRIntensity st.matter.generated.zap_clusters.ColorControl.server.attributes.ColorPointRIntensity
--- @field public ColorPointGX st.matter.generated.zap_clusters.ColorControl.server.attributes.ColorPointGX
--- @field public ColorPointGY st.matter.generated.zap_clusters.ColorControl.server.attributes.ColorPointGY
--- @field public ColorPointGIntensity st.matter.generated.zap_clusters.ColorControl.server.attributes.ColorPointGIntensity
--- @field public ColorPointBX st.matter.generated.zap_clusters.ColorControl.server.attributes.ColorPointBX
--- @field public ColorPointBY st.matter.generated.zap_clusters.ColorControl.server.attributes.ColorPointBY
--- @field public ColorPointBIntensity st.matter.generated.zap_clusters.ColorControl.server.attributes.ColorPointBIntensity
--- @field public EnhancedCurrentHue st.matter.generated.zap_clusters.ColorControl.server.attributes.EnhancedCurrentHue
--- @field public EnhancedColorMode st.matter.generated.zap_clusters.ColorControl.server.attributes.EnhancedColorMode
--- @field public ColorLoopActive st.matter.generated.zap_clusters.ColorControl.server.attributes.ColorLoopActive
--- @field public ColorLoopDirection st.matter.generated.zap_clusters.ColorControl.server.attributes.ColorLoopDirection
--- @field public ColorLoopTime st.matter.generated.zap_clusters.ColorControl.server.attributes.ColorLoopTime
--- @field public ColorLoopStartEnhancedHue st.matter.generated.zap_clusters.ColorControl.server.attributes.ColorLoopStartEnhancedHue
--- @field public ColorLoopStoredEnhancedHue st.matter.generated.zap_clusters.ColorControl.server.attributes.ColorLoopStoredEnhancedHue
--- @field public ColorCapabilities st.matter.generated.zap_clusters.ColorControl.server.attributes.ColorCapabilities
--- @field public ColorTempPhysicalMinMireds st.matter.generated.zap_clusters.ColorControl.server.attributes.ColorTempPhysicalMinMireds
--- @field public ColorTempPhysicalMaxMireds st.matter.generated.zap_clusters.ColorControl.server.attributes.ColorTempPhysicalMaxMireds
--- @field public CoupleColorTempToLevelMinMireds st.matter.generated.zap_clusters.ColorControl.server.attributes.CoupleColorTempToLevelMinMireds
--- @field public StartUpColorTemperatureMireds st.matter.generated.zap_clusters.ColorControl.server.attributes.StartUpColorTemperatureMireds
--- @field public AcceptedCommandList st.matter.generated.zap_clusters.ColorControl.server.attributes.AcceptedCommandList
--- @field public AttributeList st.matter.generated.zap_clusters.ColorControl.server.attributes.AttributeList
local ColorControlServerAttributes = {}

function ColorControlServerAttributes:set_parent_cluster(cluster)
  self._cluster = cluster
  return self
end

setmetatable(ColorControlServerAttributes, attr_mt)

return ColorControlServerAttributes

