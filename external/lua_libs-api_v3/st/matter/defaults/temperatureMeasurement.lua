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

--- @class st.matter.defaults.temperatureMeasurement
--- @field public matter_handlers table
--- @field public subscribed_attributes table
--- @field public capability_handlers table
local temp_sensor_defaults = {}

local function temperature_attr_handler(driver, device, ib, response)
  local temp = ib.data.value / 100.0
  local unit = "C"
  device:emit_event_for_endpoint(
    ib.endpoint_id, capabilities.temperatureMeasurement.temperature({value = temp, unit = unit})
  )
end

temp_sensor_defaults.matter_handlers = {
  attr = {
    [clusters.TemperatureMeasurement.ID] = {
      [clusters.TemperatureMeasurement.attributes.MeasuredValue.ID] = temperature_attr_handler,
    },
    [clusters.Thermostat.ID] = {
      [clusters.Thermostat.attributes.LocalTemperature.ID] = temperature_attr_handler,
    },
  },
}
temp_sensor_defaults.capability_handlers = {}
temp_sensor_defaults.subscribed_attributes = {
  clusters.TemperatureMeasurement.attributes.MeasuredValue,
  clusters.Thermostat.attributes.LocalTemperature,
}

return temp_sensor_defaults
