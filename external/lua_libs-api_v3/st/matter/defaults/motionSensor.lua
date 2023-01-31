-- Copyright 2022 SmartThings
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
local capabilities = require "st.capabilities"
local clusters = require "st.matter.generated.zap_clusters.init"

--- @class st.matter.defaults.motionSensor
--- @field public matter_handlers table
--- @field public subscribed_attributes table
--- @field public capability_handlers table
local motion_sensor_defaults = {}

local function occupancy_attr_handler(driver, device, ib, response)
  device:emit_event(
    ib.data.value == 0x01 and capabilities.motionSensor.motion.active()
      or capabilities.motionSensor.motion.inactive()
  )
end

motion_sensor_defaults.matter_handlers = {
  attr = {
    [clusters.OccupancySensing.ID] = {
      [clusters.OccupancySensing.attributes.Occupancy.ID] = occupancy_attr_handler,
    },
  },
}
motion_sensor_defaults.capability_handlers = {}
motion_sensor_defaults.subscribed_attributes = {clusters.OccupancySensing.attributes.Occupancy}

return motion_sensor_defaults
