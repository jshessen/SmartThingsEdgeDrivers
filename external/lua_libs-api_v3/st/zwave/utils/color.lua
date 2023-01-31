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
local utils = require "st.utils"

--- @class st.zwave.utils.color
--- @alias color st.zwave.utils.color
local color = {}

local COLOR_TEMP_MIN = 2700
local COLOR_TEMP_MAX = 6500
-- For Z-Wave devices, we control illumination by crossfading the cold and warm
-- white channels.  But for devices that only have single cold or warm white
-- illumination (as with many RGBW LED strips), we cannot dim either white
-- channel to 0, as this will then completely turn off illumination.
-- Therefore, we lower-bound both white channels to 1.  This will have no
-- perceptible impact for devices that actually support white temperature
-- cross-fading, but will keep devices that do not doing something sane from
-- the user perspective, which is to modify intensity for the single white
local WHITE_MIN = 1 -- min for Z-Wave coldWhite and warmWhite paramaeters
local WHITE_MAX = 255 -- max for Z-Wave coldWhite and warmWhite paramaeters

function color.temp2White(temp)
  temp = utils.clamp_value(temp, COLOR_TEMP_MIN, COLOR_TEMP_MAX)
  local COLOR_TEMP_DIFF = COLOR_TEMP_MAX - COLOR_TEMP_MIN
  local ZWAVE_WHITE_DIFF = WHITE_MAX - WHITE_MIN
  local ww = utils.round((COLOR_TEMP_MAX - temp) / COLOR_TEMP_DIFF * ZWAVE_WHITE_DIFF + WHITE_MIN)
  local cw = utils.round((temp - COLOR_TEMP_MIN) / COLOR_TEMP_DIFF * ZWAVE_WHITE_DIFF + WHITE_MIN)
  return ww, cw
end

function color.white2Temp(ww, cw)
  local COLOR_TEMP_DIFF = COLOR_TEMP_MAX - COLOR_TEMP_MIN
  local ZWAVE_WHITE_DIFF = WHITE_MAX - WHITE_MIN
  local temp = COLOR_TEMP_MIN + (COLOR_TEMP_DIFF / 2)
  if ww ~= cw then
    local a = COLOR_TEMP_MIN + (cw - WHITE_MIN) * (1 / ZWAVE_WHITE_DIFF) * COLOR_TEMP_DIFF
    local b = COLOR_TEMP_MAX - (ww - WHITE_MIN) * (1 / ZWAVE_WHITE_DIFF) * COLOR_TEMP_DIFF
    temp = (a + b) * (1 / 2)
  end
  return utils.round(temp)
end

return color
