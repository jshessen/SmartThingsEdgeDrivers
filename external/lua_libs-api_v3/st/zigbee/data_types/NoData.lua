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
local NoDataABC = require "st.zigbee.data_types.base_defs.NoDataABC"

--- @class st.zigbee.data_types.NoData: st.zigbee.data_types.NoDataABC
--- @field public ID number 0x00
--- @field public NAME string "NoData"
--- @field public value nil this data type has no body
local NoData = {}
setmetatable(NoData, NoDataABC.new_mt({NAME = "NoData", ID = 0x00}))

return NoData
