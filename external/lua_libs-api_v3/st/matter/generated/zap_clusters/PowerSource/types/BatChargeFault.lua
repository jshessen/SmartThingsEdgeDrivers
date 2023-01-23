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

--- @class st.matter.clusters.PowerSource.types.BatChargeFault: st.matter.data_types.Uint8
--- @alias BatChargeFault
---
--- @field public byte_length number 1
--- @field public UNSPECFIED number 0
--- @field public AMBIENT_TOO_HOT number 1
--- @field public AMBIENT_TOO_COLD number 2
--- @field public BATTERY_TOO_HOT number 3
--- @field public BATTERY_TOO_COLD number 4
--- @field public BATTERY_ABSENT number 5
--- @field public BATTERY_OVER_VOLTAGE number 6
--- @field public BATTERY_UNDER_VOLTAGE number 7
--- @field public CHARGER_OVER_VOLTAGE number 8
--- @field public CHARGER_UNDER_VOLTAGE number 9
--- @field public SAFETY_TIMEOUT number 10

local BatChargeFault = {}
local new_mt = UintABC.new_mt({NAME = "BatChargeFault", ID = data_types.name_to_id_map["Uint8"]}, 1)
new_mt.__index.pretty_print = function(self)
  local name_lookup = {
    [self.UNSPECFIED] = "UNSPECFIED",
    [self.AMBIENT_TOO_HOT] = "AMBIENT_TOO_HOT",
    [self.AMBIENT_TOO_COLD] = "AMBIENT_TOO_COLD",
    [self.BATTERY_TOO_HOT] = "BATTERY_TOO_HOT",
    [self.BATTERY_TOO_COLD] = "BATTERY_TOO_COLD",
    [self.BATTERY_ABSENT] = "BATTERY_ABSENT",
    [self.BATTERY_OVER_VOLTAGE] = "BATTERY_OVER_VOLTAGE",
    [self.BATTERY_UNDER_VOLTAGE] = "BATTERY_UNDER_VOLTAGE",
    [self.CHARGER_OVER_VOLTAGE] = "CHARGER_OVER_VOLTAGE",
    [self.CHARGER_UNDER_VOLTAGE] = "CHARGER_UNDER_VOLTAGE",
    [self.SAFETY_TIMEOUT] = "SAFETY_TIMEOUT",
  }
  return string.format("%s: %s", self.field_name or self.NAME, name_lookup[self.value] or string.format("%d", self.value))
end
new_mt.__tostring = new_mt.__index.pretty_print

new_mt.__index.UNSPECFIED  = 0x00
new_mt.__index.AMBIENT_TOO_HOT  = 0x01
new_mt.__index.AMBIENT_TOO_COLD  = 0x02
new_mt.__index.BATTERY_TOO_HOT  = 0x03
new_mt.__index.BATTERY_TOO_COLD  = 0x04
new_mt.__index.BATTERY_ABSENT  = 0x05
new_mt.__index.BATTERY_OVER_VOLTAGE  = 0x06
new_mt.__index.BATTERY_UNDER_VOLTAGE  = 0x07
new_mt.__index.CHARGER_OVER_VOLTAGE  = 0x08
new_mt.__index.CHARGER_UNDER_VOLTAGE  = 0x09
new_mt.__index.SAFETY_TIMEOUT  = 0x0A

BatChargeFault.augment_type = function(cls, val)
  setmetatable(val, new_mt)
end

setmetatable(BatChargeFault, new_mt)

return BatChargeFault

