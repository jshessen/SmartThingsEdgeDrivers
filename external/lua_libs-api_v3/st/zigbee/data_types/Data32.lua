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
local DataABC = require "st.zigbee.data_types.base_defs.DataABC"

--- @class st.zigbee.data_types.Data32: st.zigbee.data_types.DataABC
--- @field public ID number 0x0B
--- @field public NAME string "Data32"
--- @field public byte_length number 4
--- @field public value string The raw bytes of this data field
local Data32 = {}
setmetatable(Data32, DataABC.new_mt({ NAME = "Data32", ID = 0x0B }, 4))

return Data32
