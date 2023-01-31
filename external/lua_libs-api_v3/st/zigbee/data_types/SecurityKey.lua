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
local DataABC = require "st.zigbee.data_types.base_defs.DataABC"

--- @class st.zigbee.data_types.SecurityKey: st.zigbee.data_types.DataABC
--- @field public ID number 0xF1
--- @field public NAME string "SecurityKey"
--- @field public byte_length number 16
--- @field public value string The bytes of this SecurityKey
local SecurityKey = {}
setmetatable(SecurityKey, DataABC.new_mt({ NAME = "SecurityKey", ID = 0xF1 }, 16))

