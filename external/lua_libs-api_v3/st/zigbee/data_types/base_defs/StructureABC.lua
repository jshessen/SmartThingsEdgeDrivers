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

--- @class st.zigbee.data_types.StructureABC: st.zigbee.data_types.DataType
---
--- Classes being created using the StructureABC class represent Zigbee data types whose lua "value" is stored
--- as an array of Zigbee data types each of which can be a separate type.
local StructureABC = {}

--- This function will create a new metatable with the appropriate functionality for a Zigbee Structure
--- @param base table the base meta table, this will include the ID and NAME of the type being represented
--- @return table The meta table containing the functionality for this type class
function StructureABC.new_mt(base)
  local mt = {}
  mt.__index = base or {}
  mt.__index.is_fixed_length = false
  mt.__index.is_discrete = true
  mt.__index._serialize = function(self)
    local out_string = self.num_elements:_serialize()
    for i = 1, self.num_elements.value, 1 do
      out_string = out_string .. self.elements[i].data_type:_serialize() .. self.elements[i].data:_serialize()
    end
    return out_string
  end
  mt.__index.get_length = function(self)
    local total_length = self.num_elements:get_length()
    for i = 1, self.num_elements.value, 1 do
      total_length = total_length + self.elements[i].data_type:get_length() + self.elements[i].data:get_length()
    end
    return total_length
  end
  mt.__index.deserialize = function(buf, field_name)
    local o = {}
    setmetatable(o, mt)
    o.field_name = field_name
    o.num_elements = data_types.Uint16.deserialize(buf)
    o.elements = {}
    for i = 1, o.num_elements.value, 1 do
      o.elements[i] = {}
      o.elements[i].data_type = data_types.Uint8.deserialize(buf)
      o.elements[i].data = data_types.parse_data_type(o.elements[i].data_type.value, buf)
    end
    return o
  end
  mt.__index.pretty_print = function(self)
    if self.elements == nil then
      return "Uninitialized " .. self.NAME
    end
    local out_str = (self.field_name or self.NAME) .. ": ["
    for _, v in ipairs(self.elements) do
      out_str = out_str .. v.data:pretty_print() .. ", "
    end
    if self.num_elements.value > 0 then
      out_str = out_str:sub(1, -3) -- remove trailing comma
    end
    out_str = out_str .. "]"
    return out_str
  end
  mt.__call = function(orig, data_vals)
    local o = {}
    setmetatable(o, mt)
    o.elements = {}
    for i, v in ipairs(data_vals) do
      o.elements[i] = {}
      o.elements[i].data_type = data_types.ZigbeeDataType(v.ID)
      o.elements[i].data = v
    end
    o.num_elements = data_types.Uint16(#data_vals)
    return o
  end
  mt.__tostring = function(self)
    return self:pretty_print()
  end
  return mt
end

return StructureABC
