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
--- @class st.matter.data_types.ArrayABC: st.matter.data_types.DataType
---
--- Classes being created using the ArrayABC class represent Matter data types whose lua "value" is stored
--- as a Lua-native 1-indexed table of Matter data types all of the same type.
local ArrayABC = {}

--- This function will create a new metatable with the appropriate functionality for a Matter Array
--- @param base table the base meta table, this will include the ID and NAME of the type being represented
--- @return table The meta table containing the functionality for this type class
function ArrayABC.new_mt(base)
  local mt = {}
  mt.__index = base or {}
  mt.__index.is_fixed_length = false
  mt.__index.is_discrete = true
  mt.__index.deserialize = function(buf, include_control_octet, field_name)
    local TLVParser = require "st.matter.TLV.TLVParser"

    local o = {}
    setmetatable(o, mt)
    if include_control_octet then
      local control_octet = buf:read_u8()
      local tag_control = control_octet & TLVParser.TAG_CONTROL_MASK
      local element_type = control_octet & TLVParser.TAG_ELEMENT_TYPE_MASK
      if (element_type ~= mt.__index.ID) then
        error("Array deserialization failed, incorrect element type in control octet")
      end
      if tag_control == TLVParser.FORM_CONT_SPEC_TAG.code then
        o.field_id = buf:read_u8()
      end
    end

    o.num_elements = 0
    o.elements = {}
    o.field_name = field_name
    local parseTLV = true
    while (parseTLV) do
      local control_octet = buf:peek_u8()
      local tag_control = control_octet & TLVParser.TAG_CONTROL_MASK

      if control_octet == TLVParser.TAG_END_CONTAINER then
        -- consume the tag
        buf:read_u8()
        parseTLV = false
        break
      end

      if tag_control ~= TLVParser.FORM_ANONYMOUS_TAG.code then
        error("Only anonymous tag forms allowed in an array")
      end
      table.insert(o.elements, TLVParser.decode_tlv_primititive(buf, control_octet, true))
      o.num_elements = o.num_elements + 1
    end

    return o
  end
  mt.__index.serialize = function(self, buffer, include_control_octet, tag)
    local buf_lib = require "st.buf"
    local buf = buffer or buf_lib.Writer()
    if include_control_octet then
      local tag_control = tag and 0x20 or 0x0 --0x20 is context specific tag
      local element_type = self.ID
      local control_octet = tag_control | element_type
      buf:write_u8(control_octet)
      if tag ~= nil then
        buf:write_u8(tag)
      end
    end
    for _, elem in ipairs(self.elements) do
      elem:serialize(buf, true) --anonymous tag control octet
    end
    buf:write_u8(0x18) --end of container
    return buf.buf
  end
  mt.__index.pretty_print = function(self)
    local out_str = (self.field_name or self.NAME) .. ": ["
    for _, v in ipairs(self.elements) do out_str = out_str .. v:pretty_print() .. ", " end
    if #self.elements > 0 then out_str = out_str:sub(1, -3) end
    out_str = out_str .. "]"
    return out_str
  end
  mt.__call = function(orig, val)
    local o = {}
    o.num_elements = 0
    setmetatable(o, mt)
    o.elements = val
    o.num_elements = #val
    return o
  end
  mt.__tostring = function(self) return self:pretty_print() end
  return mt
end

return ArrayABC
