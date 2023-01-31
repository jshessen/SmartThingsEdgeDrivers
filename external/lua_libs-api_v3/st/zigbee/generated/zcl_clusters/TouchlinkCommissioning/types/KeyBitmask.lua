local data_types = require "st.zigbee.data_types"
local BitmapABC = require "st.zigbee.data_types.base_defs.BitmapABC"

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

--- @class st.zigbee.zcl.clusters.TouchlinkCommissioning.types.KeyBitmask: st.zigbee.data_types.Bitmap16
--- @alias KeyBitmask
---
--- @field public byte_length number 2
--- @field public DEVELOPMENT_KEY number 1
--- @field public MASTER_KEY number 16
--- @field public CERTIFICATION_KEY number 32768
local KeyBitmask = {}
local new_mt = BitmapABC.new_mt({NAME = "KeyBitmask", ID = data_types.name_to_id_map["Bitmap16"]}, 2)
new_mt.__index.BASE_MASK         = 0xFFFF
new_mt.__index.DEVELOPMENT_KEY   = 0x0001
new_mt.__index.MASTER_KEY        = 0x0010
new_mt.__index.CERTIFICATION_KEY = 0x8000

--- @function KeyBitmask:is_development_key_set
--- @return boolean True if the value of DEVELOPMENT_KEY is non-zero
new_mt.__index.is_development_key_set = function(self)
  return (self.value & self.DEVELOPMENT_KEY) ~= 0
end
 
--- @function KeyBitmask:set_development_key
--- Set the value of the bit in the DEVELOPMENT_KEY field to 1
new_mt.__index.set_development_key = function(self)
  self.value = self.value | self.DEVELOPMENT_KEY
end

--- @function KeyBitmask:unset_development_key
--- Set the value of the bits in the DEVELOPMENT_KEY field to 0
new_mt.__index.unset_development_key = function(self)
  self.value = self.value & (~self.DEVELOPMENT_KEY & self.BASE_MASK)
end

--- @function KeyBitmask:is_master_key_set
--- @return boolean True if the value of MASTER_KEY is non-zero
new_mt.__index.is_master_key_set = function(self)
  return (self.value & self.MASTER_KEY) ~= 0
end
 
--- @function KeyBitmask:set_master_key
--- Set the value of the bit in the MASTER_KEY field to 1
new_mt.__index.set_master_key = function(self)
  self.value = self.value | self.MASTER_KEY
end

--- @function KeyBitmask:unset_master_key
--- Set the value of the bits in the MASTER_KEY field to 0
new_mt.__index.unset_master_key = function(self)
  self.value = self.value & (~self.MASTER_KEY & self.BASE_MASK)
end

--- @function KeyBitmask:is_certification_key_set
--- @return boolean True if the value of CERTIFICATION_KEY is non-zero
new_mt.__index.is_certification_key_set = function(self)
  return (self.value & self.CERTIFICATION_KEY) ~= 0
end
 
--- @function KeyBitmask:set_certification_key
--- Set the value of the bit in the CERTIFICATION_KEY field to 1
new_mt.__index.set_certification_key = function(self)
  self.value = self.value | self.CERTIFICATION_KEY
end

--- @function KeyBitmask:unset_certification_key
--- Set the value of the bits in the CERTIFICATION_KEY field to 0
new_mt.__index.unset_certification_key = function(self)
  self.value = self.value & (~self.CERTIFICATION_KEY & self.BASE_MASK)
end

setmetatable(KeyBitmask, new_mt)
return KeyBitmask