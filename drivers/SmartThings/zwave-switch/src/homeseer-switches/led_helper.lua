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
--- Sets component color to closest supported color match
--- @param device (st.zwave.Device) The device object
--- @param command (Command) Input command value
--- @return (number)|(nil) color
function led.set_status_color(device, command)
  local preferences = preferencesMap.get_device_parameters(device)
  ---@type number
  local value = command.args.value
  ---@type string
  local component = "ledStatusColor" .. string.sub(command.component, string.find(command.component, "-") + 1)
  ---@type table
  local color = helpers.color.map[7]

  if value == SwitchBinary.value.ON_ENABLE and device:supports_capability(capabilities.colorControl, nil) then
    if command.args.color then
      color = helpers.color.find_closest_color(command.args.color.hue, command.args.color.saturation, command.args.color.lightness)
    else
      color = helpers.color.map[device.preferences[component] and tonumber(device.preferences[component]) or 7]
    end

    ---@type number|nil
    local r, g, b = helpers.color.hex_to_rgb(color.hex)
    if not r then
      log.error(string.format("%s: helpers.color.hex_to_rgb returned nil for color.hex = %s", device:pretty_print(), color.hex))
    end
    ---@type number
    local hue, saturation, lightness = utils.rgb_to_hsl(r, g, b)

    if not command.args.color then
      command.args.color = {}
    end
    command.args.color.hue = hue
    command.args.color.saturation = saturation
    device:set_field(CAP_CACHE_KEY, command)

    --- If the saturation and lightness values are 0, set the value to off
    value = saturation == 0 and lightness == 0 and SwitchBinary.value.OFF_DISABLE or SwitchBinary.value.ON_ENABLE
  end
  --- Set the value to off or the color value
  value = value == SwitchBinary.value.OFF_DISABLE and value or color.value

  --- Get the parameter number and size from the device preferences
  ---@type number
  local parameter_number = preferences[component] and preferences[component].parameter_number
  ---@type number
  local size = preferences[component] and preferences[component].size

  if not parameter_number or not size then
    --- If the parameter number or size is missing, log an error and return
    log.error(string.format("%s: Missing parameter number or size for component %s", device:pretty_print(), component))
    return nil
  end
  --- Create a configuration set based on the parameter number, size, and value
  local set = Configuration:Set({
    parameter_number = parameter_number,
    size = size,
    configuration_value = value
  })
  device:send(set)
  return value
end
---
--- #######################################################

--- #######################################################
---

--- @function led.set_blink_bitmask() --
--- Sets LED to blink based upon preference settings
--- @param device (st.zwave.Device) The device object
--- @return (nil)
function led.set_blink_bitmask(device)
  local preferences = preferencesMap.get_device_parameters(device)
  local blink_ctrl = "ledBlinkControl"
  local count = device:component_count() - 1
  local blink_freq = device.preferences["ledBlinkFrequency"] & 0xFF
  local bitmask = 0

  local blink_enabled
  for id = 1, count do
    local blink_id = "ledStatusBlink" .. id
    blink_enabled = device.preferences[blink_id] and (blink_freq ~= 0)
    if blink_enabled then
      bitmask = bitmask | (1 << (id - 1))
    end
    device:set_field(blink_id,blink_enabled)
  end

  local set = Configuration:Set({
    parameter_number = preferences[blink_ctrl].parameter_number,
    size = preferences[blink_ctrl].size,
    configuration_value = bitmask
  })
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