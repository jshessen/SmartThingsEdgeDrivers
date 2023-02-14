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
local log = (require "log")
-- @type table
local helpers = {}
helpers.color = (require "homeseer-switches.color_helper")
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

--- @function led.set_status_color() --
--- Sets component color to closes supported color match
--- @param device (st.zwave.Device) The device object
--- @param command (table) Input command value
--- @return (nil)
function led.set_status_color(device, command)
  -- Retrieve the on/off value from the arguments
  local value = command.args.value
  -- Retrieve the device parameters from the preferences map
  local preferences = preferencesMap.get_device_parameters(device)
  -- Construct the component name by concatenating the string "ledStatusColor" with the number extracted from the command component
  local component = "ledStatusColor" .. string.sub(command.component, string.find(command.component, "-") + 1)
  local color
  
  if value == SwitchBinary.value.ON_ENABLE then
    -- Check if the device parameters exists in the preferences map
    if preferences and preferences[component] then
      -- If the color argument is present in the command
      if command.args.color then
        -- Find the closest color based on hue, saturation, and lightness values
        color = helpers.color.find_closest_color(command.args.color.hue, command.args.color.saturation, command.args.color.lightness)
      else
        -- If color is not defined, check the device.preferences, if neither is defined set to White=7
        local pref_color = tonumber(device.preferences[component]) or 7
        for _,clr in ipairs(helpers.color.map) do
          if pref_color == clr.value then
            color = clr
            break
          end
        end
      end
      
      -- Convert the color from hex to RGB and then to HSL
      local r, g, b = helpers.color.hex_to_rgb(color.hex)
      local hue, saturation, lightness = utils.rgb_to_hsl(r,g,b)
      
      -- Update the hue and saturation values in the command arguments
      command.args.color = {
        hue = hue,
        saturation = saturation
      }
      device:set_field(CAP_CACHE_KEY, command)
      
      -- Determine the value of the status LED based on hue and saturation values
      value = hue == 0 and saturation == 0 and SwitchBinary.value.OFF_DISABLE or SwitchBinary.value.ON_ENABLE
    end
  end
  -- Set value to OFF_DISABLE, or color value
  value = value == SwitchBinary.value.OFF_DISABLE and value or color.value
  
  -- Create the configuration set based on the device parameters and value
  local set = Configuration:Set({
    parameter_number = preferences[component].parameter_number, 
    size = preferences[component].size,
    configuration_value = value
  })
  -- Send the configuration set to the device
  device:send(set)
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