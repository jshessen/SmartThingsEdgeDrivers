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
local TimeOfDayABC = require "st.zigbee.data_types.base_defs.TimeOfDayABC"

--- @class st.zigbee.data_types.TimeOfDay: st.zigbee.data_types.TimeOfDayABC
--- @field public ID number 0xE0
--- @field public NAME string "TimeOfDay"
--- @field public hours st.zigbee.data_types.Uint8 The hours value of this time
--- @field public minutes st.zigbee.data_types.Uint8 The minutes value of this time
--- @field public seconds st.zigbee.data_types.Uint8 The seconds value of this time
--- @field public hundredths st.zigbee.data_types.Uint8 The hundredths value of this time
local TimeOfDay = {}
setmetatable(TimeOfDay, TimeOfDayABC.new_mt({ NAME = "TimeOfDay", ID = 0xE0 }))

return TimeOfDay
