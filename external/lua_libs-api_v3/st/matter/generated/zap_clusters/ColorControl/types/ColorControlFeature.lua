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

--- @class st.matter.clusters.ColorControl.types.ColorControlFeature
--- @alias ColorControlFeature
---
--- @field public HUE_AND_SATURATION number 1
--- @field public ENHANCED_HUE number 2
--- @field public COLOR_LOOP number 4
--- @field public XY number 8
--- @field public COLOR_TEMPERATURE number 16

local ColorControlFeature = {}
local new_mt = UintABC.new_mt({NAME = "ColorControlFeature", ID = data_types.name_to_id_map["Uint32"]}, 4)

ColorControlFeature.BASE_MASK = 0xFFFF
ColorControlFeature.HUE_AND_SATURATION = 0x0001
ColorControlFeature.ENHANCED_HUE = 0x0002
ColorControlFeature.COLOR_LOOP = 0x0004
ColorControlFeature.XY = 0x0008
ColorControlFeature.COLOR_TEMPERATURE = 0x0010

ColorControlFeature.mask_fields = {
  BASE_MASK = 0xFFFF,
  HUE_AND_SATURATION = 0x0001,
  ENHANCED_HUE = 0x0002,
  COLOR_LOOP = 0x0004,
  XY = 0x0008,
  COLOR_TEMPERATURE = 0x0010,
}

--- @function ColorControlFeature:is_hue_and_saturation_set
--- @return boolean True if the value of HUE_AND_SATURATION is non-zero
ColorControlFeature.is_hue_and_saturation_set = function(self)
  return (self.value & self.HUE_AND_SATURATION) ~= 0
end
 
--- @function ColorControlFeature:set_hue_and_saturation
--- Set the value of the bit in the HUE_AND_SATURATION field to 1
ColorControlFeature.set_hue_and_saturation = function(self)
  if self.value ~= nil then
    self.value = self.value | self.HUE_AND_SATURATION
  else
    self.value = self.HUE_AND_SATURATION
  end
end

--- @function ColorControlFeature:unset_hue_and_saturation
--- Set the value of the bits in the HUE_AND_SATURATION field to 0
ColorControlFeature.unset_hue_and_saturation = function(self)
  self.value = self.value & (~self.HUE_AND_SATURATION & self.BASE_MASK)
end
--- @function ColorControlFeature:is_enhanced_hue_set
--- @return boolean True if the value of ENHANCED_HUE is non-zero
ColorControlFeature.is_enhanced_hue_set = function(self)
  return (self.value & self.ENHANCED_HUE) ~= 0
end
 
--- @function ColorControlFeature:set_enhanced_hue
--- Set the value of the bit in the ENHANCED_HUE field to 1
ColorControlFeature.set_enhanced_hue = function(self)
  if self.value ~= nil then
    self.value = self.value | self.ENHANCED_HUE
  else
    self.value = self.ENHANCED_HUE
  end
end

--- @function ColorControlFeature:unset_enhanced_hue
--- Set the value of the bits in the ENHANCED_HUE field to 0
ColorControlFeature.unset_enhanced_hue = function(self)
  self.value = self.value & (~self.ENHANCED_HUE & self.BASE_MASK)
end
--- @function ColorControlFeature:is_color_loop_set
--- @return boolean True if the value of COLOR_LOOP is non-zero
ColorControlFeature.is_color_loop_set = function(self)
  return (self.value & self.COLOR_LOOP) ~= 0
end
 
--- @function ColorControlFeature:set_color_loop
--- Set the value of the bit in the COLOR_LOOP field to 1
ColorControlFeature.set_color_loop = function(self)
  if self.value ~= nil then
    self.value = self.value | self.COLOR_LOOP
  else
    self.value = self.COLOR_LOOP
  end
end

--- @function ColorControlFeature:unset_color_loop
--- Set the value of the bits in the COLOR_LOOP field to 0
ColorControlFeature.unset_color_loop = function(self)
  self.value = self.value & (~self.COLOR_LOOP & self.BASE_MASK)
end
--- @function ColorControlFeature:is_xy_set
--- @return boolean True if the value of XY is non-zero
ColorControlFeature.is_xy_set = function(self)
  return (self.value & self.XY) ~= 0
end
 
--- @function ColorControlFeature:set_xy
--- Set the value of the bit in the XY field to 1
ColorControlFeature.set_xy = function(self)
  if self.value ~= nil then
    self.value = self.value | self.XY
  else
    self.value = self.XY
  end
end

--- @function ColorControlFeature:unset_xy
--- Set the value of the bits in the XY field to 0
ColorControlFeature.unset_xy = function(self)
  self.value = self.value & (~self.XY & self.BASE_MASK)
end
--- @function ColorControlFeature:is_color_temperature_set
--- @return boolean True if the value of COLOR_TEMPERATURE is non-zero
ColorControlFeature.is_color_temperature_set = function(self)
  return (self.value & self.COLOR_TEMPERATURE) ~= 0
end
 
--- @function ColorControlFeature:set_color_temperature
--- Set the value of the bit in the COLOR_TEMPERATURE field to 1
ColorControlFeature.set_color_temperature = function(self)
  if self.value ~= nil then
    self.value = self.value | self.COLOR_TEMPERATURE
  else
    self.value = self.COLOR_TEMPERATURE
  end
end

--- @function ColorControlFeature:unset_color_temperature
--- Set the value of the bits in the COLOR_TEMPERATURE field to 0
ColorControlFeature.unset_color_temperature = function(self)
  self.value = self.value & (~self.COLOR_TEMPERATURE & self.BASE_MASK)
end

function ColorControlFeature.bits_are_valid(feature)
  local max = 
    ColorControlFeature.HUE_AND_SATURATION | 
    ColorControlFeature.ENHANCED_HUE | 
    ColorControlFeature.COLOR_LOOP | 
    ColorControlFeature.XY | 
    ColorControlFeature.COLOR_TEMPERATURE
  if (feature <= max) and (feature >= 1) then
    return true
  else
    return false
  end
end

ColorControlFeature.mask_methods = {
  is_hue_and_saturation_set = ColorControlFeature.is_hue_and_saturation_set,
  set_hue_and_saturation = ColorControlFeature.set_hue_and_saturation,
  unset_hue_and_saturation = ColorControlFeature.unset_hue_and_saturation,
  is_enhanced_hue_set = ColorControlFeature.is_enhanced_hue_set,
  set_enhanced_hue = ColorControlFeature.set_enhanced_hue,
  unset_enhanced_hue = ColorControlFeature.unset_enhanced_hue,
  is_color_loop_set = ColorControlFeature.is_color_loop_set,
  set_color_loop = ColorControlFeature.set_color_loop,
  unset_color_loop = ColorControlFeature.unset_color_loop,
  is_xy_set = ColorControlFeature.is_xy_set,
  set_xy = ColorControlFeature.set_xy,
  unset_xy = ColorControlFeature.unset_xy,
  is_color_temperature_set = ColorControlFeature.is_color_temperature_set,
  set_color_temperature = ColorControlFeature.set_color_temperature,
  unset_color_temperature = ColorControlFeature.unset_color_temperature,
}

ColorControlFeature.augment_type = function(cls, val)
  setmetatable(val, new_mt)
end

setmetatable(ColorControlFeature, new_mt)

return ColorControlFeature

