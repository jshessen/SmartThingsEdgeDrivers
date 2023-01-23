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
--- @class st.matter.data_types.StructureABC: st.matter.data_types.DataType
---
--- Classes being created using the StructureABC class represent matter data types whose lua "value" is stored
--- as an array of matter data types each of which can be a separate type.
local StructureABC = {}

-- Element types that have value encoded in them
local NULL = 0x14
local BOOL_FALSE = 0x08
local BOOL_TRUE = 0x09

--- This function will create a new metatable with the appropriate functionality for a matter Structure
--- @param base table the base meta table, this will include the ID and NAME of the type being represented
--- @return table The meta table containing the functionality for this type class
function StructureABC.new_mt(base)
  local mt = {}
  mt.__index = base or {}
  mt.__index.is_fixed_length = false
  mt.__index.is_discrete = true
  mt.__index.deserialize = function(buf, include_control_octet, field_name)
    local TLVParser = require "st.matter.TLV.TLVParser"

    local o = {}
    setmetatable(o, mt)
    o.field_name = field_name
    if include_control_octet then
      local control_octet = buf:read_u8()
      local tag_control = control_octet & TLVParser.TAG_CONTROL_MASK
      local element_type = control_octet & TLVParser.TAG_ELEMENT_TYPE_MASK
      if (element_type ~= o.ID) and (element_type ~= o.ExtendedID) then
        error("Structure deserialization failed, incorrect element type in control octet")
      end
      if tag_control == TLVParser.FORM_CONT_SPEC_TAG.code then
        o.field_id = buf:read_u8()
      end
    end

    -- Each structure might have a collection of tag and a data pairs
    local i = 1
    o.num_elements = 0
    o.elements = {}

    local parseTLV = true
    while (parseTLV) do
      local control_octet = buf:peek_u8()
      local tag_control = control_octet & TLVParser.TAG_CONTROL_MASK
      local element_type = control_octet & TLVParser.TAG_ELEMENT_TYPE_MASK

      -- End of structure
      if control_octet == TLVParser.TAG_END_CONTAINER then
        -- consume the tag
        buf:read_u8()
        parseTLV = false
        break
      end
      table.insert(o.elements, TLVParser.decode_tlv_primititive(buf, element_type, true))
      o.num_elements = o.num_elements + 1
    end

    return o
  end
  mt.__index.serialize = function(elements, buffer, include_control_octet, tag)
    local data_types = require "st.matter.data_types"
    local TLVParser = require "st.matter.TLV.TLVParser"
    local buf_lib = require "st.buf"
    local buf = buffer or buf_lib.Writer()

    if include_control_octet then
      local tag_control = tag and 0x20 or 0x0 -- 0x20 is context specific tag
      local element_type = 0x15 --structure element type
      local control_octet = tag_control | element_type
      buf:write_u8(control_octet)
      if tag ~= nil then
        buf:write_u8(tag)
      end
    end

    for _, element in pairs(elements) do
      element:serialize(buf, true, element.field_id)
    end
    -- End of structure
    buf:write_u8(TLVParser.TAG_END_CONTAINER)
    return buf.buf
  end
  mt.__index.pretty_print = function(self)
    local out_str = (self.field_name or self.NAME) .. ": {"
    for k, v in pairs(self.elements) do
      out_str = out_str .. v:pretty_print() .. ", "
    end
    if self.num_elements > 0 then out_str = out_str:sub(1, -3) end
    out_str = out_str .. "}"
    return out_str
  end
  mt.__call = function(cls, val)
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

return StructureABC
