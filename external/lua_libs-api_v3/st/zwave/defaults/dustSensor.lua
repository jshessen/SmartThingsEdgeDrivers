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
--- @type st.zwave.CommandClass.SensorMultilevel.Get
local SensorMultilevel = (require "st.zwave.CommandClass.SensorMultilevel")({version=10})

--- Default handler for sensor multilevel reports of particulate matter 2.5/10 level for dust measurement-implementing devices
---
--- This converts the command sensor level to the appropriate dust events
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.SensorMultilevel.Report
local function dust_measurement_report_handler(self, device, cmd)
  if (cmd.args.sensor_type == SensorMultilevel.sensor_type.PARTICULATE_MATTER and
    cmd.args.scale == SensorMultilevel.scale.particulate_matter.MICROGRAMS_PER_CUBIC_METER) then
    local scale = 'μg/m^3'
    device:emit_event_for_endpoint(cmd.src_channel, capabilities.dustSensor.dustLevel({value = cmd.args.sensor_value, unit = scale}))
  elseif (cmd.args.sensor_type == SensorMultilevel.sensor_type.PARTICULATE_MATTER_2_5 and
    cmd.args.scale == SensorMultilevel.scale.particulate_matter_2_5.MICROGRAMS_PER_CUBIC_METER) then
    local scale = 'μg/m^3'
    device:emit_event_for_endpoint(cmd.src_channel, capabilities.dustSensor.fineDustLevel({value = cmd.args.sensor_value, unit = scale}))
  end
end

--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param component string
--- @param endpoint integer
local function get_refresh_commands(driver, device, component, endpoint)
  if device:supports_capability_by_id(capabilities.dustSensor.ID, component) and device:is_cc_supported(cc.SENSOR_MULTILEVEL, endpoint) then
    return {
      SensorMultilevel:Get({sensor_type = SensorMultilevel.sensor_type.PARTICULATE_MATTER}, {dst_channels = {endpoint}}),
      SensorMultilevel:Get({sensor_type = SensorMultilevel.sensor_type.PARTICULATE_MATTER_2_5}, {dst_channels = {endpoint}})
    }
  end
end

--- @class st.zwave.defaults.dustSensor
--- @alias dust_measurement_defaults st.zwave.defaults.dustSensor
--- @field public zwave_handlers table
local dust_measurement_defaults = {
  zwave_handlers = {
    [cc.SENSOR_MULTILEVEL] = {
      [SensorMultilevel.REPORT] = dust_measurement_report_handler
    }
  },
  get_refresh_commands = get_refresh_commands
}

return dust_measurement_defaults
