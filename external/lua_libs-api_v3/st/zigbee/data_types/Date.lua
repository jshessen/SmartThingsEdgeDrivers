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
local DateABC = require "st.zigbee.data_types.base_defs.DateABC"

--- @class st.zigbee.data_types.Date: st.zigbee.data_types.DateABC
--- @field public ID number 0xE1
--- @field public NAME string "Date"
--- @field public year st.zigbee.data_types.Uint8 The year of this date (year - 1900, e.g. 119 for 2019)
--- @field public month st.zigbee.data_types.Uint8 The month value of this date (1 - 12)
--- @field public day_of_month st.zigbee.data_types.Uint8 The day of the month value of this date
--- @field public day_of_week st.zigbee.data_types.Uint8 The day of week value of this date (1 - 7)
local Date = {}
setmetatable(Date, DateABC.new_mt({ NAME = "Date", ID = 0xE1 }))

return Date
