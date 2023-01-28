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

--- @type st.zwave.CommandClass.Configuration
local Configuration = (require "st.zwave.CommandClass.Configuration")({ version=4 })

local devices = {
  -- https://docs.homeseer.com/products/sensors/hs-fls100+/hs-fls100+-user-guide
  HOMESEER_FLOODLIGHT_SENSOR = {
    MATCHING_MATRIX = {
      mfrs = 0x000C,
      product_types = {0x0201},
      product_ids = 0x000B
    },
    PARAMETERS = {
      onTime = {parameter_number = 1, size = 2},
      -- Determines how long floodlights stay on after motion sensed	8-720 (seconds) (DEFAULT=180)
      luxThreshold = {parameter_number = 2, size = 2},
      -- Values under this setting will allow motion to control load range 10-900	(DEFAULT=50)
      sensorReportInterval = {parameter_number = 3, size = 2},
      -- Determines how frequently Lux and Temperature values are reported	1-1440 (minutes) (DEFAULT=10)
      notificationReport = {parameter_number = 4, configuration_value = 1, size = 1},
      -- 0 : Disable alert
      -- 1 : Enable alert
      loadControlSensors = {parameter_number = 5, configuration_value = 1, size = 1},
      -- 0 : Load controlled by Z-Wave Only
      -- 1 : Load controlled by Z-Wave and Sensors
      loadControlSensorsMotion = {parameter_number = 6, configuration_value = 0, size = 1},
      -- 0 : Load controlled by Lux and Motion
      -- 1 : Load controlled by Lux Only
      temperatureOffset = {parameter_number = 7, configuration_value = 0x00, size = 1},
      -- 0x9C - 0x64
      -- (offset range : -10.0°C ~ +10.0°C)
      motionSensitivityLevel = {parameter_number = 8, configuration_value = 0, size = 1}
      -- 0: low level, approx. 6m distance (DEFAULT)
      -- 1: mid level, approx. 10m distance
      -- 2: high level, approx. 20m distance
    },
    ASSOCIATION = {
      {grouping_identifier = 1},
      {grouping_identifier = 2}
    },
    NOTIFICATION = {
      -- disable notification-style motion events
      -- {notification_type = 7, notification_status = 0}
    }
  }
}
local preferences = {}

preferences.update_preferences = function(driver, device, args)
  local prefs = preferences.get_device_parameters(device)
  if prefs ~= nil then
    for id, value in pairs(device.preferences) do
      if not (args and args.old_st_store) or (args.old_st_store.preferences[id] ~= value and prefs and prefs[id]) then
        local new_parameter_value = preferences.to_numeric_value(device.preferences[id])
        device:send(Configuration:Set({parameter_number = prefs[id].parameter_number, size = prefs[id].size, configuration_value = new_parameter_value}))
      end
    end
  end
end

preferences.get_device_parameters = function(zw_device)
  for _, device in pairs(devices) do
    if zw_device:id_match(
      device.MATCHING_MATRIX.mfrs,
      device.MATCHING_MATRIX.product_types,
      device.MATCHING_MATRIX.product_ids) then
      return device.PARAMETERS
    end
  end
  return nil
end

preferences.to_numeric_value = function(new_value)
  local numeric = tonumber(new_value)
  if numeric == nil then -- in case the value is boolean
    numeric = new_value and 1 or 0
  end
  return numeric
end

return preferences
