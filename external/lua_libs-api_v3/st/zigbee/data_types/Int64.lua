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

--- @class st.zigbee.data_types.Int64: st.zigbee.data_types.DataABC
--- Because lua only supports 64 bit numbers it is not possible to natively store a number that is
--- 64 bits long and unsigned.  In this case our number is signed so we could possibly use a native number
--- However, to maintain consistency with all other 64 bit Zigbee types we actually inherit from the DataABC Zigbee type
--- and store the bytes of the number directly. Thus usage of this will be different.
--- @field public ID number 0x2F
--- @field public NAME string "Int64"
--- @field public byte_length number 8
--- @field public value string This is the actual value of the instance of the data type
local Int64 = {}
setmetatable(Int64, DataABC.new_mt({ NAME = "Int64", ID = 0x2F }, 8))

return Int64
