-- Copyright 2022 SmartThings
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
local st_utils = require "st.utils"

--- @class st.matter.data_types.UintABC: st.matter.data_types.DataType
---
--- Classes being created using the UintABC class represent Matter data types whose lua "value" is stored
--- as an unsigned number.  In general these are the Matter data types Uint8-Uint56 represented by IDs 0x20-0x26.
--- Uint64 has to be treated differently due to lua limitations.  In addition there are several other ID types
--- that derive their behavior from Uint as well.
local UintABC = {}

--- This function will create a new metatable with the appropriate functionality for a Matter Uint
--- @param base table the base meta table, this will include the ID and NAME of the type being represented
--- @param byte_length number the length in bytes of this Uint
function UintABC.new_mt(base, byte_length)
  local mt = {}
  mt.__index = base
  mt.__index.byte_length = byte_length
  mt.__index.is_fixed_length = true
  if base.is_discrete == nil then mt.__index.is_discrete = false end
  mt.__index._serialize = function(s) return nil end
  mt.__index.get_length = function(self) return self.byte_length end
  mt.__index.deserialize = function(buf, include_control_octet, field_name)
    local TLVParser = require "st.matter.TLV.TLVParser"
    local read_type_length = byte_length
    local data_types = require "st.matter.data_types"

    local o = {}
    setmetatable(o, mt)

    if include_control_octet then
      local control_octet = buf:read_u8()
      local tag_control = control_octet & TLVParser.TAG_CONTROL_MASK
      local element_type = control_octet & TLVParser.TAG_ELEMENT_TYPE_MASK
      if (element_type ~= o.ID) then
        read_type_length = data_types.get_subtype_length(o.SUBTYPES, element_type)
        if read_type_length == nil then
          error("Uint deserialization failed, incorrect element type in control octet")
        end
      end
      if tag_control == TLVParser.FORM_CONT_SPEC_TAG.code then
        o.field_id = buf:read_u8()
      end
    end

    o.field_name = field_name
    o.value = buf:read_int(read_type_length, false, true)
    return o
  end
  mt.__index.serialize = function(self, buf, include_control_octet, tag)
    if include_control_octet then
      local tag_control = tag and 0x20 or 0x0 -- 0x20 is context specific tag
      local element_type = self.ID
      local control_octet = tag_control | element_type
      buf:write_u8(control_octet)
      if tag ~= nil then
        buf:write_u8(tag)
      end
    end
    buf:write_int(self.value, self.byte_length, false, true)
    return buf.buf
  end
  mt.__index.pretty_print = function(self)
    local pattern = ">I" .. self.byte_length
    return string.format(
             "%s: 0x%s", self.field_name or self.NAME,
               st_utils.get_print_safe_string(string.pack(pattern, self.value))
           )
  end
  mt.__index.check_if_valid = function(self, int_val)
    if type(int_val) ~= "number" or int_val ~= math.floor(int_val) then
      error(string.format("%s value must be an integer", self.NAME), 2)
    elseif int_val >= (1 << (byte_length * 8)) then
      error(string.format("%s too large for type", self.NAME), 2)
    elseif int_val < 0 then
      error(string.format("%s value must be positive", self.NAME), 2)
    end
  end
  mt.__newindex = function(self, k, v)
    if k == "value" then
      self:check_if_valid(v)
      rawset(self, k, v)
    else
      rawset(self, k, v)
    end
  end
  mt.__call = function(orig, int_val)
    local o = {}
    setmetatable(o, mt)
    o.value = int_val
    return o
  end
  mt.__tostring = function(self) return self:pretty_print() end
  return mt
end

return UintABC
