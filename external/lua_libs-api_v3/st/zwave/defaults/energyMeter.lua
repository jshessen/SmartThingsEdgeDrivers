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
--- @type st.zwave.CommandClass.Meter
local Meter = (require "st.zwave.CommandClass.Meter")({version=3})

local zwave_handlers = {}
local capability_handlers = {}
local ENERGY_UNIT_KWH = "kWh"
local ENERGY_UNIT_KVAH = "kVAh"

--- Default handler for energy meter command class reports
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.Meter.Report
function zwave_handlers.meter_report_handler(self, device, cmd)
  local event_arguments = nil

  if cmd.args.scale == Meter.scale.electric_meter.KILOWATT_HOURS then
    event_arguments = {
      value = cmd.args.meter_value,
      unit = ENERGY_UNIT_KWH
    }
  elseif cmd.args.scale == Meter.scale.electric_meter.KILOVOLT_AMPERE_HOURS then
    event_arguments = {
      value = cmd.args.meter_value,
      unit = ENERGY_UNIT_KVAH
    }
  end
  if event_arguments ~= nil then
    device:emit_event_for_endpoint(
      cmd.src_channel,
      capabilities.energyMeter.energy(event_arguments)
    )
  end
end

--- Default handler for energy meter reset command
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param command meter reset command
function capability_handlers.reset(driver, device, command)
  device:send_to_component(Meter:Reset({}), command.component)
  device:send_to_component(Meter:Get({scale = Meter.scale.electric_meter.KILOWATT_HOURS}), command.component)
end

--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param component string
--- @param endpoint integer
local function get_refresh_commands(driver, device, component, endpoint)
  if device:supports_capability_by_id(capabilities.energyMeter.ID, component) and device:is_cc_supported(cc.METER, endpoint) then
    return {Meter:Get({scale = Meter.scale.electric_meter.KILOWATT_HOURS}, {dst_channels = {endpoint}})}
  end
end

--- @class st.zwave.defaults.energyMeter
--- @alias energy_meter_defaults st.zwave.defaults.energyMeter
--- @field public zwave_handlers table
--- @field public get_refresh_commands function
local energy_meter_defaults = {
  zwave_handlers = {
    [cc.METER] = {
      [Meter.REPORT] = zwave_handlers.meter_report_handler
    },
  },
  capability_handlers = {
    [capabilities.energyMeter.commands.resetEnergyMeter] = capability_handlers.reset
  },
  get_refresh_commands = get_refresh_commands
}

return energy_meter_defaults
