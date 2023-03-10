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

--- @class st.matter.clusters.Thermostat.types.DayOfWeek
--- @alias DayOfWeek
---
--- @field public SUNDAY number 1
--- @field public MONDAY number 2
--- @field public TUESDAY number 4
--- @field public WEDNESDAY number 8
--- @field public THURSDAY number 16
--- @field public FRIDAY number 32
--- @field public SATURDAY number 64
--- @field public AWAY_OR_VACATION number 128

local DayOfWeek = {}
local new_mt = UintABC.new_mt({NAME = "DayOfWeek", ID = data_types.name_to_id_map["Uint8"]}, 1)

DayOfWeek.BASE_MASK = 0xFFFF
DayOfWeek.SUNDAY = 0x0001
DayOfWeek.MONDAY = 0x0002
DayOfWeek.TUESDAY = 0x0004
DayOfWeek.WEDNESDAY = 0x0008
DayOfWeek.THURSDAY = 0x0010
DayOfWeek.FRIDAY = 0x0020
DayOfWeek.SATURDAY = 0x0040
DayOfWeek.AWAY_OR_VACATION = 0x0080

DayOfWeek.mask_fields = {
  BASE_MASK = 0xFFFF,
  SUNDAY = 0x0001,
  MONDAY = 0x0002,
  TUESDAY = 0x0004,
  WEDNESDAY = 0x0008,
  THURSDAY = 0x0010,
  FRIDAY = 0x0020,
  SATURDAY = 0x0040,
  AWAY_OR_VACATION = 0x0080,
}

--- @function DayOfWeek:is_sunday_set
--- @return boolean True if the value of SUNDAY is non-zero
DayOfWeek.is_sunday_set = function(self)
  return (self.value & self.SUNDAY) ~= 0
end
 
--- @function DayOfWeek:set_sunday
--- Set the value of the bit in the SUNDAY field to 1
DayOfWeek.set_sunday = function(self)
  if self.value ~= nil then
    self.value = self.value | self.SUNDAY
  else
    self.value = self.SUNDAY
  end
end

--- @function DayOfWeek:unset_sunday
--- Set the value of the bits in the SUNDAY field to 0
DayOfWeek.unset_sunday = function(self)
  self.value = self.value & (~self.SUNDAY & self.BASE_MASK)
end
--- @function DayOfWeek:is_monday_set
--- @return boolean True if the value of MONDAY is non-zero
DayOfWeek.is_monday_set = function(self)
  return (self.value & self.MONDAY) ~= 0
end
 
--- @function DayOfWeek:set_monday
--- Set the value of the bit in the MONDAY field to 1
DayOfWeek.set_monday = function(self)
  if self.value ~= nil then
    self.value = self.value | self.MONDAY
  else
    self.value = self.MONDAY
  end
end

--- @function DayOfWeek:unset_monday
--- Set the value of the bits in the MONDAY field to 0
DayOfWeek.unset_monday = function(self)
  self.value = self.value & (~self.MONDAY & self.BASE_MASK)
end
--- @function DayOfWeek:is_tuesday_set
--- @return boolean True if the value of TUESDAY is non-zero
DayOfWeek.is_tuesday_set = function(self)
  return (self.value & self.TUESDAY) ~= 0
end
 
--- @function DayOfWeek:set_tuesday
--- Set the value of the bit in the TUESDAY field to 1
DayOfWeek.set_tuesday = function(self)
  if self.value ~= nil then
    self.value = self.value | self.TUESDAY
  else
    self.value = self.TUESDAY
  end
end

--- @function DayOfWeek:unset_tuesday
--- Set the value of the bits in the TUESDAY field to 0
DayOfWeek.unset_tuesday = function(self)
  self.value = self.value & (~self.TUESDAY & self.BASE_MASK)
end
--- @function DayOfWeek:is_wednesday_set
--- @return boolean True if the value of WEDNESDAY is non-zero
DayOfWeek.is_wednesday_set = function(self)
  return (self.value & self.WEDNESDAY) ~= 0
end
 
--- @function DayOfWeek:set_wednesday
--- Set the value of the bit in the WEDNESDAY field to 1
DayOfWeek.set_wednesday = function(self)
  if self.value ~= nil then
    self.value = self.value | self.WEDNESDAY
  else
    self.value = self.WEDNESDAY
  end
end

--- @function DayOfWeek:unset_wednesday
--- Set the value of the bits in the WEDNESDAY field to 0
DayOfWeek.unset_wednesday = function(self)
  self.value = self.value & (~self.WEDNESDAY & self.BASE_MASK)
end
--- @function DayOfWeek:is_thursday_set
--- @return boolean True if the value of THURSDAY is non-zero
DayOfWeek.is_thursday_set = function(self)
  return (self.value & self.THURSDAY) ~= 0
