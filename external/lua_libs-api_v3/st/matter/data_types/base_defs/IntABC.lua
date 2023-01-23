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
--- @class st.matter.data_types.IntABC: st.matter.data_types.DataType
---
--- Classes being created using the IntABC class represent Matter data types whose lua "value" is stored
----- as a signed number.  In general these are the Matter data types Int8-Int56 represented by IDs 0x28-0x2E.
----- Int64 has to be treated differently due to lua limitations.
local IntABC = {}

--- This function will create a new metatable with the appropriate functionality for a Matter Int
--- @param base table the base meta table, this will include the ID and NAME of the type being represented
--- @param byte_length number the length in bytes of this Int
function IntABC.new_mt(base, byte_length)
  local mt = {}
  mt.__index = base or {}
  mt.__index.byte_length = byte_length
  mt.__index.is_fixed_length = true
  mt.__index.is_discrete = false
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
      if (element_type ~= mt.__index.ID) then
        read_type_length = data_types.get_subtype_length(o.SUBTYPES, element_type)
        if read_type_length == nil then
          error("Int deserialization failed, incorrect element type in control octet")
        end
      end
      if tag_control == TLVParser.FORM_CONT_SPEC_TAG.code then
        o.field_id = buf:read_u8()
      end
    end

    o.field_name = field_name
    o.value = buf:read_int(read_type_length, true, true)
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
    buf:write_int(self.value, self.byte_length, true, true)
    return buf.buf
  end
  mt.__index.pretty_print = function(self)
    return string.format("%s: %d", self.field_name or self.NAME, self.value)
  end
  mt.__call = function(orig, val)
    if type(val) ~= "number" or val ~= math.floor(val) then
      error(string.format("%s value must be an integer", orig.NAME), 2)
    elseif val >= (1 << ((byte_length * 8) - 1)) then
      error(string.format("%s too large for type", orig.NAME), 2)
    elseif val < -1 * (1 << ((byte_length * 8) - 1)) then
      error(string.format("%svalue too negative for type", orig.NAME), 2)
    end
    local o = {}
    setmetatable(o, mt)
    o.value = val
    return o
  end
  mt.__tostring = function(self) return self:pretty_print() end
  return mt
end

return IntABC
