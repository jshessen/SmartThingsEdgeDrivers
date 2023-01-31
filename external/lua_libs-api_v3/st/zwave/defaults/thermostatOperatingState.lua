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
local capabilities = require "st.capabilities"
--- @type st.zwave.CommandClass
local cc = require "st.zwave.CommandClass"
--- @type st.zwave.CommandClass.ThermostatOperatingState
local ThermostatOperatingState = (require "st.zwave.CommandClass.ThermostatOperatingState")({version=1,strict=true})

--- Default handler for thermostat operating state reports for implementing devices
---
--- This converts the command operating state to the equivalent smartthings capability value
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.ThermostatOperatingState.Report
local function thermostat_operating_state_report_handler(self, device, cmd)
  local event = nil
  if (cmd.args.operating_state == ThermostatOperatingState.operating_state.IDLE) then
    event = capabilities.thermostatOperatingState.thermostatOperatingState.idle()
  elseif (cmd.args.operating_state == ThermostatOperatingState.operating_state.HEATING) then
    event = capabilities.thermostatOperatingState.thermostatOperatingState.heating()
  elseif (cmd.args.operating_state == ThermostatOperatingState.operating_state.COOLING) then
    event = capabilities.thermostatOperatingState.thermostatOperatingState.cooling()
  elseif (cmd.args.operating_state == ThermostatOperatingState.operating_state.FAN_ONLY) then
    event = capabilities.thermostatOperatingState.thermostatOperatingState.fan_only()
  elseif (cmd.args.operating_state == ThermostatOperatingState.operating_state.PENDING_HEAT) then
    event = capabilities.thermostatOperatingState.thermostatOperatingState.pending_heat()
  elseif (cmd.args.operating_state == ThermostatOperatingState.operating_state.PENDING_COOL) then
    event = capabilities.thermostatOperatingState.thermostatOperatingState.pending_cool()
  elseif (cmd.args.operating_state == ThermostatOperatingState.operating_state.VENT_ECONOMIZER) then
    event = capabilities.thermostatOperatingState.thermostatOperatingState.vent_economizer()
  end

  if (event ~= nil) then
    device:emit_event_for_endpoint(cmd.src_channel, event)
  end
end

--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param component string
--- @param endpoint integer
local function get_refresh_commands(driver, device, component, endpoint)
  if device:supports_capability_by_id(capabilities.thermostatOperatingState.ID, component) and device:is_cc_supported(cc.THERMOSTAT_OPERATING_STATE, endpoint) then
    return {ThermostatOperatingState:Get({}, {dst_channels = {endpoint}})}
  end
end

--- @class st.zwave.defaults.thermostatOperatingState
--- @alias thermostat_operating_state_defaults st.zwave.defaults.thermostatOperatingState
--- @field public zwave_handlers table
--- @field public get_refresh_commands function
local thermostat_operating_state_defaults = {
  zwave_handlers = {
    [cc.THERMOSTAT_OPERATING_STATE] = {
      [ThermostatOperatingState.REPORT] = thermostat_operating_state_report_handler
    }
  },
  get_refresh_commands = get_refresh_commands
}

return thermostat_operating_state_defaults
