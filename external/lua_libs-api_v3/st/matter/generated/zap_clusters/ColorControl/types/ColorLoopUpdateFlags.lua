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

--- @class st.matter.clusters.ColorControl.types.ColorLoopUpdateFlags
--- @alias ColorLoopUpdateFlags
---
--- @field public UPDATE_ACTION number 1
--- @field public UPDATE_DIRECTION number 2
--- @field public UPDATE_TIME number 4
--- @field public UPDATE_START_HUE number 8

local ColorLoopUpdateFlags = {}
local new_mt = UintABC.new_mt({NAME = "ColorLoopUpdateFlags", ID = data_types.name_to_id_map["Uint8"]}, 1)

ColorLoopUpdateFlags.BASE_MASK = 0xFFFF
ColorLoopUpdateFlags.UPDATE_ACTION = 0x0001
ColorLoopUpdateFlags.UPDATE_DIRECTION = 0x0002
ColorLoopUpdateFlags.UPDATE_TIME = 0x0004
ColorLoopUpdateFlags.UPDATE_START_HUE = 0x0008

ColorLoopUpdateFlags.mask_fields = {
  BASE_MASK = 0xFFFF,
  UPDATE_ACTION = 0x0001,
  UPDATE_DIRECTION = 0x0002,
  UPDATE_TIME = 0x0004,
  UPDATE_START_HUE = 0x0008,
}

--- @function ColorLoopUpdateFlags:is_update_action_set
--- @return boolean True if the value of UPDATE_ACTION is non-zero
ColorLoopUpdateFlags.is_update_action_set = function(self)
  return (self.value & self.UPDATE_ACTION) ~= 0
end
 
--- @function ColorLoopUpdateFlags:set_update_action
--- Set the value of the bit in the UPDATE_ACTION field to 1
ColorLoopUpdateFlags.set_update_action = function(self)
  if self.value ~= nil then
    self.value = self.value | self.UPDATE_ACTION
  else
    self.value = self.UPDATE_ACTION
  end
end

--- @function ColorLoopUpdateFlags:unset_update_action
--- Set the value of the bits in the UPDATE_ACTION field to 0
ColorLoopUpdateFlags.unset_update_action = function(self)
  self.value = self.value & (~self.UPDATE_ACTION & self.BASE_MASK)
end
--- @function ColorLoopUpdateFlags:is_update_direction_set
--- @return boolean True if the value of UPDATE_DIRECTION is non-zero
ColorLoopUpdateFlags.is_update_direction_set = function(self)
  return (self.value & self.UPDATE_DIRECTION) ~= 0
end
 
--- @function ColorLoopUpdateFlags:set_update_direction
--- Set the value of the bit in the UPDATE_DIRECTION field to 1
ColorLoopUpdateFlags.set_update_direction = function(self)
  if self.value ~= nil then
    self.value = self.value | self.UPDATE_DIRECTION
  else
    self.value = self.UPDATE_DIRECTION
  end
end

--- @function ColorLoopUpdateFlags:unset_update_direction
--- Set the value of the bits in the UPDATE_DIRECTION field to 0
ColorLoopUpdateFlags.unset_update_direction = function(self)
  self.value = self.value & (~self.UPDATE_DIRECTION & self.BASE_MASK)
end
--- @function ColorLoopUpdateFlags:is_update_time_set
--- @return boolean True if the value of UPDATE_TIME is non-zero
ColorLoopUpdateFlags.is_update_time_set = function(self)
  return (self.value & self.UPDATE_TIME) ~= 0
end
 
--- @function ColorLoopUpdateFlags:set_update_time
--- Set the value of the bit in the UPDATE_TIME field to 1
ColorLoopUpdateFlags.set_update_time = function(self)
  if self.value ~= nil then
    self.value = self.value | self.UPDATE_TIME
  else
    self.value = self.UPDATE_TIME
  end
end

--- @function ColorLoopUpdateFlags:unset_update_time
--- Set the value of the bits in the UPDATE_TIME field to 0
ColorLoopUpdateFlags.unset_update_time = function(self)
  self.value = self.value & (~self.UPDATE_TIME & self.BASE_MASK)
end
--- @function ColorLoopUpdateFlags:is_update_start_hue_set
--- @return boolean True if the value of UPDATE_START_HUE is non-zero
ColorLoopUpdateFlags.is_update_start_hue_set = function(self)
  return (self.value & self.UPDATE_START_HUE) ~= 0
end
 
--- @function ColorLoopUpdateFlags:set_update_start_hue
--- Set the value of the bit in the UPDATE_START_HUE field to 1
ColorLoopUpdateFlags.set_update_start_hue = function(self)
  if self.value ~= nil then
    self.value = self.value | self.UPDATE_START_HUE
  else
    self.value = self.UPDATE_START_HUE
  end
end

--- @function ColorLoopUpdateFlags:unset_update_start_hue
--- Set the value of the bits in the UPDATE_START_HUE field to 0
ColorLoopUpdateFlags.unset_update_start_hue = function(self)
  self.value = self.value & (~self.UPDATE_START_HUE & self.BASE_MASK)
end


ColorLoopUpdateFlags.mask_methods = {
  is_update_action_set = ColorLoopUpdateFlags.is_update_action_set,
  set_update_action = ColorLoopUpdateFlags.set_update_action,
  unset_update_action = ColorLoopUpdateFlags.unset_update_action,
  is_update_direction_set = ColorLoopUpdateFlags.is_update_direction_set,
  set_update_direction = ColorLoopUpdateFlags.set_update_direction,
  unset_update_direction = ColorLoopUpdateFlags.unset_update_direction,
  is_update_time_set = ColorLoopUpdateFlags.is_update_time_set,
  set_update_time = ColorLoopUpdateFlags.set_update_time,
  unset_update_time = ColorLoopUpdateFlags.unset_update_time,
  is_update_start_hue_set = ColorLoopUpdateFlags.is_update_start_hue_set,
  set_update_start_hue = ColorLoopUpdateFlags.set_update_start_hue,
  unset_update_start_hue = ColorLoopUpdateFlags.unset_update_start_hue,
}

ColorLoopUpdateFlags.augment_type = function(cls, val)
  setmetatable(val, new_mt)
end

setmetatable(ColorLoopUpdateFlags, new_mt)

return ColorLoopUpdateFlags
