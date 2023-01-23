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

--- @class st.zigbee.defaults.thermostatHeatingSetpoint
--- @field public zigbee_handlers table
--- @field public attribute_configurations table
--- @field public capability_handlers table
local ths_defaults = {}

--- Default handler for the occupied heating setpoint value attribute on the thermostat cluster
---
--- This converts the Int16 value of the occupied heating setpoint attribute on the thermostat cluster to
--- ThermostatHeatingSetpoint.heatingSetpoint
---
--- @param driver Driver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param value st.zigbee.data_types.Int16 the thermostat occupied heating setpoint value
--- @param zb_rx st.zigbee.ZigbeeMessageRx the full message this report came in
function ths_defaults.thermostat_heating_setpoint_handler(driver, device, value, zb_rx)
  local raw_temp = value.value
  local celc_temp = raw_temp / 100.0
  local temp_scale = "C"
  device:emit_event_for_endpoint(zb_rx.address_header.src_endpoint.value, capabilities.thermostatHeatingSetpoint.heatingSetpoint({value = celc_temp, unit = temp_scale }))
end

--- Default handler for the ThermostatHeatingSetpoint.setHeatingSetpoint command
---
--- This will send a write to the occupied heating setpoint attribute in the thermostat cluster,
--- followed by a delayed read of the same attribute to confirm
---
--- @param driver Driver The current driver running containing necessary context for execution
--- @param device st.Device The device this message was received from containing identifying information
--- @param command table The capability command table
function ths_defaults.set_heating_setpoint(driver, device, command)
  device:send_to_component(command.component, zcl_clusters.Thermostat.attributes.OccupiedHeatingSetpoint:write(device, command.args.setpoint*100))

  device.thread:call_with_delay(2, function(d)
    device:send_to_component(command.component, zcl_clusters.Thermostat.attributes.OccupiedHeatingSetpoint:read(device))
  end)
end

ths_defaults.zigbee_handlers = {
  global = {},
  cluster = {},
  attr = {
    [zcl_clusters.Thermostat] = {
      [zcl_clusters.Thermostat.attributes.OccupiedHeatingSetpoint] = ths_defaults.thermostat_heating_setpoint_handler,
    }
  }
}
ths_defaults.capability_handlers = {
  [capabilities.thermostatHeatingSetpoint.commands.setHeatingSetpoint.NAME] = ths_defaults.set_heating_setpoint,
}

return ths_defaults
