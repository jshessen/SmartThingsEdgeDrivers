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

local capabilities = require "st.capabilities"
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

--- @type string
local CAP_CACHE_KEY = "st.capabilities." .. capabilities.colorControl.ID

--- @local (table)
local color = {
  map = {
    [0] = {name = "Off",     value = 0, hex = "000000", constant = 0},
    [1] = {name = "Red",     value = 1, hex = "FF0000", constant = SwitchColor.color_component_id.RED},       -- RED=2
    [2] = {name = "Green",   value = 2, hex = "00FF00", constant = SwitchColor.color_component_id.GREEN},     -- GREEN=3
    [3] = {name = "Blue",    value = 3, hex = "0000FF", constant = SwitchColor.color_component_id.BLUE},      -- BLUE=4
    [4] = {name = "Magenta", value = 4, hex = "FF00FF", constant = SwitchColor.color_component_id.PURPLE},    -- PURPLE=7
    [5] = {name = "Yellow",  value = 5, hex = "FFFF00", constant = SwitchColor.color_component_id.AMBER},     -- AMBER=5
    [6] = {name = "Cyan",    value = 6, hex = "00FFFF", constant = SwitchColor.color_component_id.CYAN},      -- CYAN=6
    [7] = {name = "White",   value = 7, hex = "FFFFFF", constant = SwitchColor.color_component_id.COLD_WHITE} -- COLD_WHITE=1
  }
}
---
--- ???????????????????????????????????????????????????????

--- #######################################################
---

--- @function hex_to_rgb() --
--- Function that converts hexadecimal color code to RGB color
--- @param hex (string) The hexadecimal string to convert to RGB
--- @return (number)|(nil) red, (number)? green, (number)? blue RGB values as numbers between 0 and 255, or nil if hex is invalid
function color.hex_to_rgb(hex)
  -- Check if the input is a string
  if type(hex) ~= "string" then
    log.error("Invalid argument: expected string, got " .. type(hex), 2)
  end
  
  -- Remove the "#" symbol from the hexadecimal string
  hex = hex:gsub("#", "")
  
  -- Check if the hexadecimal string is valid
  if not hex:match("%x%x%x%x%x%x") then
    return nil -- Return nil if hex is invalid
  end
  
  -- Check if the hexadecimal string is 3 characters long
  if #hex == 3 then
    hex = hex:gsub(".", "%1%1")
  end
  
  local r = tonumber(hex:sub(1, 2), 16)
  local g = tonumber(hex:sub(3, 4), 16)
  local b = tonumber(hex:sub(5, 6), 16)
  
  return r, g, b
end
---
--- #######################################################

--- #######################################################
---

--- @function color.set_switch_color() --
--- This function is used to set the RGB switch color for the given device
--- @param device (st.zwave.Device) The device to set the color for
--- @param command (Command) The command to set the color
--- @param r (number) The red value (0-255)
--- @param g (number) The green value (0-255)
--- @param b (number) The blue value (0-255)
--- @return (boolean) true if the color was set successfully, false otherwise
function color.set_switch_color(device, command, r, g, b)
  if not device or not command or not r or not g or not b then
    log.error("Invalid input")
    return false
  end

  local hue, saturation, mylightness = utils.rgb_to_hsl(r, g, b)
  log.trace(string.format("***** HSM200 Driver *****: myhue=%s,mysat=%s", device:pretty_print(),hue, saturation))
  command.args.color = {
    hue = hue,
    saturation = saturation,
  }
  device:set_field(CAP_CACHE_KEY, command)

  local dim_duration = constants.DEFAULT_DIMMING_DURATION
  local set = SwitchColor:Set({
    color_components = {
      { color_component_id = SwitchColor.color_component_id.RED, value = r },
      { color_component_id = SwitchColor.color_component_id.GREEN, value = g },
      { color_component_id = SwitchColor.color_component_id.BLUE, value = b },
      { color_component_id = SwitchColor.color_component_id.WARM_WHITE, value = 0 },
      { color_component_id = SwitchColor.color_component_id.COLD_WHITE, value = 0 },
    },
    duration = dim_duration
  })
  device:send_to_component(set, command.component)

  local color_check = function()
    -- Use a single RGB color key to trigger our callback to emit a color
    -- control capability update.
    device:send_to_component(
      SwitchColor:Get({ color_component_id = SwitchColor.color_component_id.RED }),
      command.component
    )
  end
  device.thread:call_with_delay(constants.DEFAULT_GET_STATUS_DELAY, color_check)
  return true
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

  -- Initialize the closest color to White (index 7 in color.map)
  -- and the distance to the farthest possible value (255 * sqrt(3))
  local closest_color = color.map[7]
  local closest_dist = 255 * math.sqrt(3.0)

  -- Iterate through color.map and find the closest color
  for _, clr in ipairs(color.map) do
    local r1, g1, b1 = color.hex_to_rgb(clr.hex)
    local newdist = math.sqrt((r - r1)^2 + (g - g1)^2 + (b - b1)^2)
    if newdist < closest_dist then
      closest_dist = newdist
      closest_color = clr
    end
  end

  -- Throw an error if the closest color couldn't be found
  if not closest_color then
    log.error("Couldn't find closest color")
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