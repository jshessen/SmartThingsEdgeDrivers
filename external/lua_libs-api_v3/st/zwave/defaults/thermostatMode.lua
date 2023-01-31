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
--- @type st.zwave.CommandClass.ThermostatMode
local ThermostatMode = (require "st.zwave.CommandClass.ThermostatMode")({version=2})

--- Default handler for thermostat mode reports for implementing devices
---
--- This converts the command mode to the equivalent smartthings capability value
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.ThermostatMode.Report
local function thermostat_mode_report_handler(self, device, cmd)
  local event = nil
  if (cmd.args.mode == ThermostatMode.mode.OFF) then
    event = capabilities.thermostatMode.thermostatMode.off()
  elseif (cmd.args.mode == ThermostatMode.mode.HEAT) then
    event = capabilities.thermostatMode.thermostatMode.heat()
  elseif (cmd.args.mode == ThermostatMode.mode.COOL) then
    event = capabilities.thermostatMode.thermostatMode.cool()
  elseif (cmd.args.mode == ThermostatMode.mode.AUTO) then
    event = capabilities.thermostatMode.thermostatMode.auto()
  elseif (cmd.args.mode == ThermostatMode.mode.AUXILIARY_HEAT) then
    event = capabilities.thermostatMode.thermostatMode.emergency_heat()
  elseif (cmd.args.mode == ThermostatMode.mode.ENERGY_SAVE_HEAT) then
    event = capabilities.thermostatMode.thermostatMode.energysaveheat()
  end

  if (event ~= nil) then
    device:emit_event_for_endpoint(cmd.src_channel, event)
  end
end

--- Default handler for thermostat mode supported reports for implementing devices
---
--- This converts the command supported modes to the equivalent smartthings capability value
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.ThermostatMode.SupportedReport
local function thermostat_supported_modes_report_handler(self, device, cmd)
  local supported_modes = {}
  if (cmd.args.off) then
    table.insert(supported_modes, capabilities.thermostatMode.thermostatMode.off.NAME)
  end
  if (cmd.args.heat) then
    table.insert(supported_modes, capabilities.thermostatMode.thermostatMode.heat.NAME)
  end
  if (cmd.args.cool) then
    table.insert(supported_modes, capabilities.thermostatMode.thermostatMode.cool.NAME)
  end
  if (cmd.args.auto) then
    table.insert(supported_modes, capabilities.thermostatMode.thermostatMode.auto.NAME)
  end
  if (cmd.args.auxiliary_emergency_heat) then
    table.insert(supported_modes, capabilities.thermostatMode.thermostatMode.emergency_heat.NAME)
  end
  if (cmd.args.energy_save_heat) then
    table.insert(supported_modes, capabilities.thermostatMode.thermostatMode.energysaveheat.NAME)
  end
  device:emit_event_for_endpoint(
    cmd.src_channel,
    capabilities.thermostatMode.supportedThermostatModes(
      supported_modes,
      { visibility = { displayed = false }}
    )
  )
end

--- Default handler for the ThermostatMode.setThermostatMode command
---
--- This will send a thermostat mode set of the equivalent z-wave value, with a follow up
--- get to confirm.
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param command table The capability command table
local function set_thermostat_mode(driver, device, command)
  local modes = capabilities.thermostatMode.thermostatMode
  local mode = command.args.mode
  local modeValue = nil
  if (mode == modes.off.NAME) then
    modeValue = ThermostatMode.mode.OFF
  elseif (mode == modes.heat.NAME) then
    modeValue = ThermostatMode.mode.HEAT
  elseif (mode == modes.cool.NAME) then
    modeValue = ThermostatMode.mode.COOL
  elseif (mode == modes.auto.NAME) then
    modeValue = ThermostatMode.mode.AUTO
  elseif (mode == modes.emergency_heat.NAME) then
    modeValue = ThermostatMode.mode.AUXILIARY_HEAT
  elseif (mode == modes.energysaveheat.NAME) then
    modeValue = ThermostatMode.mode.ENERGY_SAVE_HEAT
  end

  if (modeValue ~= nil) then
    device:send_to_component(ThermostatMode:Set({mode = modeValue}), command.component)

    local follow_up_poll = function()
      device:send_to_component(ThermostatMode:Get({}), command.component)
    end

    device.thread:call_with_delay(1, follow_up_poll)
  end

end

local mode_setter = function(mode_name)
  return function(driver, device, command)
    set_thermostat_mode(driver,device,{args={mode=mode_name}})
  end
end

--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param component string
--- @param endpoint integer
local function get_refresh_commands(driver, device, component, endpoint)
  if device:supports_capability_by_id(capabilities.thermostatMode.ID, component) and device:is_cc_supported(cc.THERMOSTAT_MODE, endpoint) then
    return {ThermostatMode:Get({}, {dst_channels = {endpoint}})}
  end
end

--- @class st.zwave.defaults.thermostatMode
--- @alias thermostat_mode_defaults st.zwave.defaults.thermostatMode
--- @field public zwave_handlers table
--- @field public capability_handlers table
--- @field public get_refresh_commands function
local thermostat_mode_defaults = {
  zwave_handlers = {
    [cc.THERMOSTAT_MODE] = {
      [ThermostatMode.REPORT] = thermostat_mode_report_handler,
      [ThermostatMode.SUPPORTED_REPORT] = thermostat_supported_modes_report_handler
    }
  },
  capability_handlers = {
    [capabilities.thermostatMode.commands.setThermostatMode] = set_thermostat_mode,
    [capabilities.thermostatMode.commands.auto] = mode_setter(capabilities.thermostatMode.thermostatMode.auto.NAME),
    [capabilities.thermostatMode.commands.cool] = mode_setter(capabilities.thermostatMode.thermostatMode.cool.NAME),
    [capabilities.thermostatMode.commands.heat] = mode_setter(capabilities.thermostatMode.thermostatMode.heat.NAME),
    [capabilities.thermostatMode.commands.emergencyHeat] = mode_setter(capabilities.thermostatMode.thermostatMode.emergency_heat.NAME),
    [capabilities.thermostatMode.commands.off] = mode_setter(capabilities.thermostatMode.thermostatMode.off.NAME)
  },
  get_refresh_commands = get_refresh_commands
}

return thermostat_mode_defaults
