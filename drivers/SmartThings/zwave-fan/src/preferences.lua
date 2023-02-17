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

local devices = {
  -- https://homeseer.com/wp-content/uploads/2019/11/HS-WD200-Manual-6.pdf
  HOMESEER_FC200 = {
    MATCHING_MATRIX = {
      mfrs = 0x000C,
      product_types = 0x0203,
      product_ids = 0x0001
    },
    PARAMETERS = {
      ledIndicator = {parameter_number = 3, size = 1},
      reverse = {parameter_number = 4, size = 1},
      operatingMode = {parameter_number = 13, size = 1},
      ledNormalColor = {parameter_number = 14, size = 1},
      ledStatusColor1 = {parameter_number = 21, size = 1},
      ledStatusColor2 = {parameter_number = 22, size = 1},
      ledStatusColor3 = {parameter_number = 23, size = 1},
      ledStatusColor4 = {parameter_number = 24, size = 1},
      ledBlinkFrequency = {parameter_number = 30, size = 1},
      ledBlinkControl = {parameter_number = 31, size = 1},
    }
  }
}

local preferences = {}

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
