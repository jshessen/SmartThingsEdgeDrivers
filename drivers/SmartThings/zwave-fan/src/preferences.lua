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
      -- 0 = Indicator ON when load is OFF
      -- 1 = Indicator OFF when load is OFF (DEFAULT)
      reverse = {parameter_number = 4, size = 1},
      -- 0 = Top of Paddle turns load ON (DEFAULT)
      -- 1 = Bottom of Paddle turns load ON
      operatingMode = {parameter_number = 13, size = 1},
      -- Set mode of operation
      -- 0=Normal mode (load status) (DEFAULT)
      -- 1=Status mode (custom status)
      ledNormalColor = {parameter_number = 14, size = 1},
      -- Possible values: 0-6
      -- 0=White (DEFAULT)
      -- 1=Red, 2=Green, 3=Blue, 4=Magenta, 5=Yellow, 6-Cyan
      ledStatusColor1 = {parameter_number = 21, size = 1},
      -- Sets the Status mode LED 1 (bottom) color
      -- Possible values: 0-7
      -- 0=Off (DEFAULT)
      -- 1=Red, 2=Green, 3=Blue, 4=Magenta, 5=Yellow, 6=Cyan, 7=White
      ledStatusColor2 = {parameter_number = 22, size = 1},
      ledStatusColor3 = {parameter_number = 23, size = 1},
      ledStatusColor4 = {parameter_number = 24, size = 1},
      ledBlinkFrequency = {parameter_number = 30, size = 1},
      -- Sets the dimmer Blink frequency for All LEDs in Status mode
      -- Possible values: 0, 1-255
      -- 0=No blink (DEFAULT), 1=100ms ON then 100ms OFF
      --ledBlinkControl = {parameter_number = 31, size = 1},
      -- Sets LED(s) 1-7 to Blink in Status mode
      -- Bitmask defines specific LEDs to enable for blinking:
      -- Note: this decimal value is derived from a hex code calculation based on the following:
      -- Bit 0 = led 1, Bit 1 = led 2, Bit 2 = led 3, Bit 3 = led 4, Bit 4 = led 5, Bit 5 = led 6, Bit 6 = led 7
      -- IE: value of 1 = first LED, 64 = led 7
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