end
 
--- @function DayOfWeek:set_thursday
--- Set the value of the bit in the THURSDAY field to 1
DayOfWeek.set_thursday = function(self)
  if self.value ~= nil then
    self.value = self.value | self.THURSDAY
  else
    self.value = self.THURSDAY
  end
end

--- @function DayOfWeek:unset_thursday
--- Set the value of the bits in the THURSDAY field to 0
DayOfWeek.unset_thursday = function(self)
  self.value = self.value & (~self.THURSDAY & self.BASE_MASK)
end
--- @function DayOfWeek:is_friday_set
--- @return boolean True if the value of FRIDAY is non-zero
DayOfWeek.is_friday_set = function(self)
  return (self.value & self.FRIDAY) ~= 0
end
 
--- @function DayOfWeek:set_friday
--- Set the value of the bit in the FRIDAY field to 1
DayOfWeek.set_friday = function(self)
  if self.value ~= nil then
    self.value = self.value | self.FRIDAY
  else
    self.value = self.FRIDAY
  end
end

--- @function DayOfWeek:unset_friday
--- Set the value of the bits in the FRIDAY field to 0
DayOfWeek.unset_friday = function(self)
  self.value = self.value & (~self.FRIDAY & self.BASE_MASK)
end
--- @function DayOfWeek:is_saturday_set
--- @return boolean True if the value of SATURDAY is non-zero
DayOfWeek.is_saturday_set = function(self)
  return (self.value & self.SATURDAY) ~= 0
end
 
--- @function DayOfWeek:set_saturday
--- Set the value of the bit in the SATURDAY field to 1
DayOfWeek.set_saturday = function(self)
  if self.value ~= nil then
    self.value = self.value | self.SATURDAY
  else
    self.value = self.SATURDAY
  end
end

--- @function DayOfWeek:unset_saturday
--- Set the value of the bits in the SATURDAY field to 0
DayOfWeek.unset_saturday = function(self)
  self.value = self.value & (~self.SATURDAY & self.BASE_MASK)
end
--- @function DayOfWeek:is_away_or_vacation_set
--- @return boolean True if the value of AWAY_OR_VACATION is non-zero
DayOfWeek.is_away_or_vacation_set = function(self)
  return (self.value & self.AWAY_OR_VACATION) ~= 0
end
 
--- @function DayOfWeek:set_away_or_vacation
--- Set the value of the bit in the AWAY_OR_VACATION field to 1
DayOfWeek.set_away_or_vacation = function(self)
  if self.value ~= nil then
    self.value = self.value | self.AWAY_OR_VACATION
  else
    self.value = self.AWAY_OR_VACATION
  end
end

--- @function DayOfWeek:unset_away_or_vacation
--- Set the value of the bits in the AWAY_OR_VACATION field to 0
DayOfWeek.unset_away_or_vacation = function(self)
  self.value = self.value & (~self.AWAY_OR_VACATION & self.BASE_MASK)
end


DayOfWeek.mask_methods = {
  is_sunday_set = DayOfWeek.is_sunday_set,
  set_sunday = DayOfWeek.set_sunday,
  unset_sunday = DayOfWeek.unset_sunday,
  is_monday_set = DayOfWeek.is_monday_set,
  set_monday = DayOfWeek.set_monday,
  unset_monday = DayOfWeek.unset_monday,
  is_tuesday_set = DayOfWeek.is_tuesday_set,
  set_tuesday = DayOfWeek.set_tuesday,
  unset_tuesday = DayOfWeek.unset_tuesday,
  is_wednesday_set = DayOfWeek.is_wednesday_set,
  set_wednesday = DayOfWeek.set_wednesday,
  unset_wednesday = DayOfWeek.unset_wednesday,
  is_thursday_set = DayOfWeek.is_thursday_set,
  set_thursday = DayOfWeek.set_thursday,
  unset_thursday = DayOfWeek.unset_thursday,
  is_friday_set = DayOfWeek.is_friday_set,
  set_friday = DayOfWeek.set_friday,
  unset_friday = DayOfWeek.unset_friday,
  is_saturday_set = DayOfWeek.is_saturday_set,
  set_saturday = DayOfWeek.set_saturday,
  unset_saturday = DayOfWeek.unset_saturday,
  is_away_or_vacation_set = DayOfWeek.is_away_or_vacation_set,
  set_away_or_vacation = DayOfWeek.set_away_or_vacation,
  unset_away_or_vacation = DayOfWeek.unset_away_or_vacation,
}

DayOfWeek.augment_type = function(cls, val)
  setmetatable(val, new_mt)
end

setmetatable(DayOfWeek, new_mt)

return DayOfWeek

