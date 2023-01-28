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
--- @class st.matter.data_types.BooleanABC: st.matter.data_types.DataType
---
--- Classes being created using the BooleanABC class represent Matter data types whose lua "value" is stored
--- as a boolean.
local BooleanABC = {}

--- This function will create a new metatable with the appropriate functionality for a Matter Boolean
--- @param base table the base meta table, this will include the ID and NAME of the type being represented
--- @return table The meta table containing the functionality for this type class
function BooleanABC.new_mt(base)
  local mt = {}
  mt.__index = base or {}
  mt.__index.is_fixed_length = true
  mt.__index.is_discrete = true
  mt.__index._serialize = function(s) return nil end
  mt.__index.get_length = function(self) return 1 end
  mt.__index.deserialize = function(buf, include_control_octet, field_name)
    local TLVParser = require "st.matter.TLV.TLVParser"
    local o = {}
    setmetatable(o, mt)

    if include_control_octet then
      local control_octet = buf:read_u8()
      local tag_control = control_octet & TLVParser.TAG_CONTROL_MASK
      local element_type = control_octet & TLVParser.TAG_ELEMENT_TYPE_MASK
      if element_type == o.ID then
        o.value = false
      elseif element_type == o.ExtendedID then
        o.value = true
      else
        error("Boolean deserialization failed, incorrect element type in control octet")
      end
      if tag_control == TLVParser.FORM_CONT_SPEC_TAG.code then
        o.field_id = buf:read_u8()
      end
    else
      error("Boolean type must include_control_octet to deserialize")
    end
    o.field_name = field_name
    return o
  end
  mt.__index.serialize = function(self, buf, include_control_octet, tag)
    if include_control_octet then
      local tag_control = tag and 0x20 or 0x0 -- context specific tag
      local element_type
      if self.value then
        element_type = self.ExtendedID
      else
        element_type = self.ID
      end
      local control_octet = tag_control | element_type
      buf:write_u8(control_octet)
      if tag ~= nil then
        buf:write_u8(tag)
      end
    else
      error("Must include control octet while seriailzing Boolean")
    end

    return buf.buf
  end
  mt.__index.pretty_print = function(self)
    return string.format("%s: %s", self.field_name or self.NAME, self.value and "true" or "false")
  end
  mt.__call = function(orig, val)
    if type(val) ~= "boolean" then
      error(string.format("%s value must be type boolean", orig.NAME), 2)
    end
    local o = {}
    setmetatable(o, mt)
    o.value = val
    return o
  end
  mt.__tostring = function(self) return self:pretty_print() end
  return mt
end

return BooleanABC
