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
local utils = require "st.utils"

--- @class st.matter.defaults.relativeHumidityMeasurement
--- @field public matter_handlers table
--- @field public subscribed_attributes table
--- @field public capability_handlers table
local humidity_sensor_defaults = {}

local function humidity_attr_handler(driver, device, ib, response)
  local humidity = utils.round(ib.data.value / 100.0)
  device:emit_event_for_endpoint(
    ib.endpoint_id, capabilities.relativeHumidityMeasurement.humidity(humidity)
  )
end

humidity_sensor_defaults.matter_handlers = {
  attr = {
    [clusters.RelativeHumidityMeasurement.ID] = {
      [clusters.RelativeHumidityMeasurement.attributes.MeasuredValue.ID] = humidity_attr_handler,
    },
  },
}
humidity_sensor_defaults.capability_handlers = {}
humidity_sensor_defaults.subscribed_attributes = {
  clusters.RelativeHumidityMeasurement.attributes.MeasuredValue,
}

return humidity_sensor_defaults
