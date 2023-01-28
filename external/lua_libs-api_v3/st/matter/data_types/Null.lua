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
local NullABC = require "st.matter.data_types.base_defs.NullABC"

--- @class st.matter.data_types.Null: st.matter.data_types.NullABC
--- @field public ID number 0x00
--- @field public NAME string "Null"
--- @field public value nil this data type has no body
local Null = {}
setmetatable(Null, NullABC.new_mt({NAME = "Null", ID = 0x0014}))

return Null
