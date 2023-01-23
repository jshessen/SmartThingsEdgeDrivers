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

--- @class st.zigbee.data_types.Data40: st.zigbee.data_types.DataABC
--- @field public ID number 0x0C
--- @field public NAME string "Data40"
--- @field public byte_length number 5
--- @field public value string The raw bytes of this data field
local Data40 = {}
setmetatable(Data40, DataABC.new_mt({ NAME = "Data40", ID = 0x0C }, 5))

return Data40
