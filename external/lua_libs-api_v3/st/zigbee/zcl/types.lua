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
local types = {
}

local types_mt = {}
types_mt.__type_cache = {}
types_mt.__index = function(self, key)
  if types_mt.__type_cache[key] == nil then
    local require_path = string.format("st.zigbee.generated.types.%s", key)
    types_mt.__type_cache[key] = require(require_path)
  end
  return types_mt.__type_cache[key]
end

setmetatable(types, types_mt)
return types