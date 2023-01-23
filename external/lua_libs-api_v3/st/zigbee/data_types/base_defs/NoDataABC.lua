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
--- @class st.zigbee.data_types.NoDataABC: st.zigbee.data_types.DataType
---
--- Classes being created using the NoDataABC class represent Zigbee data types that have no body
local NoDataABC = {}

--- This function will create a new metatable with the appropriate functionality for a Zigbee NoData
--- @param base table the base meta table, this will include the ID and NAME of the type being represented
--- @return table The meta table containing the functionality for this type class
function NoDataABC.new_mt(base)
  local mt = {}
  mt.__index = base or {}
  mt.__index.is_discrete = true
  mt.__index.is_fixed_length = true
  mt.__index.deserialize = function(buf, field_name)
    local o = {}
    o.field_name = field_name
    setmetatable(o, mt)
    return o
  end
  mt.__index._serialize = function(self)
    return ""
  end
  mt.__index.get_length = function(self)
    return 0
  end
  mt.__index.pretty_print = function(self)
    return "<" .. (self.field_name or self.NAME) .. ">"
  end
  mt.__call = function(orig)
    local o = {}
    setmetatable(o, mt)
    return o
  end
  mt.__tostring = function(self)
    return self:pretty_print()
  end
  return mt
end

return NoDataABC
