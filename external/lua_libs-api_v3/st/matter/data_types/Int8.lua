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
local IntABC = require "st.matter.data_types.base_defs.IntABC"

--- @class st.matter.data_types.Int8: st.matter.data_types.IntABC
--- @field public ID number 0x00
--- @field public NAME string "Int8"
--- @field public byte_length number 1
--- @field public value number This is the actual value of the instance of the data type
local Int8 = {}
setmetatable(Int8, IntABC.new_mt({NAME = "Int8", ID = 0x00}, 1))

return Int8
