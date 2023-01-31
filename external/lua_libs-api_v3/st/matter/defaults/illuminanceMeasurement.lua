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

--- @class st.matter.defaults.illuminanceMeasurement
--- @field public matter_handlers table
--- @field public subscribed_attributes table
--- @field public capability_handlers table
local illum_sensor_defaults = {}

local function illuminance_attr_handler(driver, device, ib, response)
  local lux = math.floor(math.pow(10, (ib.data.value - 1) / 10000))
  device:emit_event_for_endpoint(
    ib.endpoint_id, capabilities.illuminanceMeasurement.illuminance(lux)
  )
end

illum_sensor_defaults.matter_handlers = {
  attr = {
    [clusters.IlluminanceMeasurement.ID] = {
      [clusters.IlluminanceMeasurement.attributes.MeasuredValue.ID] = illuminance_attr_handler,
    },
  },
}
illum_sensor_defaults.capability_handlers = {}
illum_sensor_defaults.subscribed_attributes = {
  clusters.IlluminanceMeasurement.attributes.MeasuredValue,
}

return illum_sensor_defaults
