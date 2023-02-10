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
--- @type st.Device
local st_device = require "st.device"
-- @type st.zwave.CommandClass
local cc = require "st.zwave.CommandClass"
--- @type st.zwave.CommandClass.Configuration
local Configuration = (require "st.zwave.CommandClass.Configuration")({ version = 2 })

-- @type st.utils
local utils = require "st.utils"
-- @type log
local log = require "log"


--- Switch
--- @type st.zwave.CommandClass.Basic
local Basic = (require "st.zwave.CommandClass.Basic")({ version = 2 })
--- @type st.zwave.CommandClass.SwitchMultilevel
local SwitchMultilevel = (require "st.zwave.CommandClass.SwitchMultilevel")({ version = 4 })

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

--- Helpers
local fan_speed_helper = (require "zwave_fan_helpers")
local zwave_fan_3_speed = (require "zwave-fan-3-speed")
local zwave_fan_4_speed = (require "zwave-fan-4-speed")
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
local HOMESEER_FAN_FINGERPRINTS = {
  {mfr = 0x000C, prod = 0x0203, model = 0x0001}, -- HomeSeer FC200 Fan Controller
}
---
--- ???????????????????????????????????????????????????????

--- #######################################################
---

--- @function can_handle_homeseer_fan_controller --
--- Determine whether the passed device is a HomeSeer Fan Contorller.
--- Iterates over the fingerprints in `HOMESEER_FAN_FINGERPRINTS` and
--- checks if the device's id matches the fingerprint's manufacturer, product, and model id.
--- If a match is found, the function returns true, else it returns false.
--- @param opts (table)
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @vararg ... any
--- @return (boolean)
local function can_handle_homeseer_fan_controller(opts, driver, device, ...)
  for _, fingerprint in ipairs(HOMESEER_FAN_FINGERPRINTS) do
    if device:id_match(fingerprint.mfr, fingerprint.prod, fingerprint.model) then
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
--- Section: Local Functions
---
--- ############################################################
--- Subsection: Profile Management
---
--- ???????????????????????????????????????????????????????
--- Variables/Constants
---

---
--- ???????????????????????????????????????????????????????

--- #######################################################
---

--- @function update_device_profile() --
--- Adjust profile definition based upon operatingMode
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
  for _, fingerprint in ipairs(HOMESEER_FAN_FINGERPRINTS) do
    if device:id_match(fingerprint.mfr, fingerprint.prod, fingerprint.model) then
      log.info(string.format("%s [%s] : %s - Firmware: %s.%s", device.id, device.device_network_id, fingerprint.id, firmware_version, firmware_sub_version))
      profile = "homeseer-" .. string.lower(string.sub(fingerprint.id, fingerprint.id:match'^.*()/'+1)) .. operatingMode
    end
  end
  if profile then
    assert (device:try_update_metadata({profile = profile}), "Failed to change device profile")
    log.info(string.format("%s [%s] : Defined Profile: %s", device.id, device.device_network_id, profile))
  end
end
---
--- #######################################################
---
--- ############################################################


--- ############################################################
--- Subsection: LED Management
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
---
--- ???????????????????????????????????????????????????????

--- #######################################################
---

--- @function status_led_handler() --
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
    local pref_color = tonumber(device.preferences[component])
    local color = color or (pref_color ~= 0 and pref_color) or 7

    -- If value is OFF_DISABLE, use value; otherwise use color
    value = value == SwitchMultilevel.value.OFF_DISABLE and value or color
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

--- @function hex_to_rgb() --
--- Function that converts hexadecimal color code to RGB color
--- @param hex (string)
--- @return (number, number, number) equivalent red, green, blue with each color in range [0,1]
local function hex_to_rgb(hex)
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

--- @function find_closest_color() --
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
    local r1, g1, b1 = hex_to_rgb(color.hex)
    local newdist = math.sqrt((r - r1)^2 + (g - g1)^2 + (b - b1)^2)
    if newdist < closest_dist then
      closest_dist = newdist
      closest_color = color
    end
  end
  -- Return the closest color
  return closest_color
end
---
--- #######################################################
---
--- ############################################################
---
--- #################################################################



--- #################################################################
--- Section: Capability Handlers
---
--- ???????????????????????????????????????????????????????
--- Variables/Constants
---

--- @local table
local capability_handlers = {}
---
--- ???????????????????????????????????????????????????????

--- ############################################################
--- Subsection: fanSpeed
---

--- #######################################################
---

--- @function capability_handlers.fan_speed_set() --
--- Issue a level-set command to the specified device.
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @param command (table) ST level capability command
--- @return (nil)
function capability_handlers.fan_speed_set(driver, device, command)
  local operatingMode = tonumber(device.preferences.fanType)
  if device.preferences.fanType then
    fan_speed_helper.capability_handlers.fan_speed_set(driver, device, command, zwave_fan_4_speed.map_fan_4_speed_to_switch_level)
  else
    fan_speed_helper.capability_handlers.fan_speed_set(driver, device, command, zwave_fan_3_speed.map_fan_3_speed_to_switch_level)
  end
end
---
--- #######################################################
---
--- ############################################################
---
--- #################################################################



--- #################################################################
--- Section: Z-Wave Handlers
---
--- ???????????????????????????????????????????????????????
--- Variables/Constants
---

