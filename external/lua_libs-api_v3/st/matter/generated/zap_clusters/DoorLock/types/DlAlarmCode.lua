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

local data_types = require "st.matter.data_types"
local UintABC = require "st.matter.data_types.base_defs.UintABC"

--- @class st.matter.clusters.DoorLock.types.DlAlarmCode: st.matter.data_types.Uint8
--- @alias DlAlarmCode
---
--- @field public byte_length number 1
--- @field public LOCK_JAMMED number 0
--- @field public LOCK_FACTORY_RESET number 1
--- @field public LOCK_RADIO_POWER_CYCLED number 3
--- @field public WRONG_CODE_ENTRY_LIMIT number 4
--- @field public FRONT_ESCEUTCHEON_REMOVED number 5
--- @field public DOOR_FORCED_OPEN number 6
--- @field public DOOR_AJAR number 7
--- @field public FORCED_USER number 8

local DlAlarmCode = {}
local new_mt = UintABC.new_mt({NAME = "DlAlarmCode", ID = data_types.name_to_id_map["Uint8"]}, 1)
new_mt.__index.pretty_print = function(self)
  local name_lookup = {
    [self.LOCK_JAMMED] = "LOCK_JAMMED",
    [self.LOCK_FACTORY_RESET] = "LOCK_FACTORY_RESET",
    [self.LOCK_RADIO_POWER_CYCLED] = "LOCK_RADIO_POWER_CYCLED",
    [self.WRONG_CODE_ENTRY_LIMIT] = "WRONG_CODE_ENTRY_LIMIT",
    [self.FRONT_ESCEUTCHEON_REMOVED] = "FRONT_ESCEUTCHEON_REMOVED",
    [self.DOOR_FORCED_OPEN] = "DOOR_FORCED_OPEN",
    [self.DOOR_AJAR] = "DOOR_AJAR",
    [self.FORCED_USER] = "FORCED_USER",
  }
  return string.format("%s: %s", self.field_name or self.NAME, name_lookup[self.value] or string.format("%d", self.value))
end
new_mt.__tostring = new_mt.__index.pretty_print

new_mt.__index.LOCK_JAMMED  = 0x00
new_mt.__index.LOCK_FACTORY_RESET  = 0x01
new_mt.__index.LOCK_RADIO_POWER_CYCLED  = 0x03
new_mt.__index.WRONG_CODE_ENTRY_LIMIT  = 0x04
new_mt.__index.FRONT_ESCEUTCHEON_REMOVED  = 0x05
new_mt.__index.DOOR_FORCED_OPEN  = 0x06
new_mt.__index.DOOR_AJAR  = 0x07
new_mt.__index.FORCED_USER  = 0x08

DlAlarmCode.augment_type = function(cls, val)
  setmetatable(val, new_mt)
end

setmetatable(DlAlarmCode, new_mt)

return DlAlarmCode

