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
local constants = require "st.zigbee.constants"
local log = require "log"

--- @class st.zigbee.defaults.powerMeter
--- @field public zigbee_handlers table
--- @field public attribute_configurations table
--- @field public capability_handlers table
--- @field public default_active_power_configuration st.zigbee.defaults.powerMeter.ActivePowerConfiguration
----@field public default_instantaneous_demand_configuration st.zigbee.defaults.powerMeter.InstantaneousDemandConfiguration
local powerMeter_defaults = {}

--- Default handler for ACPowerDivisor attribute on ElectricalMeasurement cluster
---
--- This will take the Uint16 value of the ACPowerDivisor on the ElectricalMeasurement cluster and set the devices field
--- constants.ELECTRICAL_MEASUREMENT_DIVISOR_KEY to the value.  This will then be used in the default handling of the
--- ActivePower attribute
---
--- @param driver ZigbeeDriver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param divisor st.zigbee.data_types.Uint16 the value of the Divisor
--- @param zb_rx st.zigbee.ZigbeeMessageRx the full message this report came in
function powerMeter_defaults.electrical_measurement_divisor_handler(driver, device, divisor, zb_rx)
  local raw_value = divisor.value
  device:set_field(constants.ELECTRICAL_MEASUREMENT_DIVISOR_KEY, raw_value, {persist = true})
end

--- Default handler for ACPowerMultiplier attribute on ElectricalMeasurement cluster
---
--- This will take the Uint16 value of the ACPowerMultiplier on the ElectricalMeasurement cluster and set the devices field
--- constants.ELECTRICAL_MEASUREMENT_MULTIPLIER_KEY to the value.  This will then be used in the default handling of the
--- ActivePower attribute
---
--- @param driver ZigbeeDriver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param multiplier st.zigbee.data_types.Uint16 the value of the Divisor
--- @param zb_rx st.zigbee.ZigbeeMessageRx the full message this report came in
function powerMeter_defaults.electrical_measurement_multiplier_handler(driver, device, multiplier, zb_rx)
  local raw_value = multiplier.value
  device:set_field(constants.ELECTRICAL_MEASUREMENT_MULTIPLIER_KEY, raw_value, {persist = true})
end

--- Default handler for ActivePower attribute on ElectricalMeasurement cluster
---
--- This converts the Int16 instantaneous demand into the powerMeter.power capability event.  This will
--- check the device for values set in the constants.ELECTRICAL_MEASUREMENT_MULTIPLIER_KEY and
--- constants.ELECTRICAL_MEASUREMENT_DIVISOR_KEY to convert the raw value to the correctly scaled values.  These
--- fields should be set by reading the values from the same cluster
---
--- @param driver ZigbeeDriver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param value st.zigbee.data_types.Int16 the value of the ActivePower
--- @param zb_rx st.zigbee.ZigbeeMessageRx the full message this report came in
function powerMeter_defaults.active_power_meter_handler(driver, device, value, zb_rx)
  local raw_value = value.value
  -- By default emit raw value
  local multiplier = device:get_field(constants.ELECTRICAL_MEASUREMENT_MULTIPLIER_KEY) or 1
  local divisor = device:get_field(constants.ELECTRICAL_MEASUREMENT_DIVISOR_KEY) or 1

  if divisor == 0 then
    log.warn_with({ hub_logs = true }, "Temperature scale divisor is 0; using 1 to avoid division by zero")
    divisor = 1
  end

  raw_value = raw_value * multiplier/divisor

  device:emit_event_for_endpoint(zb_rx.address_header.src_endpoint.value, capabilities.powerMeter.power({value = raw_value, unit = "W" }))
end

--- Default handler for Divisor attribute on SimpleMetering cluster
---
--- This will take the Int24 value of the Divisor on the SimpleMetering cluster and set the devices field
---constants.SIMPLE_METERING_DIVISOR_KEY to the value.  This will then be used in the default handling of the
---InstantaneousDemand attribute
---
--- @param driver ZigbeeDriver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param divisor st.zigbee.data_types.Int24 the value of the Divisor
--- @param zb_rx st.zigbee.ZigbeeMessageRx the full message this report came in
function powerMeter_defaults.simple_metering_divisor_handler(driver, device, divisor, zb_rx)
  local raw_value = divisor.value
  device:set_field(constants.SIMPLE_METERING_DIVISOR_KEY, raw_value, {persist = true})
end

--- Default handler for Multiplier attribute on SimpleMetering cluster
---
--- This will take the Int24 value of the Multiplier on the SimpleMetering cluster and set the devices field
---constants.SIMPLE_METERING_MULTIPLIER_KEY to the value.  This will then be used in the default handling of the
---InstantaneousDemand attribute
---
--- @param driver ZigbeeDriver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param multiplier st.zigbee.data_types.Int24 the value of the Multiplier
--- @param zb_rx st.zigbee.ZigbeeMessageRx the full message this report came in
function powerMeter_defaults.simple_metering_multiplier_handler(driver, device, multiplier, zb_rx)
  local raw_value = multiplier.value
  device:set_field(constants.SIMPLE_METERING_MULTIPLIER_KEY, raw_value, {persist = true})
