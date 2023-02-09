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
--- @type st.zwave.Device
local st_device = require "st.zwave.device"
-- @type st.zwave.CommandClass
local cc = require "st.zwave.CommandClass"
--- @type st.zwave.CommandClass.Configuration
local Configuration = (require "st.zwave.CommandClass.Configuration")({ version = 2 })
--- @type st.zwave.defaults.colorControl
local colorControl = (require "st.zwave.defaults.colorControl")

-- @type st.zwave.constants
local constants = require "st.zwave.constants"
-- @type st.utils
local utils = require "st.utils"
-- @type log
local log = require "log"


--- Switch
--- @type Basic
local Basic = (require "st.zwave.CommandClass.Basic")({version = 2, strict = true})
--- @type SwitchBinary
local SwitchBinary = (require "st.zwave.CommandClass.SwitchBinary")({version = 2, strict = true})

--- Dimmer
--- @type SwitchMultilevel
local SwitchMultilevel = (require "st.zwave.CommandClass.SwitchMultilevel")({version = 4})

--- Color
--- @type SwitchColor
local SwitchColor = (require "st.zwave.CommandClass.SwitchColor")({version = 3, strict = true})

--- Button
--- @type CentralScene
local CentralScene = (require "st.zwave.CommandClass.CentralScene")({version = 1})

--- Misc
--- @type Version
local Version = (require "st.zwave.CommandClass.Version")({version = 3})
--- @type table
local preferencesMap = require "preferences"
---
--- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



--- #################################################################
--- Section: Can Handle
---
--- ???????????????????????????????????????????????????????
--- Variables/Constants
---

--- Map HomeSeer Fingerprints
--- @local (table)
local HOMESEER_SWITCH_FINGERPRINTS = {
  {id = "HomeSeer/Switch/WS100",  mfr = 0x000C, prod = 0x4447, model = 0x3033}, -- HomeSeer WS100 Switch
  {id = "HomeSeer/Dimmer/WD100",  mfr = 0x000C, prod = 0x4447, model = 0x3034}, -- HomeSeer WD100 Dimmer
  {id = "HomeSeer/Switch/WS200",  mfr = 0x000C, prod = 0x4447, model = 0x3035}, -- HomeSeer WS200 Switch
  {id = "HomeSeer/Dimmer/WD200",  mfr = 0x000C, prod = 0x4447, model = 0x3036}, -- HomeSeer WD200 Dimmer
  {id = "HomeSeer/Dimmer/WX300D", mfr = 0x000C, prod = 0x4447, model = 0x4036}, -- HomeSeer WX300 Dimmer
  {id = "HomeSeer/Dimmer/WX300S", mfr = 0x000C, prod = 0x4447, model = 0x4037}, -- HomeSeer WX300 Switch
  {id = "ZLink/Switch/WS100",     mfr = 0x0315, prod = 0x4447, model = 0x3033}, -- ZLink ZL-WS-100 Switch - ZWaveProducts.com
  {id = "ZLink/Dimmer/WD100",     mfr = 0x0315, prod = 0x4447, model = 0x3034}, -- ZLink ZL-WD-100 Dimmer - ZWaveProducts.com
}
---
--- ???????????????????????????????????????????????????????

--- #######################################################
---

--- @function can_handle_homeseer_switches --
--- Determine whether the passed device is a HomeSeer switch.
--- Iterates over the fingerprints in `HOMESEER_SWITCH_FINGERPRINTS` and
--- checks if the device's id matches the fingerprint's manufacturer, product, and model id.
--- If a match is found, the function returns true, else it returns false.
--- @param opts (table)
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @vararg ... any
--- @return (boolean)
local function can_handle_homeseer_switches(opts, driver, device, ...)
  for _, fingerprint in ipairs(HOMESEER_SWITCH_FINGERPRINTS) do
    if device:id_match(fingerprint.mfr, fingerprint.prod, fingerprint.model) then
      log.info(string.format("%s [%s] : %s - mfr=0x%04x, prod=0x%04x, model=0x%04x", device.id, device.device_network_id, fingerprint.id, device.zwave_manufacturer_id, device.zwave_product_type, device.zwave_product_id))
      return true
    end
  end
  return false
