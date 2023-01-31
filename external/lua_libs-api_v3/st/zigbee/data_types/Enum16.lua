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
local EnumABC = require "st.zigbee.data_types.base_defs.EnumABC"

--- @class st.zigbee.data_types.Enum16: st.zigbee.data_types.EnumABC
--- @field public ID number 0x31
--- @field public NAME string "Enum16"
--- @field public byte_length number 2
--- @field public value number This is the actual value of the instance of the data type
local Enum16 = {}
setmetatable(Enum16, EnumABC.new_mt({ NAME = "Enum16", ID = 0x31 }, 2))

return Enum16
