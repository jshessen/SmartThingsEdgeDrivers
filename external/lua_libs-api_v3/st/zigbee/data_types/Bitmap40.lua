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
local BitmapABC = require "st.zigbee.data_types.base_defs.BitmapABC"

--- @class st.zigbee.data_types.Bitmap40: st.zigbee.data_types.BitmapABC
--- @field public ID number 0x1C
--- @field public NAME string "Bitmap40"
--- @field public byte_length number 5
--- @field public value number This is the actual value of the instance of the data type
local Bitmap40 = {}
setmetatable(Bitmap40, BitmapABC.new_mt({ NAME = "Bitmap40", ID = 0x1C }, 5))

return Bitmap40
