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
local SensorMultilevel = (require "st.zwave.CommandClass.SensorMultilevel")({version=5})

--- Default handler for sensor multilevel reports of precipitation rate for rain rate measurement-implementing devices
---
--- This converts the command sensor level to the appropriate precipitationRate events
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.SensorMultilevel.Report
local function precipitation_rate_report_handler(self, device, cmd)
  if cmd.args.sensor_type == SensorMultilevel.sensor_type.RAIN_RATE then
    local event
    if cmd.args.scale == SensorMultilevel.scale.rain_rate.MILLIMETERS_PER_HOUR then
      event = capabilities.precipitationRate.precipitationRate({value = cmd.args.sensor_value, unit = "mm/h"})
    elseif cmd.args.scale == SensorMultilevel.scale.rain_rate.INCHES_PER_HOUR then
      event = capabilities.precipitationRate.precipitationRate({value = cmd.args.sensor_value, unit = "in/h"})
    end

    if event ~= nil then
      device:emit_event_for_endpoint(cmd.src_channel, event)
    end
  end
end

--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param component string
--- @param endpoint integer
local function get_refresh_commands(driver, device, component, endpoint)
  if device:supports_capability_by_id(capabilities.precipationRate.ID, component) and device:is_cc_supported(cc.SENSOR_MULTILEVEL, endpoint) then
    return {SensorMultilevel:Get({sensor_type = SensorMultilevel.sensor_type.RAIN_RATE}, {dst_channels = {endpoint}})}
  end
end

--- @class st.zwave.defaults.precipitationRate
--- @alias precipitation_rate_defaults st.zwave.defaults.precipitationRate
--- @field public zwave_handlers table
local precipitation_rate_defaults = {
  zwave_handlers = {
    [cc.SENSOR_MULTILEVEL] = {
      [SensorMultilevel.REPORT] = precipitation_rate_report_handler
    }
  },
  get_refresh_commands = get_refresh_commands
}

return precipitation_rate_defaults
