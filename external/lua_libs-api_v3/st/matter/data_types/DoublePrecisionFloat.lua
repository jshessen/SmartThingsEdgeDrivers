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

--- @class st.matter.data_types.DoublePrecisionFloat: st.matter.data_types.FloatABC
--- @field public ID number 0x0B
--- @field public NAME string "DoublePrecision"
--- @field public byte_length number 8
--- @field public mantissa_bit_length number 52
--- @field public exponent_bit_length number 11
local DoublePrecisionFloat = {}
setmetatable(
  DoublePrecisionFloat, FloatABC.new_mt(
    {NAME = "DoublePrecisionFloat", ID = 0x0B, SUBTYPES = {"SinglePrecisionFloat"}}, 8, 52, 11
  )
)

return DoublePrecisionFloat