end

--- Default handler for InstantaneousDemand attribute on SimpleMetering cluster
---
--- This converts the Int24 instantaneous demand into the powerMeter.power capability event.  This will
--- check the device for values set in the constants.SIMPLE_METERING_MULTIPLIER_KEY and
--- constants.SIMPLE_METERING_DIVISOR_KEY to convert the raw value to the correctly scaled values.  These
--- fields should be set by reading the values from the same cluster
---
--- @param driver ZigbeeDriver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param value st.zigbee.data_types.Int24 the value of the instantaneous demand
--- @param zb_rx st.zigbee.ZigbeeMessageRx the full message this report came in
function powerMeter_defaults.instantaneous_demand_handler(driver, device, value, zb_rx)
  local raw_value = value.value
  --- demand = demand received * Multipler/Divisor
  local multiplier = device:get_field(constants.SIMPLE_METERING_MULTIPLIER_KEY) or 1
  local divisor = device:get_field(constants.SIMPLE_METERING_DIVISOR_KEY) or 1

  if divisor == 0 then
    log.warn_with({ hub_logs = true }, "Temperature scale divisor is 0; using 1 to avoid division by zero")
    divisor = 1
  end

  raw_value = raw_value * multiplier/divisor

  local raw_value_watts = raw_value * 1000
  device:emit_event_for_endpoint(zb_rx.address_header.src_endpoint.value, capabilities.powerMeter.power({value = raw_value_watts, unit = "W" }))
end

powerMeter_defaults.zigbee_handlers = {
  global = {},
  cluster = {},
  attr = {
    [zcl_clusters.ElectricalMeasurement] = {
      [zcl_clusters.ElectricalMeasurement.attributes.ActivePower] = powerMeter_defaults.active_power_meter_handler,
      [zcl_clusters.ElectricalMeasurement.attributes.ACPowerDivisor.ID] = powerMeter_defaults.electrical_measurement_divisor_handler,
      [zcl_clusters.ElectricalMeasurement.attributes.ACPowerMultiplier.ID] = powerMeter_defaults.electrical_measurement_multiplier_handler
    },
    [zcl_clusters.SimpleMetering] = {
      [zcl_clusters.SimpleMetering.attributes.InstantaneousDemand] = powerMeter_defaults.instantaneous_demand_handler,
      [zcl_clusters.SimpleMetering.attributes.Multiplier] = powerMeter_defaults.simple_metering_multiplier_handler,
      [zcl_clusters.SimpleMetering.attributes.Divisor] = powerMeter_defaults.simple_metering_divisor_handler
    }
  }
}
powerMeter_defaults.capability_handlers = {}

--- @class st.zigbee.defaults.powerMeter.ActivePowerConfiguration
--- @field public cluster number ElectricalMeasurement ID 0x0B04
--- @field public attribute number ActivePower ID 0x050B
--- @field public minimum_interval number 1 seconds
--- @field public maximum_interval number 3600 seconds (1 hour)
--- @field public data_type st.zigbee.data_types.Int16 the Int16 class
--- @field public reportable_change number 1 (some amount of W, dependent on multiplier and divisor)
local active_power_configuration = {
  cluster = zcl_clusters.ElectricalMeasurement.ID,
  attribute = zcl_clusters.ElectricalMeasurement.attributes.ActivePower.ID,
  minimum_interval = 1,
  maximum_interval = 3600,
  data_type = zcl_clusters.ElectricalMeasurement.attributes.ActivePower.base_type,
  reportable_change = 5
}

--- @class st.zigbee.defaults.powerMeter.InstantaneousDemandConfiguration
--- @field public cluster number SimpleMetering ID 0x0702
--- @field public attribute number InstantaneousDemand ID 0x0400
--- @field public minimum_interval number 1 seconds
--- @field public maximum_interval number 3600 seconds (1 hour)
--- @field public data_type st.zigbee.data_types.Int24 the Int24 class
--- @field public reportable_change number 1 (some amount of W, dependent on multiplier and divisor)
local instantaneous_demand_configuration = {
  cluster = zcl_clusters.SimpleMetering.ID,
  attribute = zcl_clusters.SimpleMetering.attributes.InstantaneousDemand.ID,
  minimum_interval = 1,
  maximum_interval = 3600,
  data_type = zcl_clusters.SimpleMetering.attributes.InstantaneousDemand.base_type,
  reportable_change = 5
}

powerMeter_defaults.default_active_power_configuration = active_power_configuration
powerMeter_defaults.default_instantaneous_demand_configuration = instantaneous_demand_configuration

powerMeter_defaults.attribute_configurations = {
  active_power_configuration,
  instantaneous_demand_configuration
}

return powerMeter_defaults
