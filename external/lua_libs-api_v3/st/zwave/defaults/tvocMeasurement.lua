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

local utils = require "st.utils"

--- Default handler for sensor multilevel reports of volatile organic compound level for tvoc measurement-implementing devices
---
--- This converts the command sensor level to the appropriate tvocLevel events
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.SensorMultilevel.Report
local function tvoc_measurement_report_handler(self, device, cmd)
  if cmd.args.sensor_type == SensorMultilevel.sensor_type.VOLATILE_ORGANIC_COMPOUND then
    local tvocLevelValue = cmd.args.sensor_value
    if cmd.args.scale == SensorMultilevel.scale.volatile_organic_compound.MOLES_PER_CUBIC_METER then
      tvocLevelValue = utils.mole_per_cubic_meter_to_ppm(cmd.args.sensor_value)
    end
    local scale = 'ppm'
    device:emit_event_for_endpoint(cmd.src_channel, capabilities.tvocMeasurement.tvocLevel({value = tvocLevelValue, unit = scale}))
  end
end

--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param component string
--- @param endpoint integer
local function get_refresh_commands(driver, device, component, endpoint)
  if device:supports_capability_by_id(capabilities.tvocMeasurement.ID, component) and device:is_cc_supported(cc.SENSOR_MULTILEVEL, endpoint) then
    return {SensorMultilevel:Get({sensor_type = SensorMultilevel.sensor_type.VOLATILE_ORGANIC_COMPOUND}, {dst_channels = {endpoint}})}
  end
end

--- @class st.zwave.defaults.tvocMeasurement
--- @alias tvoc_measurement_defaults st.zwave.defaults.tvocMeasurement
--- @field public zwave_handlers table
local tvoc_measurement_defaults = {
  zwave_handlers = {
    [cc.SENSOR_MULTILEVEL] = {
      [SensorMultilevel.REPORT] = tvoc_measurement_report_handler
    }
  },
  get_refresh_commands = get_refresh_commands
}

return tvoc_measurement_defaults
