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
--- @type st.zwave.CommandClass.SensorMultilevel
local SensorMultilevel = (require "st.zwave.CommandClass.SensorMultilevel")({version=5})

-- According to https://en.wikipedia.org/wiki/Inch_of_mercury
local KILO_PASCAL_PER_INCH_OF_MERCURY = 3.386389

--- Default handler for sensor multilevel reports of atmospheric or barometric pressure for atmospheric pressure measurement-implementing devices
---
--- This converts the command sensor level to the appropriate pressure measurement and kPa scale
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.SensorMultilevel.Report
local function pressure_report_handler(self, device, cmd)
  if (cmd.args.sensor_type == SensorMultilevel.sensor_type.ATMOSPHERIC_PRESSURE or
    cmd.args.sensor_type == SensorMultilevel.sensor_type.BAROMETRIC_PRESSURE) then
    local scale = 'kPa'
    local pressure_value = cmd.args.sensor_value
    if (cmd.args.scale == SensorMultilevel.scale.atmospheric_pressure.INCHES_OF_MERCURY) then pressure_value = pressure_value * KILO_PASCAL_PER_INCH_OF_MERCURY end
    device:emit_event_for_endpoint(cmd.src_channel, capabilities.atmosphericPressureMeasurement.atmosphericPressure({value = pressure_value, unit = scale}))
  end
end

--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param component string
--- @param endpoint integer
local function get_refresh_commands(driver, device, component, endpoint)
  if device:supports_capability_by_id(capabilities.atmosphericPressureMeasurement.ID, component) and device:is_cc_supported(cc.SENSOR_MULTILEVEL, endpoint) then
    return {SensorMultilevel:Get({sensor_type = SensorMultilevel.sensor_type.BAROMETRIC_PRESSURE}, {dst_channels = {endpoint}})}
  end
end

--- @class st.zwave.defaults.atmosphericPressureMeasurement
--- @alias atmospheric_pressure_measurement_defaults st.zwave.defaults.atmosphericPressureMeasurement
--- @field public zwave_handlers table
local atmospheric_pressure_measurement_defaults = {
  zwave_handlers = {
    [cc.SENSOR_MULTILEVEL] = {
      [SensorMultilevel.REPORT] = pressure_report_handler
    }
  },
  get_refresh_commands = get_refresh_commands
}

return atmospheric_pressure_measurement_defaults
