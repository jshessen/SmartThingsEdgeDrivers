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
local constants = require "st.zigbee.constants"
local capabilities = require "st.capabilities"

--- @class st.zigbee.defaults.energyMeter
--- @field public zigbee_handlers table
--- @field public attribute_configurations table
--- @field public capability_handlers table
--- @field public default_current_summation_delivered_configuration st.zigbee.defaults.energyMeter.CurrentSummationDelivered
local energyMeter_defaults = {}


--- Default handler for CurrentSummationDelivered attribute on SimpleMetering cluster
---
--- This converts the Uint48 CurrentSummationDelivered into the energyMeter.energy capability event. This will
--- check the device for values set in the constants.SIMPLE_METERING_MULTIPLIER_KEY and
--- constants.SIMPLE_METERING_DIVISOR_KEY to convert the raw value to the correctly scaled values. These
--- fields should be set by reading the values from the same cluster
---
--- @param driver ZigbeeDriver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param value st.zigbee.data_types.Uint48 the value of the instantaneous demand
--- @param zb_rx st.zigbee.ZigbeeMessageRx the full message this report came in
function energyMeter_defaults.energy_meter_handler(driver, device, value, zb_rx)
  local raw_value = value.value
  local multiplier = device:get_field(constants.SIMPLE_METERING_MULTIPLIER_KEY) or 1
  local divisor = device:get_field(constants.SIMPLE_METERING_DIVISOR_KEY) or 1
  raw_value = raw_value * multiplier/divisor
  local offset = device:get_field(constants.ENERGY_METER_OFFSET) or 0
  if raw_value < offset then
    --- somehow our value has gone below the offset, so we'll reset the offset, since the device seems to have
    offset = 0
    device:set_field(constants.ENERGY_METER_OFFSET, offset, {persist = true})
  end
  raw_value = raw_value - offset
  device:emit_event_for_endpoint(zb_rx.address_header.src_endpoint.value, capabilities.energyMeter.energy({value = raw_value, unit = "kWh" }))
end

--- Default handler for Divisor attribute on SimpleMetering cluster
---
--- This will take the Int24 value of the Divisor on the SimpleMetering cluster and set the devices field
--- constants.SIMPLE_METERING_DIVISOR_KEY to the value.  This will then be used in the default handling of the
--- InstantaneousDemand attribute
---
--- @param driver ZigbeeDriver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param divisor st.zigbee.data_types.Int24 the value of the Divisor
--- @param zb_rx st.zigbee.ZigbeeMessageRx the full message this report came in
function energyMeter_defaults.simple_metering_divisor_handler(driver, device, divisor, zb_rx)
  local raw_value = divisor.value
  device:set_field(constants.SIMPLE_METERING_DIVISOR_KEY, raw_value, {persist = true})
end

--- Default handler for Multiplier attribute on SimpleMetering cluster
---
--- This will take the Int24 value of the Multiplier on the SimpleMetering cluster and set the devices field
--- constants.SIMPLE_METERING_MULTIPLIER_KEY to the value.  This will then be used in the default handling of the
--- InstantaneousDemand attribute
---
--- @param driver ZigbeeDriver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param multiplier st.zigbee.data_types.Int24 the value of the Multiplier
--- @param zb_rx st.zigbee.ZigbeeMessageRx the full message this report came in
function energyMeter_defaults.simple_metering_multiplier_handler(driver, device, multiplier, zb_rx)
  local raw_value = multiplier.value
  device:set_field(constants.SIMPLE_METERING_MULTIPLIER_KEY, raw_value, {persist = true})
end

--- Default handler for resetting the energy meter reading to zero
---
--- This will store the most recent energy meter reading, and all subsequent reports will have this value subtracted
--- from the value reported. Zigbee (unlike Z-Wave) does not provide a way to reset the value to zero, so this
--- is an attempt at a workaround.
---
--- @param driver ZigbeeDriver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param command CapabilityCommand the capability command table
function energyMeter_defaults.reset(driver, device, command)
  local _,last_reading = device:get_latest_state(command.component, capabilities.energyMeter.ID, capabilities.energyMeter.energy.NAME, 0, {value = 0, unit = "kWh"})
  if last_reading.value ~= 0 then
    local offset = device:get_field(constants.ENERGY_METER_OFFSET) or 0
    device:set_field(constants.ENERGY_METER_OFFSET, last_reading.value+offset, {persist = true})
  end
  device:emit_component_event({id = command.component}, capabilities.energyMeter.energy({value = 0.0, unit = "kWh"}))
end

energyMeter_defaults.zigbee_handlers = {
  global = {},
  cluster = {},
  attr = {
    [zcl_clusters.SimpleMetering] = {
      [zcl_clusters.SimpleMetering.attributes.CurrentSummationDelivered] = energyMeter_defaults.energy_meter_handler,
      [zcl_clusters.SimpleMetering.attributes.Multiplier] = energyMeter_defaults.simple_metering_multiplier_handler,
      [zcl_clusters.SimpleMetering.attributes.Divisor] = energyMeter_defaults.simple_metering_divisor_handler
    }
  }
}

energyMeter_defaults.capability_handlers = {
  [capabilities.energyMeter.commands.resetEnergyMeter.NAME] = energyMeter_defaults.reset
}

--- @class st.zigbee.defaults.energyMeter.CurrentSummationDelivered
--- @field public cluster number SimpleMetering ID 0x0702
--- @field public attribute number CurrentSummationDelivered ID 0x0000
--- @field public minimum_interval number 5 seconds
--- @field public maximum_interval number 3600 seconds (1 hour)
--- @field public data_type st.zigbee.data_types.Uint48 the UInt48 class
--- @field public reportable_change number 5 (some amount of kWh, dependent on multiplier and divisor)
local current_summation_delivered_default_config = {
  cluster = zcl_clusters.SimpleMetering.ID,
  attribute = zcl_clusters.SimpleMetering.attributes.CurrentSummationDelivered.ID,
  minimum_interval = 5,
  maximum_interval = 3600,
  data_type = zcl_clusters.SimpleMetering.attributes.CurrentSummationDelivered.base_type,
  reportable_change = 1
}

energyMeter_defaults.default_current_summation_delivered_configuration = current_summation_delivered_default_config

energyMeter_defaults.attribute_configurations = {
  current_summation_delivered_default_config
}

return energyMeter_defaults
