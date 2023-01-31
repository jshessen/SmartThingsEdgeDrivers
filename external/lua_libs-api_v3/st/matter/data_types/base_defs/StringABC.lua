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
local log = require "log"

--- @class st.matter.data_types.StringABC: st.matter.data_types.DataType
---
--- Classes being created using the StringABC class represent Matter data types whose lua "value" is stored
--- as a string.  These are the Matter data types UTF-8 String, 1-octet length, UTF-8 String, 2-octet length,
--- UTF-8 String, 4-octet length, and UTF-8 String, 8-octet length.
local StringABC = {}

--- This function will create a new metatable with the appropriate functionality for a Matter String
--- @param base table the base meta table, this will include the ID and NAME of the type being represented
--- @param length_byte_length number the length of the encoded byte_length of this String
function StringABC.new_mt(base, length_byte_length)
  local mt = {}
  mt.__index = base or {}
  mt.__index.length_byte_length = length_byte_length
  mt.__index.is_fixed_length = false
  mt.__index.is_discrete = true
  mt.__index._serialize = function(s) return nil end
  mt.__index.get_length = function(self) return self.byte_length + self.length_byte_length end
  mt.__index.deserialize = function(buf, include_control_octet, field_name)
    local TLVParser = require "st.matter.TLV.TLVParser"
    local o = {}
    setmetatable(o, mt)

    if include_control_octet then
      local control_octet = buf:read_u8()
      local tag_control = control_octet & TLVParser.TAG_CONTROL_MASK
      local element_type = control_octet & TLVParser.TAG_ELEMENT_TYPE_MASK
      if (element_type ~= mt.__index.ID) and (element_type ~= mt.__index.ExtendedID) then
        error("String deserialization failed, incorrect element type in control octet")
      end
      if tag_control == TLVParser.FORM_CONT_SPEC_TAG.code then
        o.field_id = buf:read_u8()
      end
    end

    o.byte_length = buf:read_int(length_byte_length, false, true)
    local status, val = pcall(buf.read_bytes, buf, o.byte_length)
    if status then
      o.value = val
    elseif string.find(val, ": buffer too short") ~= nil then
      o.value = buf:read_bytes(buf:remain())
    else
      error(val)
    end
    o.field_name = field_name
    if #o.value < o.byte_length then
      log.warn(
        string.format(
          "Matter string reported length %d but was actually only %d bytes long", o.byte_length,
            #o.value
        )
      )
      o.byte_value = #o.value
    end
    return o
  end
  mt.__index.serialize = function(self, buf, include_control_octet, tag)
    if include_control_octet then
      local tag_control = tag and 0x20 or 0x0 --0x20 is context specific tag
      local element_type = self.ID
      local control_octet = tag_control | element_type
      buf:write_u8(control_octet)
      if tag ~= nil then
        buf:write_u8(tag)
      end
    end
    buf:write_int(self.byte_length, self.length_byte_length, false, true)
    buf:write_bytes(self.value)
    return buf.buf
  end
  mt.__index.pretty_print = function(self)
    return string.format(
             "%s: \"%s\"", self.field_name or self.NAME, st_utils.get_print_safe_string(self.value)
           )
  end
  mt.__index.check_if_valid = function(self, value)
    if type(value) ~= "string" then
      error(string.format("%s value must be a string", self.NAME), 2)
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
  mt.__call = function(orig, value)
    local o = {}
    setmetatable(o, mt)
    o.byte_length = #value
    o.value = value
    return o
  end
  mt.__tostring = function(self) return self:pretty_print() end
  return mt
end

return StringABC
