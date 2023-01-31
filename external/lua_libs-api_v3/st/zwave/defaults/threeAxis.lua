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
--- @type st.zwave.CommandClass.SwitchMultilevel
local SensorMultilevel = (require "st.zwave.CommandClass.SensorMultilevel")({version=8,strict=true})
--- @type st.utils
local utils = require "st.utils"

local ACCELERATION_VECTOR_FIELD = "accelerationVector"

--- This converts acceleration value reported by a Z-Wave device in m/s^2 to unit accepted by SmartThings threeAxis capability, mG
---
--- @param value number acceleration provided in m/s^2
--- @return number acceleration in mG
local function meter_per_second_sq_to_mG(original_value)
  local G = 9.81 -- meters per second square, approximately
  return original_value / G * 1000
end

local function update_acceleration_vector(device, axis, value)
  local acceleration_vector = device:get_field(ACCELERATION_VECTOR_FIELD) or {}
  acceleration_vector[axis] = utils.round(meter_per_second_sq_to_mG(value))
  device:set_field(ACCELERATION_VECTOR_FIELD, acceleration_vector, {persist = true})
  if utils.table_size(acceleration_vector) == 3 then
    local vector_values = {}
    table.insert(vector_values, acceleration_vector.X)
    table.insert(vector_values, acceleration_vector.Y)
    table.insert(vector_values, acceleration_vector.Z)
    device:emit_event(capabilities.threeAxis.threeAxis({value = vector_values, unit = 'mG'}))
  end
end

--- Default handler for sensor multilevel reports of acceleration for three axis acceleration devices
---
--- This converts the command sensor level to the appropriate accelerations vector event (in m/s^2)
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.SensorMultilevel.Report
local function three_axis_report_handler(self, device, cmd)
  if cmd.args.sensor_type == SensorMultilevel.sensor_type.ACCELERATION_X_AXIS then
    update_acceleration_vector(device, 'X', cmd.args.sensor_value)
  elseif cmd.args.sensor_type == SensorMultilevel.sensor_type.ACCELERATION_Y_AXIS then
    update_acceleration_vector(device, 'Y', cmd.args.sensor_value)
  elseif cmd.args.sensor_type == SensorMultilevel.sensor_type.ACCELERATION_Z_AXIS then
    update_acceleration_vector(device, 'Z', cmd.args.sensor_value)
  end
end

--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param component string
--- @param endpoint integer
local function get_refresh_commands(driver, device, component, endpoint)
  if device:supports_capability_by_id(capabilities.threeAxis.ID, component) and device:is_cc_supported(cc.SENSOR_MULTILEVEL, endpoint) then
    return {
      SensorMultilevel:Get({sensor_type = SensorMultilevel.sensor_type.ACCELERATION_X_AXIS, scale = SensorMultilevel.scale.acceleration_x_axis.METERS_PER_SQUARE_SECOND}, {dst_channels = {endpoint}}),
      SensorMultilevel:Get({sensor_type = SensorMultilevel.sensor_type.ACCELERATION_Y_AXIS, scale = SensorMultilevel.scale.acceleration_y_axis.METERS_PER_SQUARE_SECOND}, {dst_channels = {endpoint}}),
      SensorMultilevel:Get({sensor_type = SensorMultilevel.sensor_type.ACCELERATION_Z_AXIS, scale = SensorMultilevel.scale.acceleration_z_axis.METERS_PER_SQUARE_SECOND}, {dst_channels = {endpoint}})
    }
  end
end

--- @class st.zwave.defaults.threeAxis
--- @alias three_axis_defaults st.zwave.defaults.threeAxis
--- @field public zwave_handlers table
--- @field public get_refresh_commands function
local three_axis_defaults = {
  zwave_handlers = {
    [cc.SENSOR_MULTILEVEL] = {
      [SensorMultilevel.REPORT] = three_axis_report_handler
    }
  },
  get_refresh_commands = get_refresh_commands
}

return three_axis_defaults
