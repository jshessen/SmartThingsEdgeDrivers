local data_types = require "st.zigbee.data_types"
local UintABC = require "st.zigbee.data_types.base_defs.UintABC"

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

--- @class st.zigbee.zcl.clusters.DoorLock.types.DrlkSettableUserStatus: st.zigbee.data_types.Uint8
--- @alias DrlkSettableUserStatus
---
--- @field public byte_length number 1
--- @field public OCCUPIED_ENABLED number 1
--- @field public OCCUPIED_DISABLED number 3
local DrlkSettableUserStatus = {}
local new_mt = UintABC.new_mt({NAME = "DrlkSettableUserStatus", ID = data_types.name_to_id_map["Uint8"]}, 1)
new_mt.__index.pretty_print = function(self)
  local name_lookup = {
    [self.OCCUPIED_ENABLED]  = "OCCUPIED_ENABLED",
    [self.OCCUPIED_DISABLED] = "OCCUPIED_DISABLED",
  }
  return string.format("%s: %s", self.NAME or self.field_name, name_lookup[self.value] or string.format("%d", self.value))
end
new_mt.__tostring = new_mt.__index.pretty_print
new_mt.__index.OCCUPIED_ENABLED  = 0x01
new_mt.__index.OCCUPIED_DISABLED = 0x03

setmetatable(DrlkSettableUserStatus, new_mt)

return DrlkSettableUserStatus
