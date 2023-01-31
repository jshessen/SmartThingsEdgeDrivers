local data_types = require "st.zigbee.data_types"
local EnumABC = require "st.zigbee.data_types.base_defs.EnumABC"

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

--- @class st.zigbee.zcl.clusters.DoorLock.types.DrlkOperatingMode: st.zigbee.data_types.Enum8
--- @alias DrlkOperatingMode
---
--- @field public byte_length number 1
--- @field public NORMAL number 0
--- @field public VACATION number 1
--- @field public PRIVACY number 2
--- @field public NO_RF_LOCK_OR_UNLOCK number 3
--- @field public PASSAGE number 4
local DrlkOperatingMode = {}
local new_mt = EnumABC.new_mt({NAME = "DrlkOperatingMode", ID = data_types.name_to_id_map["Enum8"]}, 1)
new_mt.__index.pretty_print = function(self)
  local name_lookup = {
    [self.NORMAL]               = "NORMAL",
    [self.VACATION]             = "VACATION",
    [self.PRIVACY]              = "PRIVACY",
    [self.NO_RF_LOCK_OR_UNLOCK] = "NO_RF_LOCK_OR_UNLOCK",
    [self.PASSAGE]              = "PASSAGE",
  }
  return string.format("%s: %s", self.NAME or self.field_name, name_lookup[self.value] or string.format("%d", self.value))
end
new_mt.__tostring = new_mt.__index.pretty_print
new_mt.__index.NORMAL               = 0x00
new_mt.__index.VACATION             = 0x01
new_mt.__index.PRIVACY              = 0x02
new_mt.__index.NO_RF_LOCK_OR_UNLOCK = 0x03
new_mt.__index.PASSAGE              = 0x04

setmetatable(DrlkOperatingMode, new_mt)

return DrlkOperatingMode
