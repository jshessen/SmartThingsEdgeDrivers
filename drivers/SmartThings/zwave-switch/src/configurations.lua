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
  HOMESEER_WS100 = {
    MATCHING_MATRIX = {
      mfrs = 0x000C,
      product_types = 0x4447,
      product_ids = 0x3033
    },
    PARAMETERS = {
      ledIndicator = {parameter_number = 3, size = 1, configuration_value = 0},
      invertSwitch = {parameter_number = 4, size = 1, configuration_value = 0}
    }
  },
  -- https://homeseer.com/wp-content/uploads/2020/09/HS-WD100-Manual-7.pdf
  HOMESEER_WD100 = {
    MATCHING_MATRIX = {
      mfrs = 0x000C,
      product_types = 0x4447,
      product_ids = 0x3034
    },
    PARAMETERS = {
      invertSwitch = {parameter_number = 4, size = 1, configuration_value = 0}, 
      dimmingSpeedZWave = {parameter_number = 7, size = 1, configuration_value = 1},
      rampRateZWave = {parameter_number = 8, size = 2, configuration_value = 3},
      dimmingSpeed = {parameter_number = 9, size = 1, configuration_value = 1},
      rampRate = {parameter_number = 10, size = 2, configuration_value = 3},
    }
  },
  -- https://homeseer.com/wp-content/uploads/2019/11/HS-WS200-Manual-v8a.pdf
  HOMESEER_WS200 = {
    MATCHING_MATRIX = {
      mfrs = 0x000C,
      product_types = 0x4447,
      product_ids = 0x3035
    },
    PARAMETERS = {
      ledIndicator = {parameter_number = 3, size = 1, configuration_value = 0},
      invertSwitch = {parameter_number = 4, size = 1, configuration_value = 0},
      centralSceneConrol = {parameter = 6, size = 1, configuration_value = 0},
      operatingMode = {parameter_number = 13, size = 1, configuration_value = 0},
      ledNormalColor = {parameter_number = 14, size = 1, configuration_value = 0},
      ledStatusColor = {parameter_number = 21, size = 1, configuration_value = 0},
      ledBlinkFrequency = {parameter_number = 31, size = 1, configuration_value = 0},
    }
  },
  -- https://homeseer.com/wp-content/uploads/2019/11/HS-WD200-Manual-6.pdf
  HOMESEER_WD200 = {
    MATCHING_MATRIX = {
      mfrs = 0x000C,
      product_types = 0x4447,
      product_ids = 0x3036
    },
    PARAMETERS = {
      ledIndicator = {parameter_number = 3, size = 1, configuration_value = 1},
      invertSwitch = {parameter_number = 4, size = 1, configuration_value = 0},
      minimumDimLevel = {parameter_number = 5, size = 1, configuration_value = 0},
      centralSceneConrol = {parameter = 6, size = 1, configuration_value = 0},
      rampRateZWave = {parameter_number = 11, size = 1, configuration_value = 3},
      rampRate = {parameter_number = 12, size = 1, configuration_value = 3},
      operatingMode = {parameter_number = 13, size = 1, configuration_value = 0},
      ledNormalColor = {parameter_number = 14, size = 1, configuration_value = 0},
      ledStatusColor = {parameter_number = 21, size = 1, configuration_value = 0},
      ledStatusColor2 = {parameter_number = 22, size = 1, configuration_value = 0},
      ledStatusColor3 = {parameter_number = 23, size = 1, configuration_value = 0},
      ledStatusColor4 = {parameter_number = 24, size = 1, configuration_value = 0},
      ledStatusColor5 = {parameter_number = 25, size = 1, configuration_value = 0},
      ledStatusColor6 = {parameter_number = 26, size = 1, configuration_value = 0},
      ledStatusColor7 = {parameter_number = 27, size = 1, configuration_value = 0},
      ledBlinkFrequency = {parameter_number = 30, size = 1, configuration_value = 0},
      --ledBlinkControl = {parameter_number = 31, size = 1, configuration_value = 0},
    }
  }
}

local configurations = {}

configurations.get_device_configuration = function(zw_device)
  for _, device in pairs(devices) do
    if zw_device:id_match(
      device.MATCHING_MATRIX.mfrs,
      device.MATCHING_MATRIX.product_types,
      device.MATCHING_MATRIX.product_ids) then
      return device.CONFIGURATION
    end
  end
  return nil
end

return configurations