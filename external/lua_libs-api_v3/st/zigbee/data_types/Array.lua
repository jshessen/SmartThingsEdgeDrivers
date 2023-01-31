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
local ArrayABC = require "st.zigbee.data_types.base_defs.ArrayABC"

--- @class st.zigbee.data_types.Array: st.zigbee.data_types.ArrayABC
--- @field public ID number 0x48
--- @field public NAME string "Array"
--- @field public value table the list of elements in this array
local Array = {}
setmetatable(Array, ArrayABC.new_mt({ NAME = "Array", ID = 0x48 }))

return Array