end
---
--- #######################################################
---
--- #################################################################



--- #################################################################
--- Section: Handlers (Z-Wave and Capability)
---
--- ############################################################
--- Subsection: Switch (Basic/SwitchBinary/SwitchMultilevel)
---
-- ???????????????????????????????????????????????????????
--- Variables/Constants
---

--- Map HomeSeer Colors to SmartThings Constants
--- @local (table)
local HOMESEER_COLOR_MAP = {
  {name = "Off", value = 0, hex = "000000", constant = 0},
  {name = "Red", value = 1, hex = "FFOOOO", constant = SwitchColor.color_component_id.RED}, -- RED=2
  {name = "Green", value = 2, hex = "OOFFOO", constant = SwitchColor.color_component_id.GREEN}, -- GREEN=3
  {name = "Blue", value = 3, hex = "OOOOFF", constant = SwitchColor.color_component_id.BLUE}, -- BLUE=4
  {name = "Magenta", value = 4, hex = "FFOOFF", constant = SwitchColor.color_component_id.PURPLE}, -- PURPLE=7
  {name = "Yellow", value = 5, hex = "FFFFOO", constant = SwitchColor.color_component_id.AMBER}, -- AMBER=5
  {name = "Cyan", value = 6, hex = "OOFFFF", constant = SwitchColor.color_component_id.CYAN}, -- CYAN=6
  {name = "White", value = 7, hex = "FFFFFF", constant = SwitchColor.color_component_id.COLD_WHITE} -- COLD_WHITE=1
}
--- @local (string)
local CAP_CACHE_KEY = "st.capabilities." .. capabilities.colorControl.ID
--- @local (string)
local ZW_CACHE_PREFIX = "st.zwave.SwitchColor."
---
--- ???????????????????????????????????????????????????????

--- #######################################################
---

--- @function status_led_handler --
--- Handles Status LED functionality
--- @param device (st.zwave.Device) The device object
--- @param component (string) String 'name' of the component
--- @param value (number) On/Off constant value
--- @param color? (integer) Color value
--- @return (nil)
local function status_led_handler(device, component, value, color)
  local preferences = preferencesMap.get_device_parameters(device)
  local set

  if preferences and preferences[component] then
    -- If color is not defined, check the device.preferences, if neither is defined set to White=7
    log.debug(string.format("%s [%s] : color=%s", device.id, device.device_network_id, color))
    local pref_color = tonumber(device.preferences[component])
    local color = color or (pref_color ~= 0 and pref_color) or 7
    log.debug(string.format("%s [%s] : color=%s", device.id, device.device_network_id, color))

    -- If value is OFF_DISABLE, use value; otherwise use color
    value = value == SwitchBinary.value.OFF_DISABLE and value or color
    set = Configuration:Set({parameter_number = preferences[component].parameter_number, 
                            size = preferences[component].size,
                            configuration_value = value})
    device:send(set)
  end
end
---
--- #######################################################

--- #######################################################
---

--- @function hex_to_rgb --
--- Function that converts hexadecimal color code to RGB color
--- @param hex (string)
--- @return number, number, number equivalent red, green, blue with each color in range [0,1]
local function hex_to_rgb(hex)
  -- Remove the "#" symbol from the hexadecimal string
  hex = hex:gsub("#", "")
  log.debug(string.format("hex=%s", hex))
  
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
  log.debug(string.format("r=%s, g=%s, b=%s", r,g,b))
  -- Return the RGB values as a tuple
  return r, g, b
end
---
--- #######################################################

--- #######################################################
---

