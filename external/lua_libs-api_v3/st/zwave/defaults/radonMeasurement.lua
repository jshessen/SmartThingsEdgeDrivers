-- Copyright 2022 SmartThings
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
local SensorMultilevel = (require "st.zwave.CommandClass.SensorMultilevel")({version=7})

--- Default handler for sensor multilevel reports of radon concentration for radon measurement-implementing devices
---
--- This converts the command sensor level to the appropriate radonMeasurement events
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.SensorMultilevel.Report
local function radon_concentration_report_handler(self, device, cmd)
  if cmd.args.sensor_type == SensorMultilevel.sensor_type.RADON_CONCENTRATION then
    local radonConcentrationValue = cmd.args.sensor_value
    if cmd.args.scale == SensorMultilevel.scale.radon_concentration.BECQUERELS_PER_CUBIC_METER then
      -- Conversion based on http://icrpaedia.org/Radon:_Units_of_Measure
      -- 10 [Bq/m3] = 0.27 [pCi/L]  =>  1 [pCi/L] ~ 37.037 [Bq/m3]
      radonConcentrationValue = cmd.args.sensor_value * 37.037
    end
    local scale = 'pCi/L'
    device:emit_event_for_endpoint(cmd.src_channel, capabilities.radonMeasurement.radonLevel({value = radonConcentrationValue, unit = scale}))
  end
end

--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param component string
--- @param endpoint integer
local function get_refresh_commands(driver, device, component, endpoint)
  if device:supports_capability_by_id(capabilities.radonMeasurement.ID, component) and device:is_cc_supported(cc.SENSOR_MULTILEVEL, endpoint) then
    return {SensorMultilevel:Get({sensor_type = SensorMultilevel.sensor_type.RADON_CONCENTRATION}, {dst_channels = {endpoint}})}
  end
end

--- @class st.zwave.defaults.radonMeasurement
--- @alias radon_measurement_defaults st.zwave.defaults.radonMeasurement
--- @field public zwave_handlers table
local radon_measurement_defaults = {
  zwave_handlers = {
    [cc.SENSOR_MULTILEVEL] = {
      [SensorMultilevel.REPORT] = radon_concentration_report_handler
    }
  },
  get_refresh_commands = get_refresh_commands
}

return radon_measurement_defaults
