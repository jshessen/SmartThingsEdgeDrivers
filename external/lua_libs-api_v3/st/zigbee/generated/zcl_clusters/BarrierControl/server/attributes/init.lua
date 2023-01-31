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

local attr_mt = {}
attr_mt.__attr_cache = {}
attr_mt.__index = function(self, key)
  if attr_mt.__attr_cache[key] == nil then
    local req_loc = string.format("st.zigbee.generated.zcl_clusters.BarrierControl.server.attributes.%s", key)
    local raw_def = require(req_loc)
    local cluster = rawget(self, "_cluster")
    raw_def:set_parent_cluster(cluster)
    attr_mt.__attr_cache[key] = raw_def 
  end
  return attr_mt.__attr_cache[key]
end


--- @class st.zigbee.zcl.clusters.BarrierControlServerAttributes
---
--- @field public MovingState st.zigbee.zcl.clusters.BarrierControl.MovingState
--- @field public SafetyStatus st.zigbee.zcl.clusters.BarrierControl.SafetyStatus
--- @field public Capabilities st.zigbee.zcl.clusters.BarrierControl.Capabilities
--- @field public OpenEvents st.zigbee.zcl.clusters.BarrierControl.OpenEvents
--- @field public CloseEvents st.zigbee.zcl.clusters.BarrierControl.CloseEvents
--- @field public CommandOpenEvents st.zigbee.zcl.clusters.BarrierControl.CommandOpenEvents
--- @field public CommandCloseEvents st.zigbee.zcl.clusters.BarrierControl.CommandCloseEvents
--- @field public OpenPeriod st.zigbee.zcl.clusters.BarrierControl.OpenPeriod
--- @field public ClosePeriod st.zigbee.zcl.clusters.BarrierControl.ClosePeriod
--- @field public BarrierPosition st.zigbee.zcl.clusters.BarrierControl.BarrierPosition

local BarrierControlServerAttributes = {}

function BarrierControlServerAttributes:set_parent_cluster(cluster)
  self._cluster = cluster
  return self
end

setmetatable(BarrierControlServerAttributes, attr_mt)

return BarrierControlServerAttributes
