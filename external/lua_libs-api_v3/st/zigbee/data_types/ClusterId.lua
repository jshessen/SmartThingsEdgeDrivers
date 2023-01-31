-- Copyright 2021 SmartThings
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
local UintABC = require "st.zigbee.data_types.base_defs.UintABC"
local clusters = require "st.zigbee.zcl.clusters"

--- @class st.zigbee.data_types.ClusterId: st.zigbee.data_types.UintABC
--- @field public ID number 0xE8
--- @field public NAME string "ClusterId"
--- @field public byte_length number 2
--- @field public value number The cluster ID this represents
local ClusterId = {}
local mt = UintABC.new_mt({ NAME = "ClusterId", ID = 0xE8, is_discrete = true }, 2)
mt.__index.pretty_print = function(self)
  local self_str = "%s: %s"
  local cluster_tab = clusters.get_cluster_from_id(self.value)
  local cluster_name = string.format("0x%04X", self.value)
  if cluster_tab ~= nil then
    cluster_name = cluster_tab.NAME
  end
  return string.format(self_str, self.field_name or self.NAME, cluster_name)
end
setmetatable(ClusterId, mt)


return ClusterId
