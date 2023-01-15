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
  HOMESEER = {
    MATCHING_MATRIX = {
      mfrs = 0x000C,
      product_types = 0x4447,
      product_ids = {0x3033,0x3035,0x3036}
    },
    CONFIGURATION = {
      {parameter_number = 3, size = 3, configuration_value = 0},
      {parameter_number = 4, size = 2, configuration_value = 0}
    }
  }
  HOMESEER_WD100 = {
    MATCHING_MATRIX = {
      mfrs = 0x000C,
      product_types = 0x4447,
      product_ids = {0x3034},
    },
    CONFIGURATION = {
      {parameter_number = 4, size = 1, configuration_value = 0},
      {parameter_number = 7, size = 1, configuration_value = 1},
      {parameter_number = 8, size = 2, configuration_value = 3},
      {parameter_number = 9, size = 1, configuration_value = 1},
      {parameter_number = 10, size = 2, configuration_value = 3}
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
