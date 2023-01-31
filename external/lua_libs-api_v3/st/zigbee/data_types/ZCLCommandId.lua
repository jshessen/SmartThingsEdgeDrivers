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

--- @class st.zigbee.data_types.ZCLCommandId: st.zigbee.data_types.UintABC
--- A representation of a field in a Zigbee message providing the ID of a Zigbee ZCL Command.  As this command
--- ID could represent a manufacturer/cluster specific command the value is not validated against a specific list.
--- @field public NAME string "ZCLCommandId"
--- @field public byte_length number 1
--- @field public value number This is the ID of a ZCL command
local ZCLCommandId = {}
setmetatable(ZCLCommandId, UintABC.new_mt({ NAME = "ZCLCommandId" }, 1))

return ZCLCommandId
