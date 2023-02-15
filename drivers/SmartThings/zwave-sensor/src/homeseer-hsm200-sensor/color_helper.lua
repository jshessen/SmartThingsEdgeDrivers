--- &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
--- Author: Jeff Hessenflow (jshessen)
---
--- Copyright 2022 SmartThings
---
--- Licensed under the Apache License, Version 2.0 (the "License");
--- you may not use this file except in compliance with the License.
--- You may obtain a copy of the License at
---
---     http://www.apache.org/licenses/LICENSE-2.0
---
--- Unless required by applicable law or agreed to in writing, software
--- distributed under the License is distributed on an "AS IS" BASIS,
--- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--- See the License for the specific language governing permissions and
--- limitations under the License.
---
--- &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

--- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--- Required Libraries
---

-- @type st.utils
local utils = require "st.utils"
--- @type SwitchColor
local SwitchColor = (require "st.zwave.CommandClass.SwitchColor")({version = 3, strict = true})
-- @type st.zwave.constants
local constants = require "st.zwave.constants"
local log = (require "log")
---
--- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

--- #################################################################
--- Section: Color Management
---
-- ???????????????????????????????????????????????????????
--- Variables/Constants
---

--- @local (table)
local color = {}
--- Map HomeSeer Colors to SmartThings Constants
--- @local (table)
HOMESEER_COLOR_MAP = {
  {name = "Off", value = 0, hex = "000000", constant = 0},
  {name = "Red", value = 1, hex = "FFOOOO", constant = SwitchColor.color_component_id.RED}, -- RED=2
  {name = "Green", value = 2, hex = "OOFFOO", constant = SwitchColor.color_component_id.GREEN}, -- GREEN=3
  {name = "Blue", value = 3, hex = "OOOOFF", constant = SwitchColor.color_component_id.BLUE}, -- BLUE=4
  {name = "Magenta", value = 4, hex = "FFOOFF", constant = SwitchColor.color_component_id.PURPLE}, -- PURPLE=7
  {name = "Yellow", value = 5, hex = "FFFFOO", constant = SwitchColor.color_component_id.AMBER}, -- AMBER=5
  {name = "Cyan", value = 6, hex = "OOFFFF", constant = SwitchColor.color_component_id.CYAN}, -- CYAN=6
  {name = "White", value = 7, hex = "FFFFFF", constant = SwitchColor.color_component_id.COLD_WHITE} -- COLD_WHITE=1
}
color.map = HOMESEER_COLOR_MAP
---
--- ???????????????????????????????????????????????????????

--- #######################################################
---

--- @function hex_to_rgb() --
--- Function that converts hexadecimal color code to RGB color
--- @param hex (string)
--- @return (number), (number), (number) equivalent red, green, blue with each color in range [0,1]
function color.hex_to_rgb(hex)
  -- Remove the "#" symbol from the hexadecimal string
  hex = hex:gsub("#", "")
  
  local r_,g_,b_
  local r, g, b
  -- Check if the hexadecimal string is 3 characters long
  if #hex == 3 then
    r_ = tonumber(hex:sub(1, 1), 16)
    g_ = tonumber(hex:sub(2, 2), 16)
    b_ = tonumber(hex:sub(3, 3), 16)
    r = r_ and (r_ * 17) / 255 or 0
    g = g_ and (g_ * 17) / 255 or 0
    b = b_ and (b_ * 17) / 255 or 0
  else
    r = tonumber(hex:sub(1, 2), 16) or 0
    g = tonumber(hex:sub(3, 4), 16) or 0
    b = tonumber(hex:sub(5, 6), 16) or 0
  end
  -- Return the RGB values as a tuple
  return r, g, b
end
---
--- #######################################################

--- #######################################################
---

--- @function color.set_switch_color() --
--- This function is used to set the RGB switch color for the given device
--- The `r`, `g`, and `b` parameters are all the respective values for
--- red, green, and blue. 
--- @param device (st.zwave.Device) The device object
--- @param command (Command) Input command value
--- @param r (integer) RGB value
--- @param g (integer) RGB value
--- @param b (integer) RGB value
--- @return (nil)
function color.set_switch_color(device,command, r,g,b)
  -- By specifying the color duration in microseconds, we can reduce the
  -- calculation time to find the most efficient time.
  local color_microseconds = (constants.DEFAULT_DIMMING_DURATION * 1e6)
  local set = SwitchColor:Set({
    color_components = {
      { color_component_id=SwitchColor.color_component_id.RED, value=r },
      { color_component_id=SwitchColor.color_component_id.GREEN, value=g },
      { color_component_id=SwitchColor.color_component_id.BLUE, value=b },
      { color_component_id=SwitchColor.color_component_id.WARM_WHITE, value=0 },
      { color_component_id=SwitchColor.color_component_id.COLD_WHITE, value=0 },
    },
    duration=color_microseconds
  })
  device:send_to_component(set, command.component)
  local color_check = function()
    -- Use a single RGB color key to trigger our callback to emit a color
    -- control capability update.
    device:send_to_component(
      SwitchColor:Get({ color_component_id=SwitchColor.color_component_id.RED }),
      command.component
    )
  end
  device.thread:call_with_delay(constants.DEFAULT_GET_STATUS_DELAY, color_check)
end
---
--- #######################################################

--- #######################################################
---

--- @function find_closest_color() --
--- Function to find the closest color in color.map to the specified hue and saturation
--- @param hue (number) hue in the range [0,100]%
--- @param saturation (number) saturation in the range [0,100]%
--- @param lightness (number) lightness in the range [0,100]%, or nil
--- @return (table) color.map corresponding
function color.find_closest_color(hue, saturation, lightness)
  -- Convert the given hue and saturation to RGB color
  local r, g, b = utils.hsl_to_rgb(hue, saturation, lightness)

  -- Initialize the closest color to White (index 8 in color.map)
  -- and the distance to the farthest possible value (255 * sqrt(3))
  local closest_color = color.map[8]
  local closest_dist = 255 * math.sqrt(3.0)

  -- Iterate through HOMESEER_COLOR_MAP and find the closest color
  for _, clr in ipairs(color.map) do
    local r1, g1, b1 = color.hex_to_rgb(clr.hex)
    local newdist = math.sqrt((r - r1)^2 + (g - g1)^2 + (b - b1)^2)
    if newdist < closest_dist then
      closest_dist = newdist
      closest_color = clr
    end
  end
  -- Return the closest color
  return closest_color
end
---
--- #######################################################
---
--- #################################################################

--- /////////////////////////////////////////////////////////////////
--- Return
---

return color
---
--- /////////////////////////////////////////////////////////////////