--- @local table
local zwave_handlers = {}
---
--- ???????????????????????????????????????????????????????

--- ############################################################
--- Subsection: SWITCH_MULTILEVEL_HELPER (Switch)
---
--- #######################################################
---

--- @function: zwave_handlers.fan_multilevel_report() --
--- Convert `SwitchMultilevel` level {0 - 99}
--- into `FanSpeed` speed { 0, 1, 2, 3, 4}
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @param command (st.zwave.CommandClass.SwitchMultilevel.Report)
--- @return (nil)
function zwave_handlers.fan_multilevel_report(driver, device, command)
  if device.preferences.fanType then
    fan_speed_helper.capability_handlers.fan_speed_set(driver, device, command, zwave_fan_4_speed.map_switch_level_to_fan_4_speed)
  else
    fan_speed_helper.capability_handlers.fan_speed_set(driver, device, command, zwave_fan_3_speed.map_switch_level_to_fan_3_speed)
  end
end
---
--- #######################################################
---
--- ############################################################


--- ############################################################
--- Subsection: SWITCH_COLOR (Report)
---
--- #######################################################
---

--- @function zwave_handlers.led_color_set() --
--- Sets component color to closest supported color match
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @param command (st.zwave.CommandClass.SwitchColor.Report) Input command value
--- @return (nil)
function zwave_handlers.led_color_set(driver, device, command)
  local color = find_closest_color(command.args.color.hue, command.args.color.saturation, command.args.color.lightness)
  -- Convert the color from hex to RGB and then to HSL
  local r, g, b = hex_to_rgb(color.hex)
  local hue, saturation, lightness = utils.rgb_to_hsl(r,g,b)
  -- Update the device hue, and saturation values
  command.args.color.hue = hue
  command.args.color.saturation = saturation
  device:set_field(CAP_CACHE_KEY, command)
  
  -- LED-# => ledStatusColor#
  local component = "ledStatusColor" .. string.sub(command.component,string.find(command.component,"-")+1)
  -- Determine the value of the status LED based on the hue and saturation values
  local value = (hue == 0 and saturation == 0) and SwitchMultilevel.value.OFF_DISABLE or SwitchMultilevel.value.ON_DISABLE
  -- Update the status LED of the device
  status_led_handler(device, component, value, color.value)
end
--- @local function
capability_handlers.led_color_set = zwave_handlers.led_color_set
---
--- #######################################################
---
--- ############################################################


--- ############################################################
--- Subsection: CENTRAL_SCENE_MANAGER (Button)
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

--- @function zwave_handlers.central_scene_notification() --
--- Handles "Scene" functionality
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @param command (st.zwave.CommandClass.CentralScene.Notification) Input command value
--- @return (nil)
function zwave_handlers.central_scene_notification(driver, device, command)
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
--- Subsection: VERSION (Report)

--- #######################################################
---

--- @function: zwave_handlers.version_report() --
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @param command (st.zwave.CommandClass.Version.Report)
--- @return (nil)
function zwave_handlers.version_report(driver, device, command)
  update_device_profile(driver, device, command.args)
end
---
--- #######################################################
---
--- ############################################################
---
--- #################################################################



--- #################################################################
--- Section: Lifecycle Handlers
---
--- #######################################################
---

--- @function info_changed() --
--- @param self (Driver) Reference to the current object
--- @param device (st.zwave.Device) Device object that is added
--- @param event (Event)
--- @param args (any)
local function info_changed(self, device, event, args)
  --- Check if the operating mode has changed
  if args.old_st_store.preferences.operatingMode ~= device.preferences.operatingMode then
      -- We may need to update our device profile
      device:send(Version:Get({}))
  end
  self.lifecycle_handlers.infoChanged(self, device, event, args)
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

local homeseer_fan_controller = {
  capability_handlers = {
    [capabilities.fanSpeed.ID] = {
      [capabilities.fanSpeed.commands.setFanSpeed.NAME] = capability_handlers.fan_speed_set
    },
    [capabilities.colorControl.ID] = {
      [capabilities.colorControl.commands.setColor.NAME] = capability_handlers.led_color_set --- alias to zwave_handlers.led_color_set
    }
  },
  zwave_handlers = {
    --- Switch
    [cc.BASIC] = {
      [Basic.REPORT] = zwave_handlers.fan_multilevel_report
    },
    [cc.SWITCH_MULTILEVEL] = {
      [SwitchMultilevel.REPORT] = zwave_handlers.fan_multilevel_report
    },
    [cc.SWITCH_COLOR] = {
      [SwitchColor.Report] = zwave_handlers.led_color_set
    },
    --- Button
    [cc.CENTRAL_SCENE] = {
      [CentralScene.NOTIFICATION] = zwave_handlers.central_scene_notification
    },
    --- Return firmware version
    [cc.VERSION] = {
      [Version.REPORT] = zwave_handlers.version_report
    }    
  },
  lifecycle_handlers = {
    --init = device_init,
    --added = added_handler,
    --doConfigure = do_configure,
    infoChanged = info_changed,
    --driverSwitched = driver_switched,
    --removed = removed
  },
  NAME = "HomeSeer Z-Wave Fan Controller",
  can_handle = can_handle_homeseer_fan_controller,
}
---
--- ///////////////////////////////////////////////////////

return homeseer_fan_controller

--- /////////////////////////////////////////////////////////////////