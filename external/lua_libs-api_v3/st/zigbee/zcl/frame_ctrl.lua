-- Copyright 2021 SmartThings
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
local data_types = require "st.zigbee.data_types"
local BitmapABC = require "st.zigbee.data_types.base_defs.BitmapABC"

--- @class st.zigbee.zcl.FrameCtrl: BitmapABC
--- @field public BASE_MASK number 0xFF Mask for the whole field
--- @field public FRAME_TYPE number 0x03 Mask to get the frame type value
--- @field public MFG_SPECIFIC number 0x04 Mask to get the mfg specific value
--- @field public DIRECTION number 0x08 Mask to get the direction value
--- @field public DISABLE_DEFAULT_RESPONSE number 0x10 Mask to get the disable default response value
--- @field public DIRECTION_CLIENT number 0x08 The value for direction client
--- @field public DIRECTION_SERVER number 0x00 The value for direction server
--- @field public NAME string "ZclFrameCtrl"
--- @field public ID number 0x18
local FrameCtrl = {}

local new_mt = BitmapABC.new_mt({ NAME = "ZclFrameCtrl", id = data_types.name_to_id_map["Bitmap8"] }, 1)
new_mt.__index.BASE_MASK                = 0xFF
new_mt.__index.FRAME_TYPE               = 0x03
new_mt.__index.MFG_SPECIFIC             = 0x04
new_mt.__index.DIRECTION                = 0x08
new_mt.__index.DISABLE_DEFAULT_RESPONSE = 0x10

new_mt.__index.DIRECTION_CLIENT         = 0x08
new_mt.__index.DIRECTION_SERVER         = 0x00

--- @function FrameCtrl:is_frame_type_set
--- @return boolean true if frame type is non-zero
new_mt.__index.is_frame_type_set = function(self)
  return (self.value & self.FRAME_TYPE) ~= 0
end

--- @function FrameCtrl:set_frame_type
--- @param field_val number the new value for the frame type bit field
new_mt.__index.set_frame_type = function(self, field_val)
  if ((field_val & ~(self.FRAME_TYPE >> 0)) ~= 0) then
    error("value too large for frame type", 2)
  end
  self.value = self.value | (field_val << 0)
end

--- @function FrameCtrl:get_frame_type
--- @return number the value for the frame type bit field
new_mt.__index.get_frame_type = function(self)
  return ((self.value & self.FRAME_TYPE)) >> 0
end

--- @function FrameCtrl:unset_frame_type
--- set the frame type bit field to 0
new_mt.__index.unset_frame_type = function(self)
  self.value = self.value & (self.FRAME_TYPE ~ self.BASE_MASK)
end

--- @function FrameCtrl:is_cluster_specific_set
--- @return boolean true if frame type is cluster specific
new_mt.__index.is_cluster_specific_set = function(self)
  return (self:get_frame_type() & 0x01) ~= 0
end

--- @function FrameCtrl:set_cluster_specific
--- sets this frame control field to be cluster specific
new_mt.__index.set_cluster_specific = function(self)
  self.value = self.value | 0x01
end

--- @function FrameCtrl:is_mfg_specific_set
--- @return boolean true if this frame control is mfg specific
new_mt.__index.is_mfg_specific_set = function(self)
  return (self.value & self.MFG_SPECIFIC) ~= 0
end

--- @function FrameCtrl:set_mfg_specific
--- sets the mfg specific field to true
new_mt.__index.set_mfg_specific = function(self)
  self.value = self.value | self.MFG_SPECIFIC
end

--- @function FrameCtrl:unset_mfg_specific
--- set the mfg specific bit field to false
new_mt.__index.unset_mfg_specific = function(self)
  self.value = self.value & (self.MFG_SPECIFIC ~ self.BASE_MASK)
end

--- @function FrameCtrl:is_direction_set
--- @return boolean true if this frame control is direction client
new_mt.__index.is_direction_set = function(self)
  return (self.value & self.DIRECTION) ~= 0
end

--- @function FrameCtrl:get_direction
--- @return number the direction of this frame control
new_mt.__index.get_direction = function(self)
  return (self.value & self.DIRECTION) >> 3
end

--- @function FrameCtrl:set_direction
--- sets the value of the direction bit field to 1
new_mt.__index.set_direction = function(self)
  self.value = self.value | self.DIRECTION
end

--- @function FrameCtrl:set_direction_server
--- sets the value of the direction bit field to 0 (direction to server)
new_mt.__index.set_direction_server = function(self)
  self:unset_direction()
end

--- @function FrameCtrl:set_direction_client
--- sets the value of the direction bit field to 1 (direction to client)
new_mt.__index.set_direction_client = function(self)
  self:set_direction()
end

--- @function FrameCtrl:unset_direction
--- sets the value of the direction bit field to 0
new_mt.__index.unset_direction = function(self)
  self.value = self.value & (self.DIRECTION ~ self.BASE_MASK)
end

--- @function FrameCtrl:is_disable_default_response_set
--- @return boolean true if this frame control has default responses disabled
new_mt.__index.is_disable_default_response_set = function(self)
  return (self.value & self.DISABLE_DEFAULT_RESPONSE) ~= 0
end

--- @function FrameCtrl:set_disable_default_response
--- sets the default responses to be disabled
new_mt.__index.set_disable_default_response = function(self)
  self.value = self.value | self.DISABLE_DEFAULT_RESPONSE
end

--- @function FrameCtrl:unset_disable_default_response
--- sets the default responses to be enabled
new_mt.__index.unset_disable_default_response = function(self)
  self.value = self.value & (self.DISABLE_DEFAULT_RESPONSE ~ self.BASE_MASK)
end

setmetatable(FrameCtrl, new_mt)
return FrameCtrl
