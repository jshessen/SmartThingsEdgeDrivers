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
local utils = require "st.zigbee.utils"

--- @class st.zigbee.data_types.DataABC: st.zigbee.data_types.DataType
---
--- Classes being created using the DataABC class represent Zigbee data types whose lua "value" is stored
--- as a generic byte string as the direct structure is not known or not storable in another way.  In
--- general these are the Zigbee data types Data8-Data64 represented by IDs 0x08-0x0F.  However, due to
--- limitations of lua numbers numeric types of 64 bit length use this base as well.
local DataABC = {}

--- This function will create a new metatable with the appropriate functionality for a Zigbee Data field
--- @param base table the base meta table, this will include the ID and NAME of the type being represented
--- @param byte_length number the length in bytes of this Data field
function DataABC.new_mt(base, byte_length)
  local mt = {}
  mt.__index = base or {}
  mt.__index.byte_length = byte_length
  mt.__index.is_fixed_length = true
  mt.__index.is_discrete = true
  mt.__index._serialize = function(s)
    return string.reverse(s.value)
  end
  mt.__index.get_length = function(self)
    return self.byte_length
  end
  mt.__index.deserialize = function(buf, field_name)
    local o = {}
    setmetatable(o, mt)
    o.byte_length = byte_length
    local read_bytes = buf:read_bytes(byte_length)
    o.value = string.reverse(read_bytes)
    o.field_name = field_name
    return o
  end
  mt.__index.pretty_print = function(self)
    if self.value == nil then
      return "Uninitialized " .. self.NAME
    end
    return string.format("%s: %s", self.field_name or self.NAME, utils.pretty_print_hex_str(self.value))
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
  mt.__tostring = function(self)
    return self:pretty_print()
  end
  return mt
end

return DataABC
