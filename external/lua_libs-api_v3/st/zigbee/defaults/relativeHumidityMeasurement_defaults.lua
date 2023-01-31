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
--- @type st.zigbee.zcl.clusters.RelativeHumidity
local HumidityCluster = require ("st.zigbee.zcl.clusters").RelativeHumidity
local capabilities = require "st.capabilities"
local utils = require "st.utils"

--- @class st.zigbee.defaults.relativeHumidityMeasurement
--- @field public zigbee_handlers table
--- @field public attribute_configurations table
--- @field public capability_handlers table
--- @field public default_relative_humidity_configuration st.zigbee.defaults.relativeHumidityMeasurement.HumidityMeasuredValueConfiguration
local relative_humidity_measurement_defaults = {}

--- Default handler for Humidity measured value on the relative humidity measurement cluster
---
--- This converts the Uint16 value of the humidity measured attribute to RelativeHumidityMeasurement.humidity
---
--- @param driver ZigbeeDriver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param value st.zigbee.data_types.Uint16 the value of the measured humidity
--- @param zb_rx st.zigbee.ZigbeeMessageRx the full message this report came in
function relative_humidity_measurement_defaults.humidity_attr_handler(driver, device, value, zb_rx)
  if (value.value ~= 0xFFFF) then -- 0xFFFF means the measured value was invalid
    device:emit_event_for_endpoint(zb_rx.address_header.src_endpoint.value, capabilities.relativeHumidityMeasurement.humidity(utils.round(value.value / 100.0)))
  end
end

relative_humidity_measurement_defaults.zigbee_handlers = {
  global = {},
  cluster = {},
  attr = {
    [HumidityCluster] = {
      [HumidityCluster.attributes.MeasuredValue] = relative_humidity_measurement_defaults.humidity_attr_handler
    }
  }
}

relative_humidity_measurement_defaults.capability_handlers = {}

--- @class st.zigbee.defaults.relativeHumidityMeasurement.HumidityMeasuredValueConfiguration
--- @field public cluster number RelatvieHumidity ID 0x0405
--- @field public attribute number MeasuredValue ID 0x0000
--- @field public minimum_interval number 30 seconds
--- @field public maximum_interval number 3600 seconds (1 hour)
--- @field public data_type st.zigbee.data_types.Uint16 the Uint16 class
--- @field public reportable_change number 100 (1%)
local relative_humidity_configuration =   {
  cluster = HumidityCluster,
  attribute = HumidityCluster.attributes.MeasuredValue,
  minimum_interval = 30,
  maximum_interval = 3600,
  data_type = HumidityCluster.attributes.MeasuredValue.base_type,
  reportable_change = 100
}

relative_humidity_measurement_defaults.default_relative_humidity_configuration = relative_humidity_configuration

relative_humidity_measurement_defaults.attribute_configurations = {
  relative_humidity_configuration
}

return relative_humidity_measurement_defaults
