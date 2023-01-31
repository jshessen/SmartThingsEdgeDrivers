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
local UintABC = require "st.zigbee.data_types.base_defs.UintABC"

--- @class st.zigbee.data_types.BACNetOId: st.zigbee.data_types.UintABC
--- @field public ID number 0xEA
--- @field public NAME string "BACNetOId"
--- @field public byte_length number 4
--- @field public value number The BACNetOId this represents
local BACNetOId = {}
setmetatable(BACNetOId, UintABC.new_mt({ NAME = "BACNetOId", ID = 0xEA, is_discrete = true }, 4))
