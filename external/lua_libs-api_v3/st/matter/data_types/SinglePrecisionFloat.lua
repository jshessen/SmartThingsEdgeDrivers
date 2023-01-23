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
local FloatABC = require "st.matter.data_types.base_defs.FloatABC"

--- @class st.matter.data_types.SinglePrecisionFloat: st.matter.data_types.FloatABC
--- @field public ID number 0x0A
--- @field public NAME string "SinglePrecision"
--- @field public byte_length number 4
--- @field public mantissa_bit_length number 23
--- @field public exponent_bit_length number 8
local SinglePrecisionFloat = {}
setmetatable(
  SinglePrecisionFloat, FloatABC.new_mt({NAME = "SinglePrecisionFloat", ID = 0x0A}, 4, 23, 8)
)

return SinglePrecisionFloat