--- @function find_closest_color --
--- Function to find the closest color in HOMESEER_COLOR_MAP to the specified hue and saturation
--- @param hue (number) hue in the range [0,100]%
--- @param saturation (number) saturation in the range [0,100]%
--- @param lightness (number) lightness in the range [0,100]%, or nil
--- @return (table) HOMESEER_COLOR_MAP corresponding
local function find_closest_color(hue, saturation, lightness)
  -- Convert the given hue and saturation to RGB color
  local r, g, b = utils.hsl_to_rgb(hue, saturation, lightness)

  -- Initialize the closest color to White (index 8 in HOMESEER_COLOR_MAP)
  -- and the distance to the farthest possible value (255 * sqrt(3))
  local closest_color = HOMESEER_COLOR_MAP[8]
  local closest_dist = 255 * math.sqrt(3.0)

  -- Iterate through HOMESEER_COLOR_MAP and find the closest color
  for _, color in ipairs(HOMESEER_COLOR_MAP) do
    log.debug(string.format("find_closest_color - name=%s color=%s", color.name,color.value))
    local r1, g1, b1 = hex_to_rgb(color.hex)
    local newdist = math.sqrt((r - r1)^2 + (g - g1)^2 + (b - b1)^2)
    log.debug(string.format("newdist-%s < closest_dis-%s", newdist,closest_dist))
    if newdist < closest_dist then
      closest_dist = newdist
      closest_color = color
    end
    log.debug(string.format("find_closest_color - closest_color=%s", closest_color.value))
  end
  log.debug(string.format("find_closest_color - closest_color=%s", closest_color.value))
  -- Return the closest color
  return closest_color
end
---
--- #######################################################

--- #######################################################
---

--- @function local function switch_color_handler --
--- Sets component color to closes supported color match
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @param command (table) Input command value
--- @return (nil)
local function switch_color_handler(driver, device, command)
  log.debug(string.format("%s [%s] : switch_color_handler", device.id, device.device_network_id))
  local dimmingDuration = command.args.rate or constants.DEFAULT_DIMMING_DURATION
  -- Find the closest color to the command's hue, saturation, and lightness values
  local color = find_closest_color(command.args.color.hue, command.args.color.saturation, command.args.color.lightness)
  log.debug(string.format("%s [%s] : switch_color_handler - color=%s", device.id, device.device_network_id, color.value))
  -- Convert the color from hex to RGB and then to HSL
  local r, g, b = hex_to_rgb(color.hex)
  local hue, saturation, lightness = utils.rgb_to_hsl(r,g,b)
  -- Update the device hue, and saturation values
  command.args.color.hue = hue
  command.args.color.saturation = saturation
  device:set_field(CAP_CACHE_KEY, command)
  
  -- Create an array of color components
  local set = SwitchColor:Set({
    color_components = {
      { color_component_id=SwitchColor.color_component_id.RED, value=r },
      { color_component_id=SwitchColor.color_component_id.GREEN, value=g },
      { color_component_id=SwitchColor.color_component_id.BLUE, value=b },
      { color_component_id=SwitchColor.color_component_id.WARM_WHITE, value=0 },
      { color_component_id=SwitchColor.color_component_id.COLD_WHITE, value=0 },
    },
    duration=dimmingDuration
  })
  --device:send_to_component(set, command.component)
  
  -- LED-# => ledStatusColor#
  local component = "ledStatusColor" .. string.sub(command.component,string.find(command.component,"-")+1)
  -- Determine the value of the status LED based on the hue and saturation values
  local value = (hue == 0 and saturation == 0) and SwitchBinary.value.OFF_DISABLE or SwitchBinary.value.ON_DISABLE
  -- Update the status LED of the device
  status_led_handler(device, component, value, color.value)
end
---
--- #######################################################

--- #######################################################
---

