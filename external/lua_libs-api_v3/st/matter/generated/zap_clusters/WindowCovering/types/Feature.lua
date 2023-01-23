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

--- @class st.matter.clusters.WindowCovering.types.Feature
--- @alias Feature
---
--- @field public LIFT number 1
--- @field public TILT number 2
--- @field public POSITION_AWARE_LIFT number 4
--- @field public ABSOLUTE_POSITION number 8
--- @field public POSITION_AWARE_TILT number 16

local Feature = {}
local new_mt = UintABC.new_mt({NAME = "Feature", ID = data_types.name_to_id_map["Uint32"]}, 4)

Feature.BASE_MASK = 0xFFFF
Feature.LIFT = 0x0001
Feature.TILT = 0x0002
Feature.POSITION_AWARE_LIFT = 0x0004
Feature.ABSOLUTE_POSITION = 0x0008
Feature.POSITION_AWARE_TILT = 0x0010

Feature.mask_fields = {
  BASE_MASK = 0xFFFF,
  LIFT = 0x0001,
  TILT = 0x0002,
  POSITION_AWARE_LIFT = 0x0004,
  ABSOLUTE_POSITION = 0x0008,
  POSITION_AWARE_TILT = 0x0010,
}

--- @function Feature:is_lift_set
--- @return boolean True if the value of LIFT is non-zero
Feature.is_lift_set = function(self)
  return (self.value & self.LIFT) ~= 0
end
 
--- @function Feature:set_lift
--- Set the value of the bit in the LIFT field to 1
Feature.set_lift = function(self)
  if self.value ~= nil then
    self.value = self.value | self.LIFT
  else
    self.value = self.LIFT
  end
end

--- @function Feature:unset_lift
--- Set the value of the bits in the LIFT field to 0
Feature.unset_lift = function(self)
  self.value = self.value & (~self.LIFT & self.BASE_MASK)
end
--- @function Feature:is_tilt_set
--- @return boolean True if the value of TILT is non-zero
Feature.is_tilt_set = function(self)
  return (self.value & self.TILT) ~= 0
end
 
--- @function Feature:set_tilt
--- Set the value of the bit in the TILT field to 1
Feature.set_tilt = function(self)
  if self.value ~= nil then
    self.value = self.value | self.TILT
  else
    self.value = self.TILT
  end
end

--- @function Feature:unset_tilt
--- Set the value of the bits in the TILT field to 0
Feature.unset_tilt = function(self)
  self.value = self.value & (~self.TILT & self.BASE_MASK)
end
--- @function Feature:is_position_aware_lift_set
--- @return boolean True if the value of POSITION_AWARE_LIFT is non-zero
Feature.is_position_aware_lift_set = function(self)
  return (self.value & self.POSITION_AWARE_LIFT) ~= 0
end
 
--- @function Feature:set_position_aware_lift
--- Set the value of the bit in the POSITION_AWARE_LIFT field to 1
Feature.set_position_aware_lift = function(self)
  if self.value ~= nil then
    self.value = self.value | self.POSITION_AWARE_LIFT
  else
    self.value = self.POSITION_AWARE_LIFT
  end
end

--- @function Feature:unset_position_aware_lift
--- Set the value of the bits in the POSITION_AWARE_LIFT field to 0
Feature.unset_position_aware_lift = function(self)
  self.value = self.value & (~self.POSITION_AWARE_LIFT & self.BASE_MASK)
end
--- @function Feature:is_absolute_position_set
--- @return boolean True if the value of ABSOLUTE_POSITION is non-zero
Feature.is_absolute_position_set = function(self)
  return (self.value & self.ABSOLUTE_POSITION) ~= 0
end
 
--- @function Feature:set_absolute_position
--- Set the value of the bit in the ABSOLUTE_POSITION field to 1
Feature.set_absolute_position = function(self)
  if self.value ~= nil then
    self.value = self.value | self.ABSOLUTE_POSITION
  else
    self.value = self.ABSOLUTE_POSITION
  end
end

--- @function Feature:unset_absolute_position
--- Set the value of the bits in the ABSOLUTE_POSITION field to 0
Feature.unset_absolute_position = function(self)
  self.value = self.value & (~self.ABSOLUTE_POSITION & self.BASE_MASK)
end
--- @function Feature:is_position_aware_tilt_set
--- @return boolean True if the value of POSITION_AWARE_TILT is non-zero
Feature.is_position_aware_tilt_set = function(self)
  return (self.value & self.POSITION_AWARE_TILT) ~= 0
end
 
--- @function Feature:set_position_aware_tilt
--- Set the value of the bit in the POSITION_AWARE_TILT field to 1
Feature.set_position_aware_tilt = function(self)
  if self.value ~= nil then
    self.value = self.value | self.POSITION_AWARE_TILT
  else
    self.value = self.POSITION_AWARE_TILT
  end
end

--- @function Feature:unset_position_aware_tilt
--- Set the value of the bits in the POSITION_AWARE_TILT field to 0
Feature.unset_position_aware_tilt = function(self)
  self.value = self.value & (~self.POSITION_AWARE_TILT & self.BASE_MASK)
end


Feature.mask_methods = {
  is_lift_set = Feature.is_lift_set,
  set_lift = Feature.set_lift,
  unset_lift = Feature.unset_lift,
  is_tilt_set = Feature.is_tilt_set,
  set_tilt = Feature.set_tilt,
  unset_tilt = Feature.unset_tilt,
  is_position_aware_lift_set = Feature.is_position_aware_lift_set,
  set_position_aware_lift = Feature.set_position_aware_lift,
  unset_position_aware_lift = Feature.unset_position_aware_lift,
  is_absolute_position_set = Feature.is_absolute_position_set,
  set_absolute_position = Feature.set_absolute_position,
  unset_absolute_position = Feature.unset_absolute_position,
  is_position_aware_tilt_set = Feature.is_position_aware_tilt_set,
  set_position_aware_tilt = Feature.set_position_aware_tilt,
  unset_position_aware_tilt = Feature.unset_position_aware_tilt,
}

Feature.augment_type = function(cls, val)
  setmetatable(val, new_mt)
end

setmetatable(Feature, new_mt)

return Feature

