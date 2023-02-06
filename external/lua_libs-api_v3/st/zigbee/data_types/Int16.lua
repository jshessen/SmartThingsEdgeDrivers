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
local IntABC = require "st.zigbee.data_types.base_defs.IntABC"

--- @class st.zigbee.data_types.Int16: st.zigbee.data_types.IntABC
--- @field public ID number 0x29
--- @field public NAME string "Int16"
--- @field public byte_length number 1
--- @field public value number This is the actual value of the instance of the data type
local Int16 = {}
setmetatable(Int16, IntABC.new_mt({ NAME = "Int16", ID = 0x29 }, 2))

return Int16