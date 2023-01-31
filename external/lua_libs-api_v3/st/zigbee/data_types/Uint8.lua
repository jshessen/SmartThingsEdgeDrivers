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

--- @class st.zigbee.data_types.Uint8: st.zigbee.data_types.UintABC
--- @field public ID number 0x20
--- @field public NAME string "Uint8"
--- @field public byte_length number 1
--- @field public value number This is the actual value of the instance of the data type
local Uint8 = {}
setmetatable(Uint8, UintABC.new_mt({ NAME = "Uint8", ID = 0x20 }, 1))

return Uint8
