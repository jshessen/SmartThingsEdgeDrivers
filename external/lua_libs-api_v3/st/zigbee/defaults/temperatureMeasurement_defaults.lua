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
local zcl_clusters = require "st.zigbee.zcl.clusters"
local capabilities = require "st.capabilities"

--- @class st.zigbee.defaults.temperatureMeasurement
--- @field public zigbee_handlers table
--- @field public attribute_configurations table
--- @field public capability_handlers table
--- @field public default_temperature_configuration st.zigbee.defaults.temperatureMeasurement.TemperatureConfiguration
local temperature_measurement_defaults = {}

--- Default handler for Temperature measured value on the Temperature measurement cluster
---
--- This converts the Int16 value of the temp measured attribute to TemperatureMeasurement.temperature this will convert
--- to fahrenheit or celsius based on the device data
---
--- @param driver Driver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param value st.zigbee.data_types.Int16 the value of the measured temperature
--- @param zb_rx st.zigbee.ZigbeeMessageRx the full message this report came in
function temperature_measurement_defaults.temp_attr_handler(driver, device, value, zb_rx)
  local raw_temp = value.value
  local celc_temp = raw_temp / 100.0
  local temp_scale = "C"
  -- All events from drivers should be in celsius and without offset manipulation
  device:emit_event_for_endpoint(zb_rx.address_header.src_endpoint.value, capabilities.temperatureMeasurement.temperature({value = celc_temp, unit = temp_scale }))
end

temperature_measurement_defaults.zigbee_handlers = {
  global = {},
  cluster = {},
  attr = {
    [zcl_clusters.TemperatureMeasurement] = {
      [zcl_clusters.TemperatureMeasurement.attributes.MeasuredValue] = temperature_measurement_defaults.temp_attr_handler
    },
    [zcl_clusters.Thermostat] = {
      [zcl_clusters.Thermostat.attributes.LocalTemperature] = temperature_measurement_defaults.temp_attr_handler
    }
  }
}
temperature_measurement_defaults.capability_handlers = {}


--- @class st.zigbee.defaults.temperatureMeasurement.TemperatureConfiguration
--- @field public cluster number TemperatureMeasurement cluster ID 0x0402
--- @field public attribute number MeasuredValue attribute ID 0x0000
--- @field public minimum_interval number 30 seconds
--- @field public maximum_interval number 300 seconds (5 mins)
--- @field public data_type st.zigbee.data_types.Int16 the Int16 class
--- @field public reportable_change number 16 (.1 C)
local measured_value_configuration = {
  cluster = zcl_clusters.TemperatureMeasurement.ID,
  attribute = zcl_clusters.TemperatureMeasurement.attributes.MeasuredValue.ID,
  minimum_interval = 30,
  maximum_interval = 300,
  data_type = zcl_clusters.TemperatureMeasurement.attributes.MeasuredValue.base_type,
  reportable_change = 16
}

temperature_measurement_defaults.default_temperature_configuration = measured_value_configuration

temperature_measurement_defaults.attribute_configurations = {
  measured_value_configuration
}

return temperature_measurement_defaults