--- @function switch_binary_handler --
--- Handles "on/off" functionality
--- @param value (st.zwave.CommandClass.SwitchBinary.value)
--- @return (function)
local function switch_binary_handler(value)
  --- Handles "on/off" functionality
  --- @param driver (Driver) The driver object
  --- @param device (st.zwave.Device) The device object
  --- @param command (Command) Input command value
  --- @return (nil)
  return function(driver, device, command)
    if command.component == "main" then
      local set = Basic:Set({value = value})
      device:send_to_component(set, command.component)
      local get = function()
        device:send_to_component(SwitchBinary:Get({}), command.component)
      end
      device.thread:call_with_delay(constants.DEFAULT_GET_STATUS_DELAY, get)
    else
      -- LED-# => ledStatusColor#
      local component = "ledStatusColor" .. string.sub(command.component,string.find(command.component,"-")+1)
      if device:supports_capability(capabilities.colorControl,nil) then
        --device:send_to_component(SwitchColor.Report({value =
        log.debug(string.format("%s [%s] : I can do Color!", device.id, device.device_network_id))
      end
      status_led_handler(device, component, value)
    end
  end
end
---
--- #######################################################

--- #######################################################
---

--- @function switch_multilevel_handler --
--- Handles "dimmer/level" functionality
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @param command (Command) Input command value
--- @return (nil)
local function switch_multilevel_handler(driver, device, command)
  -- Declare local variables 'level' and 'dimmingDuration'
  local level = command.args.level and utils.clamp_value(math.floor(command.args.level + 0.5), 0, 99)
  local dimmingDuration = command.args.rate or constants.DEFAULT_DIMMING_DURATION
  
  -- Emit switch on or off event depending on the value of 'level'
  device:emit_event(level and level > 0 and capabilities.switch.switch.on() or capabilities.switch.switch.off())

  -- If the device supports switch level capability
  if device:supports_capability(capabilities.switchLevel, nil) then
    local set = SwitchMultilevel:Set({value = level, duration = dimmingDuration })
    device:send_to_component(set, command.component)
    local get = function()
      device:send_to_component(SwitchBinary:Get({}), command.component)
    end
    device.thread:call_with_delay(constants.DEFAULT_GET_STATUS_DELAY, get)
  end
end

---
--- #######################################################

--- #######################################################
---

--- @function switch_multilevel_stop_level_change_handler --
--- Handles the stopping of a switch level change on Z-Wave devices
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @param command (Command) Input command value
--- @return (nil)
local function switch_multilevel_stop_level_change_handler(driver, device, command)
  --- Emits an event with the switch capability "on"
  device:emit_event(capabilities.switch.switch.on())
  
  --- Sends a `SwitchMultilevel:Get` command to the device
  device:send(SwitchMultilevel:Get({}))
end
---
--- #######################################################
---
--- ############################################################


--- ############################################################
--- Subsection: Button (Central Scene)
---
--- ???????????????????????????????????????????????????????
--- Variables/Constants
---

--- @local (string)
local LAST_SEQ_NUMBER = "last_sequence_number"

--- @local (table)
local BUTTON_VALUES = {
  "up","up_2x","up_3x","up_4x","up_5x","up_hold",
  "down","down_2x","down_3x","down_4x","down_5x","down_hold",
  "pushed","pushed_2x","pushed_3x","pushed_4x","pushed_5x","held",  
  "double"
}
--- Map Attributes to Capabilities
--- @local (table)
local map_key_attribute_to_capability = {
  [CentralScene.key_attributes.KEY_PRESSED_1_TIME] = {
    [0x01] = {
      capabilities.button.button.up(),
      capabilities.button.button.pushed()
    },
    [0x02] = {
      capabilities.button.button.down(),
      capabilities.button.button.pushed()
    }
  },
  [CentralScene.key_attributes.KEY_PRESSED_2_TIMES] = {
    [0x01] = {
      capabilities.button.button.up_2x(),
      capabilities.button.button.pushed_2x(),
      capabilities.button.button.double()
    },
    [0x02] = {
      capabilities.button.button.down_2x(),
      capabilities.button.button.pushed_2x(),
      capabilities.button.button.double()
    }
  },
  [CentralScene.key_attributes.KEY_PRESSED_3_TIMES] = {
    [0x01] = {
      capabilities.button.button.up_3x(),
      capabilities.button.button.pushed_3x()
    },
    [0x02] = {
      capabilities.button.button.down_3x(),
      capabilities.button.button.pushed_3x()
    }
  },
  [CentralScene.key_attributes.KEY_PRESSED_4_TIMES] = {
    [0x01] = {
      capabilities.button.button.up_4x(),
      capabilities.button.button.pushed_4x()
    },
    [0x02] = {
      capabilities.button.button.down_4x(),
      capabilities.button.button.pushed_4x()
    }
  },
  [CentralScene.key_attributes.KEY_PRESSED_5_TIMES] = {
    -- Up/Down
    [0x01] = {
      capabilities.button.button.up_5x(),
      capabilities.button.button.pushed_5x()
    },
    [0x02] = {
      capabilities.button.button.down_5x(),
      capabilities.button.button.pushed_5x()
    }
  },
  [CentralScene.key_attributes.KEY_HELD_DOWN] = {
    -- Up/Down
    [0x01] = {
      capabilities.button.button.up_hold(),
      capabilities.button.button.held()
    },
    [0x02] = {
      capabilities.button.button.down_hold(),
      capabilities.button.button.held()
    }
  },
  [CentralScene.key_attributes.KEY_RELEASED] = {
    [0x01] = {capabilities.button.button.held()},
    [0x02] = {capabilities.button.button.held()}
  }
}
---
--- ???????????????????????????????????????????????????????

--- #######################################################
---

--- @function central_scene_notification_handler --
--- Handles "Scene" functionality
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @param command (Command) Input command value
--- @return nil
local function central_scene_notification_handler(driver, device, command)
  -- Store the values of sequence number, scene number, and key attributes in local variables
  local seq_number = command.args.sequence_number
  local scene_number = command.args.scene_number
  local key_attributes = command.args.key_attributes

  -- Check if the key attribute is set to KEY_RELEASED
  if (key_attributes == CentralScene.key_attributes.KEY_RELEASED) then
    log.error("Button Value \"released\" is not supported by SmartThings")
    return
  end

    if device:get_field(LAST_SEQ_NUMBER) ~= seq_number then
      device:set_field(LAST_SEQ_NUMBER, seq_number)
    -- Get the events associated with the current scene_number and key_attributes
    local event = map_key_attribute_to_capability[key_attributes][scene_number]
    -- Loop through the events array
    for _, e in ipairs(event) do
      -- Emit the event for the endpoint
      device:emit_event_for_endpoint(command.src_channel, e)
    end
  end
end
---
--- #######################################################
---
--- ############################################################


--- ############################################################
--- Subsection: Dynamic Profiles (Version)
---
--- #######################################################
---

--- @function update_device_profile --
--- Adjust profile definition based upon reported firmware version
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @param args (table)
--- @return (nil)
local function update_device_profile(driver, device, args)
  log.debug(string.format("%s [%s] : operatingMode=%s", device.id, device.device_network_id, device.preferences.operatingMode))
  local operatingMode = tonumber(device.preferences.operatingMode) == 1 and "-status" or ""
  local firmware_version = args.firmware_0_version
  local firmware_sub_version = args.firmware_0_sub_version
  local profile

  -- Iterate through the list of HomeSeer switch fingerprints
  for _, fingerprint in ipairs(HOMESEER_SWITCH_FINGERPRINTS) do
    if device:id_match(fingerprint.mfr, fingerprint.prod, fingerprint.model) then
      log.info(string.format("%s [%s] : %s - Firmware: %s.%s", device.id, device.device_network_id, fingerprint.id, firmware_version, firmware_sub_version))
      profile = "homeseer-" .. string.lower(string.sub(fingerprint.id, fingerprint.id:match'^.*()/'+1)) .. operatingMode


      if fingerprint.id == "HomeSeer/Dimmer/WD200" then
        -- Check if the firmware version and sub-version match certain values
        if firmware_version == 5 and (firmware_sub_version > 11 and firmware_sub_version < 14) then
          -- Update the device's profile and set a field to indicate that the update has occurred
          profile = profile .. "-" .. firmware_version .. "." .. firmware_sub_version
          break
          -- Check if the firmware version and sub-version match certain values
        elseif firmware_version == 5 and firmware_sub_version >= 14 then
          -- Update the device's profile and set a field to indicate that the update has occurred
          profile = profile .. "-" .. "latest"
          break
        end
      -- Check if the fingerprint of the device matches "HomeSeer/Dimmer/WX300S or WX300D"
      elseif fingerprint.id == "HomeSeer/Dimmer/WX300S" or fingerprint.id == "HomeSeer/Dimmer/WX300D" then
        -- Check if the firmware version is greater than 1.12
        if (firmware_version == 1 and firmware_sub_version > 12) then
          -- Set the new profile for the device
          profile = profile .. "-" .. "latest"
          break
        end
      end
    end
  end
  if profile then
    assert (device:try_update_metadata({profile = profile}), "Failed to change device profile")
    log.info(string.format("%s [%s] : Defined Profile: %s", device.id, device.device_network_id, profile))
  end
end
---
--- #######################################################

--- #######################################################
---

--- @function version_report_handler --
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @param command (Command) Input command value
local function version_report_handler(driver, device, command)
  update_device_profile(driver, device, command.args)
end
---
--- #######################################################
---
--- ############################################################
--- Subsection: Firmware Upgrades
---
--- ???????????????????????????????????????????????????????
---

--- @local (table)
local custom_capabilities = {}
custom_capabilities.firmwareVersion = {}
custom_capabilities.firmwareVersion.name = "firmwareVersion"
custom_capabilities.firmwareVersion.capability = capabilities[custom_capabilities.firmwareVersion.name]
---
--- ???????????????????????????????????????????????????????

--- #######################################################
---

--- @function: checkForFirmwareUpdate_handler --
--- Check to see if there is a firmware update available for the device
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @param command (Command) Input command value
--- @return (nil)
local function checkForFirmwareUpdate_handler(driver, device, command)
    --- Check if the device supports Firmware capability
    if (device:supports_capability(capabilities.firmwareUpdate, nil)) then
      log.info_with({hub_logs=true}, string.format("Current Firmware: %s", device.firmware_version))
    end
end
---
--- #######################################################

--- #######################################################
---

--- @function: updateFirmware_handler --
--- Check to see if there is a firmware update available for the device
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @param command (Command) Input command value
--- @return (nil)
local function updateFirmware_handler(driver, device, command)
    --- Check if the device supports Firmware capability
    if (device:supports_capability(capabilities.firmwareUpdate, nil)) then
      log.info_with({hub_logs=true}, string.format("Current Firmware: %s", device.firmware_version))
    end
end
---
--- #######################################################
---
--- ############################################################
---
--- #################################################################



--- #################################################################
--- Section: Helpers/Utilities
---
--- @local (table)
local ENDPOINTS = {
  main = 0,
  led = { 1, 2, 3, 4, 5, 6, 7 }
}
--- #######################################################
---

--- @function component_to_endpoint --
--- Map component to end_points (channels)
--- @param device (st.zwave.Device)
--- @param component_id (string) ID
--- @return table dst_channels destination channels e.g. {2} for Z-Wave channel 2 or {} for unencapsulated
local function component_to_endpoint(device, component_id)
  local ep_num = component_id == "main" and 0 or tonumber(component_id:match("LED-(%d)"))
  return { ep_num }
end
---
--- #######################################################

--- #######################################################
---

--- @function: do_referesh --
--- Refresh Device
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @param command (Command) Input command value
--- @return (nil)
local function do_refresh(driver, device, command)
  --- Determine the component for the command
  local component = command and command.component or "main"
  local capability = device:supports_capability(capabilities.switch, component) and capabilities.switch or
                      device:supports_capability(capabilities.switchLevel, component) and capabilities.switchLevel
  --- Check if the device supports switch level capability
  if capability then
    device:send_to_component(capability == capabilities.switch and SwitchBinary:Get({}) or SwitchMultilevel:Get({}), component)
  end
end
---
--- #######################################################

--- #######################################################
---

--- @function call_parent_handler --
--- Invoke handlers for a specific event
--- @param handlers (function|table) Function or tables of functions to call as event handlers.
--- @param self (Driver) Reference to the current object
--- @param device (st.zwave.Device) Device object that is added
--- @param event (Event)
--- @param args (any)
local function call_parent_handler(handlers, self, device, event, args)
  -- check if `handlers` is not a table; if true wrap as table
  local handlers_table = (type(handlers) == "function" and { handlers } or handlers) --[[@as table]];
  -- Invoke each function in the handlers table and pass the provided arguments.
  for i, func in pairs( handlers_table or {} ) do
      func(self, device, event, args)
  end
end
---
--- #######################################################
---
--- #################################################################



--- #################################################################
--- Section: Lifecycle Handlers
---
--- #######################################################

--- #######################################################
---

--- @function device_init --
--- Initialize device
--- @param self (Driver) Reference to the current object
--- @param device (st.zwave.Device) Device object that is added
--- @param event (Event)
--- @param args (any)
local function device_init(self, device, event, args)
  --- Check if the network type is not ZWAVE
  if device.network_type ~= st_device.NETWORK_TYPE_ZWAVE then
    return
  end

  --- Log the device init message
  log.info(string.format("%s: %s > DEVICE INIT", device.id, device.device_network_id))
  
  --- Set the component to endpoint function for the device
  device:set_component_to_endpoint_fn(component_to_endpoint)

  --- Call the init lifecycle handler
  call_parent_handler(self.lifecycle_handlers.init, self, device, event, args)
end
---
--- #######################################################

--- #######################################################
---

--- @function info_changed
--- @param self (Driver) Reference to the current object
--- @param device (st.zwave.Device) Device object that is added
--- @param event (Event)
--- @param args (any)
local function info_changed(self, device, event, args)
  --- Log the device id and network id
  log.info(string.format("%s: %s > INFO_CHANGED", device.id, device.device_network_id))
    --- Check if the operating mode has changed
    if args.old_st_store.preferences.operatingMode ~= device.preferences.operatingMode then
        -- We may need to update our device profile
        device:send(Version:Get({}))
    end
  -- Call the topmost "infoChanged" lifecycle hander to do any default work
  call_parent_handler(self.lifecycle_handlers.infoChanged, self, device, event, args)
end
---
--- #######################################################
---
--- #################################################################



--- /////////////////////////////////////////////////////////////////
---  Section: Driver
---
--- ///////////////////////////////////////////////////////
---

local homeseer_switches = {
  NAME = "HomeSeer Z-Wave Switches",
  can_handle = can_handle_homeseer_switches,
  zwave_handlers = {
    --- Switch
    [cc.BASIC] = {
      [Basic.Set] = switch_multilevel_handler,
      [Basic.Report] = switch_multilevel_handler
    },
    [cc.SWITCH_BINARY] = {
      [SwitchBinary.Set] = switch_multilevel_handler,
      [SwitchBinary.Report] = switch_multilevel_handler
    },
    [cc.SWITCH_MULTILEVEL] = {
      [SwitchMultilevel.Set] = switch_multilevel_handler,
      [SwitchMultilevel.Report] = switch_multilevel_handler,
      [SwitchMultilevel.STOP_LEVEL_CHANGE] = switch_multilevel_stop_level_change_handler
    },
    [cc.SWITCH_COLOR] = {
      [SwitchColor.Report] = switch_color_handler
    },
    --- Button
    [cc.CENTRAL_SCENE] = {
      [CentralScene.NOTIFICATION] = central_scene_notification_handler
    },
    --- Return firmware version
    [cc.VERSION] = {
      [Version.REPORT] = version_report_handler
    }
  },
  capability_handlers = {
    [capabilities.refresh.ID] = {
      [capabilities.refresh.commands.refresh.NAME] = do_refresh
    },
    [capabilities.switch.ID] = {
      [capabilities.switch.switch.on.NAME] = switch_binary_handler(SwitchBinary.value.ON_ENABLE),
      [capabilities.switch.switch.off.NAME] = switch_binary_handler(SwitchBinary.value.OFF_DISABLE)
    },
    [capabilities.colorControl.ID] = {
      [capabilities.colorControl.commands.setColor.NAME] = switch_color_handler
    },
    --- Placeholder
    [capabilities.firmwareUpdate] = {
      [capabilities.firmwareUpdate.commands.checkForFirmwareUpdate] = checkForFirmwareUpdate_handler,
      [capabilities.firmwareUpdate.commands.updateFirmware] = updateFirmware_handler
    }
  },
  lifecycle_handlers = {
    init = device_init,
    --added = added_handler,
    --doConfigure = do_configure,
    infoChanged = info_changed,
    --driverSwitched = driver_switched,
    --removed = removed
  }
}
---
--- ///////////////////////////////////////////////////////

return homeseer_switches

--- /////////////////////////////////////////////////////////////////