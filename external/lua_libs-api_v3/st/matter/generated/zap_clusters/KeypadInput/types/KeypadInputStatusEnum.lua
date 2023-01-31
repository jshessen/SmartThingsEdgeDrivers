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

--- @class st.matter.clusters.KeypadInput.types.KeypadInputStatusEnum: st.matter.data_types.Uint8
--- @alias KeypadInputStatusEnum
---
--- @field public byte_length number 1
--- @field public SUCCESS number 0
--- @field public UNSUPPORTED_KEY number 1
--- @field public INVALID_KEY_IN_CURRENT_STATE number 2

local KeypadInputStatusEnum = {}
local new_mt = UintABC.new_mt({NAME = "KeypadInputStatusEnum", ID = data_types.name_to_id_map["Uint8"]}, 1)
new_mt.__index.pretty_print = function(self)
  local name_lookup = {
    [self.SUCCESS] = "SUCCESS",
    [self.UNSUPPORTED_KEY] = "UNSUPPORTED_KEY",
    [self.INVALID_KEY_IN_CURRENT_STATE] = "INVALID_KEY_IN_CURRENT_STATE",
  }
  return string.format("%s: %s", self.field_name or self.NAME, name_lookup[self.value] or string.format("%d", self.value))
end
new_mt.__tostring = new_mt.__index.pretty_print

new_mt.__index.SUCCESS  = 0x00
new_mt.__index.UNSUPPORTED_KEY  = 0x01
new_mt.__index.INVALID_KEY_IN_CURRENT_STATE  = 0x02

KeypadInputStatusEnum.augment_type = function(cls, val)
  setmetatable(val, new_mt)
end

setmetatable(KeypadInputStatusEnum, new_mt)

return KeypadInputStatusEnum


