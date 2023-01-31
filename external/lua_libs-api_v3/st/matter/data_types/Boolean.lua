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
local BooleanABC = require "st.matter.data_types.base_defs.BooleanABC"

--- @class st.matter.data_types.Boolean: st.matter.data_types.BooleanABC
--- @field public ID number 0x08
--- @field public ExtendedID number 0x09 allows too element types to map to the same data type
--- @field public NAME string "Boolean"
--- @field public value boolean The value of this boolean data type
local Boolean = {}

setmetatable(Boolean, BooleanABC.new_mt({NAME = "Boolean", ID = 0x08, ExtendedID = 0x09}))

return Boolean
