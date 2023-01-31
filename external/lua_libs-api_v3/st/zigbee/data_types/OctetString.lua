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
local StringABC = require "st.zigbee.data_types.base_defs.StringABC"

--- @class st.zigbee.data_types.OctetString: st.zigbee.data_types.StringABC
--- @field public ID number 0x41
--- @field public NAME string "OctetString"
--- @field public length_byte_length number 1 (This is the number of bytes the length description takes)
--- @field public byte_length number the length of this string (not including the length bytes)
--- @field public value string The string representation of this field (note this does not include the length bytes)
local OctetString = {}
setmetatable(OctetString, StringABC.new_mt({NAME = "OctetString", ID = 0x41}, 1))

return OctetString
