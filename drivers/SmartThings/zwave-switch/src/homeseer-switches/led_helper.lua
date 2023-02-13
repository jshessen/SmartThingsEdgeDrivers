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

-- @type st.capabilities
local capabilities = require "st.capabilities"
-- @type st.utils
local utils = require "st.utils"
--- @type st.zwave.CommandClass.Configuration
local Configuration = (require "st.zwave.CommandClass.Configuration")({ version = 2 })
--- @type SwitchBinary
local SwitchBinary = (require "st.zwave.CommandClass.SwitchBinary")({version = 2, strict = true})

--- Misc
--- @type table
local preferencesMap = (require "preferences")
-- @type table
local helpers = {}
helpers.color = (require "color_helper")
---
--- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

--- #################################################################
--- Section: LED Management
---
-- ???????????????????????????????????????????????????????
--- Variables/Constants
---

--- @local (string)
local CAP_CACHE_KEY = "st.capabilities." .. capabilities.colorControl.ID
--- @local (table)
local led = {}
---
--- ???????????????????????????????????????????????????????

--- #######################################################
---

--- @function led.set_led_color() --
--- Sets component color to closes supported color match
--- @param device (st.zwave.Device) The device object
--- @param command (table) Input command value
--- @return (nil)
function led.set_led_color(device, command)
  local preferences = preferencesMap.get_device_parameters(device)
  -- LED-# => ledStatusColor#
  local component = "ledStatusColor" .. string.sub(command.component,string.find(command.component,"-")+1)
  if preferences and preferences[component] then
    local color
    if command.args.color.hue and command.args.color.saturation then
      -- Find the closest color to the command's hue, saturation, and lightness values
      color = helpers.color.find_closest_color(command.args.color.hue, command.args.color.saturation, command.args.color.lightness)
    end
    -- If color is not defined, check the device.preferences, if neither is defined set to White=7
    local pref_color = tonumber(device.preferences[component])
    local color_index = color.value or (pref_color ~= 0 and pref_color) or 7
    color = helpers.color.map[color_index]
    
    -- Convert the color from hex to RGB and then to HSL
    local r, g, b = helpers.color.hex_to_rgb(color.hex)
    local hue, saturation, lightness = utils.rgb_to_hsl(r,g,b)
    -- Update the device hue, and saturation values
    command.args.color.hue = hue
    command.args.color.saturation = saturation
    device:set_field(CAP_CACHE_KEY, command)
  
    -- Determine the value of the status LED based on the hue and saturation values
    local value = (hue == 0 and saturation == 0) and SwitchBinary.value.OFF_DISABLE or SwitchBinary.value.ON_DISABLE
    
    -- If value is OFF_DISABLE, use value; otherwise use color
    value = value == SwitchBinary.value.OFF_DISABLE and value or color
    local set = Configuration:Set({parameter_number = preferences[component].parameter_number, 
                            size = preferences[component].size,
                            configuration_value = value})
    -- Update the status LED of the device
    device:send(set)
  end
end
---
--- #######################################################
---
--- #################################################################

--- /////////////////////////////////////////////////////////////////
--- Return
---

return led
---
--- /////////////////////////////////////////////////////////////////