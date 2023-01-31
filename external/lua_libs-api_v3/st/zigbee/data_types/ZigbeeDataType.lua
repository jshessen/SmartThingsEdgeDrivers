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
local UintABC = require "st.zigbee.data_types.base_defs.UintABC"
local data_types = require "st.zigbee.data_types"


--- @class st.zigbee.data_types.ZigbeeDataType: st.zigbee.data_types.UintABC
--- A representation of a field in a Zigbee message providing the ID of a Zigbee Data Type creation of this
--- will verify that the value is a known data type, and pretty printing will include that data type name
--- @field public NAME string "DataType"
--- @field public byte_length number 1
--- @field public value number This is the ID of a Zigbee data type
local ZigbeeDataType = {}
local dt_mt = UintABC.new_mt({ NAME = "DataType" }, 1)
dt_mt.__index.pretty_print = function(self)
  local out_str = "DataType: " .. data_types.get_data_type_by_id(self.value).NAME
  return out_str
end
dt_mt.__index.check_if_valid = function(self, int_val)
  if data_types.id_to_name_map[int_val] == nil then
    error(string.format("%s value is an unrecognized data type: 0x%02X", self.NAME, int_val))
  end
end

setmetatable(ZigbeeDataType, dt_mt)

return ZigbeeDataType
