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
local utils = require "st.utils"

--- @class st.matter.data_types.DataABC: st.matter.data_types.DataType
---
--- Classes being created using the DataABC class represent Matter data types whose lua "value" is stored
--- as a generic byte string as the direct structure is not known or not storable in another way.  In
--- general these are the Matter data types Data8-Data64 represented by IDs 0x08-0x0F.  However, due to
--- limitations of lua numbers, numeric types of 64 bit length use this base as well.
local DataABC = {}

--- This function will create a new metatable with the appropriate functionality for a Matter Data field
--- @param base table the base meta table, this will include the ID and NAME of the type being represented
--- @param byte_length number the length in bytes of this Data field
function DataABC.new_mt(base, byte_length)
  local mt = {}

  -- Utility function returning an int64 value
  local i_table = base or {}
  mt.i_table = i_table
  mt.__index = function(self, k)
    if mt.i_table[k] ~= nil then
      return mt.i_table[k]
    elseif k == "value" then
      return mt.i_table["get_i64_val"](self)
    end
  end
  i_table.get_i64_val = function(self)
    return tonumber(
             "0x"
               .. string.format(
                 string.rep("%02X", #self.value), string.byte(self.value, 1, #self.value)
               )
           )
  end

  mt.__index = base or {}
  mt.__index.byte_length = byte_length
  mt.__index.is_fixed_length = true
  mt.__index.is_discrete = true
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
          error("Data deserialization failed, incorrect element type in control octet")
        end
      end
      if tag_control == TLVParser.FORM_CONT_SPEC_TAG.code then
        o.field_id = buf:read_u8()
      end
    end

    o.field_name = field_name
    local read_bytes = buf:read_bytes(read_type_length)
    o.value = string.reverse(read_bytes)
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
    return string.format(
             "%s: %s", self.field_name or self.NAME, utils.get_print_safe_string(self.value)
           )
  end
  mt.__index.check_if_valid = function(self, data)
    if type(data) ~= "string" then
      error(string.format("%s values must be string bytes", self.NAME), 2)
    elseif #data > byte_length then
      error(string.format("%s value to large for type", self.NAME), 2)
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
  mt.__call = function(orig, data)
    local o = {}
    setmetatable(o, mt)
    o.value = data
    return o
  end
  mt.__tostring = function(self) return self:pretty_print() end
  return mt
end

return DataABC
