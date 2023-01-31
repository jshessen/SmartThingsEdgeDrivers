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

--- @class st.matter.clusters.Thermostat.types.ThermostatControlSequence: st.matter.data_types.Uint8
--- @alias ThermostatControlSequence
---
--- @field public byte_length number 1
--- @field public COOLING_ONLY number 0
--- @field public COOLING_WITH_REHEAT number 1
--- @field public HEATING_ONLY number 2
--- @field public HEATING_WITH_REHEAT number 3
--- @field public COOLING_AND_HEATING number 4
--- @field public COOLING_AND_HEATING_WITH_REHEAT number 5

local ThermostatControlSequence = {}
local new_mt = UintABC.new_mt({NAME = "ThermostatControlSequence", ID = data_types.name_to_id_map["Uint8"]}, 1)
new_mt.__index.pretty_print = function(self)
  local name_lookup = {
    [self.COOLING_ONLY] = "COOLING_ONLY",
    [self.COOLING_WITH_REHEAT] = "COOLING_WITH_REHEAT",
    [self.HEATING_ONLY] = "HEATING_ONLY",
    [self.HEATING_WITH_REHEAT] = "HEATING_WITH_REHEAT",
    [self.COOLING_AND_HEATING] = "COOLING_AND_HEATING",
    [self.COOLING_AND_HEATING_WITH_REHEAT] = "COOLING_AND_HEATING_WITH_REHEAT",
  }
  return string.format("%s: %s", self.field_name or self.NAME, name_lookup[self.value] or string.format("%d", self.value))
end
new_mt.__tostring = new_mt.__index.pretty_print

new_mt.__index.COOLING_ONLY  = 0x00
new_mt.__index.COOLING_WITH_REHEAT  = 0x01
new_mt.__index.HEATING_ONLY  = 0x02
new_mt.__index.HEATING_WITH_REHEAT  = 0x03
new_mt.__index.COOLING_AND_HEATING  = 0x04
new_mt.__index.COOLING_AND_HEATING_WITH_REHEAT  = 0x05

ThermostatControlSequence.augment_type = function(cls, val)
  setmetatable(val, new_mt)
end

setmetatable(ThermostatControlSequence, new_mt)

return ThermostatControlSequence

