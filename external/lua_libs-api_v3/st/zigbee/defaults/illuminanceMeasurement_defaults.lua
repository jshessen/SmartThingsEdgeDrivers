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

--- @class st.zigbee.defaults.illuminanceMeasurement
--- @field public zigbee_handlers table
--- @field public attribute_configurations table
--- @field public capability_handlers table
local illuminance_measurement_defaults = {}

--- Default handler for illuminance attribute on the illuminance measurement cluster
---
--- This converts the Uint16 value to IlluminanceMeasurement.illuminance in lux
--- Based on formula described in ZCL reference - MeasuredValue = 10,000 x log10 Illuminance + 1
---
--- @param driver Driver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param value st.zigbee.data_types.Uint16 the value of the illuminance attribute on the illuminance measurement cluster
--- @param zb_rx st.zigbee.ZigbeeMessageRx the full message this report came in
function illuminance_measurement_defaults.illuminance_attr_handler(driver, device, value, zb_rx)
  local lux_value = math.floor(math.pow(10, (value.value - 1) / 10000))
  device:emit_event_for_endpoint(zb_rx.address_header.src_endpoint.value, capabilities.illuminanceMeasurement.illuminance(lux_value))
end

illuminance_measurement_defaults.zigbee_handlers = {
  global = {},
  cluster = {},
  attr = {
    [zcl_clusters.IlluminanceMeasurement] = {
      [zcl_clusters.IlluminanceMeasurement.attributes.MeasuredValue] = illuminance_measurement_defaults.illuminance_attr_handler,
    }
  }
}

illuminance_measurement_defaults.capability_handlers = {}

local illuminance_configuration =   {
  cluster = zcl_clusters.IlluminanceMeasurement.ID,
  attribute = zcl_clusters.IlluminanceMeasurement.attributes.MeasuredValue.ID,
  minimum_interval = 1,
  maximum_interval = 3600,
  data_type = zcl_clusters.IlluminanceMeasurement.attributes.MeasuredValue.base_type,
  reportable_change = 1
}

illuminance_measurement_defaults.default_illuminance_configuration = illuminance_configuration

illuminance_measurement_defaults.attribute_configurations = {
  illuminance_configuration
}

return illuminance_measurement_defaults
