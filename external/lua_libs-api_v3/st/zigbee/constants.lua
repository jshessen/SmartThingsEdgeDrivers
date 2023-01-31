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

local constants = {}

constants.HA_PROFILE_ID = 0x0104
constants.ZLL_PROFILE_ID = 0xC05E
constants.ZDO_PROFILE_ID = 0x0000
constants.DEFAULT_ENDPOINT = 0x00
constants.ELECTRICAL_MEASUREMENT_MULTIPLIER_KEY = "_electrical_measurement_multiplier"
constants.ELECTRICAL_MEASUREMENT_DIVISOR_KEY = "_electrical_measurement_divisor"
constants.SIMPLE_METERING_MULTIPLIER_KEY = "_simple_metering_multiplier"
constants.SIMPLE_METERING_DIVISOR_KEY = "_simple_metering_divisor"
constants.ENERGY_METER_OFFSET = "_energy_meter_offset"

--- @class IAS_ZONE_CONFIGURE_TYPE
--- @field public CUSTOM number 0
--- @field public AUTO_ENROLL_RESPONSE number 1
--- @field public TRIP_TO_PAIR number 2
--- @field public AUTO_ENROLL_REQUEST number 3
constants.IAS_ZONE_CONFIGURE_TYPE = {
  CUSTOM = 0,
  AUTO_ENROLL_RESPONSE = 1,
  TRIP_TO_PAIR = 2,
  AUTO_ENROLL_REQUEST = 3,
}

constants.HUB = {
  ADDR = 0x0000,
  ENDPOINT = 0x01
}

return constants
