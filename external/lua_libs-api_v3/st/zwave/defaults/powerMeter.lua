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
--- @type st.zwave.CommandClass.Basic
local Basic = (require "st.zwave.CommandClass.Basic")({version=1})
--- @type st.zwave.CommandClass.Meter
local Meter = (require "st.zwave.CommandClass.Meter")({version=3})
--- @type st.zwave.CommandClass.SensorMultilevel
local SensorMultilevel = require "st.zwave.CommandClass.SensorMultilevel"
--- @type st.zwave.CommandClass.SwitchBinary
local SwitchBinary = require "st.zwave.CommandClass.SwitchBinary"
--- @type st.zwave.CommandClass.SwitchMultilevel
local SwitchMultilevel = require "st.zwave.CommandClass.SwitchMultilevel"

local zwave_handlers = {}
local POWER_UNIT_WATT = "W"

--- Default handler for power meter command class reports
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.Meter.Report
function zwave_handlers.meter_report_handler(self, device, cmd)
  if cmd.args.scale == Meter.scale.electric_meter.WATTS then
    local event_arguments = {
      value = cmd.args.meter_value,
      unit = POWER_UNIT_WATT
    }
    device:emit_event_for_endpoint(
      cmd.src_channel,
      capabilities.powerMeter.power(event_arguments)
    )
  end
end

--- Issue meter GET on switch state update to query power consumption.
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd cc Basic, SwitchBinary or SwitchMultilevel report
function zwave_handlers.switch_report(driver, device, cmd)
  if device:supports_capability_by_id(capabilities.powerMeter.ID) and device:is_cc_supported(cc.METER) then
    device:send_to_component(Meter:Get({scale = Meter.scale.electric_meter.WATTS}), device:endpoint_to_component(cmd.src_channel))
  end
end

--- Default handler for sensor multilevel reports of power for powerMeter-implementing devices
---
--- This converts the command sensor level to the appropriate power
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.SensorMultilevel.Report
function zwave_handlers.sensor_multi_level_report_handler(driver, device, cmd)
  if cmd.args.sensor_type == SensorMultilevel.sensor_type.POWER then
    local event_arguments = {
      value = cmd.args.sensor_value,
      unit = POWER_UNIT_WATT
    }
    device:emit_event_for_endpoint(
      cmd.src_channel,
      capabilities.powerMeter.power(event_arguments)
    )
  end
end

--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param component string
--- @param endpoint integer
local function get_refresh_commands(driver, device, component, endpoint)
  if device:supports_capability_by_id(capabilities.powerMeter.ID, component) and device:is_cc_supported(cc.METER, endpoint) then
    return {Meter:Get({scale = Meter.scale.electric_meter.WATTS}, {dst_channels = {endpoint}})}
  end
end

--- @class st.zwave.defaults.powerMeter
--- @alias power_meter_defaults st.zwave.defaults.powerMeter
--- @field public zwave_handlers table
--- @field public get_refresh_commands function
local power_meter_defaults = {
  zwave_handlers = {
    [cc.METER] = {
      [Meter.REPORT] = zwave_handlers.meter_report_handler
    },
    [cc.SENSOR_MULTILEVEL] = {
      [SensorMultilevel.REPORT] = zwave_handlers.sensor_multi_level_report_handler
    },
    [cc.BASIC] = {
      [Basic.REPORT] = zwave_handlers.switch_report
    },
    [cc.SWITCH_BINARY] = {
      [SwitchBinary.REPORT] = zwave_handlers.switch_report
    },
    [cc.SWITCH_MULTILEVEL] = {
      [SwitchMultilevel.REPORT] = zwave_handlers.switch_report
    }
  },
  get_refresh_commands = get_refresh_commands,
}

return power_meter_defaults
