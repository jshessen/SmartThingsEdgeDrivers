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

--- Button
--- @type CentralScene
local CentralScene = (require "st.zwave.CommandClass.CentralScene")({version = 1})

--- Misc
--- @type table
local preferencesMap = require "preferences"
--- @type ManufacturerSpecific
local ManufacturerSpecific = (require "st.zwave.CommandClass.ManufacturerSpecific")({ version = 2 })
--- @type Version
local Version = (require "st.zwave.CommandClass.Version")({version = 3})
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
      local args = {}
      args.manufacturer_id = device.zwave_manufacturer_id or 0
      --log.debug(string.format("%s [%s] : %s - mfr=0x%04x=%d", device.id, device.device_network_id, fingerprint.id,args.manufacturer_id,args.manufacturer_id))
      args.product_type_id = device.zwave_product_type or 0
      --log.debug(string.format("%s [%s] : %s - prod=0x%04x=%d", device.id, device.device_network_id, fingerprint.id,args.product_type_id,args.product_type_id))
      args.product_id = device.zwave_product_id or 0
      --log.debug(string.format("%s [%s] : %s - model=0x%04x=%d", device.id, device.device_network_id, fingerprint.id,args.product_id,args.product_id))

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
--- #######################################################
---

--- @function switch_binary_handler --
--- Handles "on/off" functionality
--- @param value (number)
--- @return (function)
local function switch_binary_handler(value)
  --- Handles "on/off" functionality
  --- @param driver (Driver) The driver object
  --- @param device (st.zwave.Device) The device object
  --- @param command (Command) Input command value
  --- @return (nil)
  return function(driver, device, command)
    device:send_to_component(Basic:Set({value = value}), command.component)
    
    --- Calls the function `device:send_to_component(SwitchBinary:Get({}))` with a delay of `constants.DEFAULT_GET_STATUS_DELAY`
    device.thread:call_with_delay(constants.DEFAULT_GET_STATUS_DELAY, function(d)
      --- Sends the `SwitchBinary:Get` command to the device's component
      device:send_to_component(SwitchBinary:Get({}))
    end)
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
--- @return (function)
local function switch_multilevel_handler(driver, device, command)
  local level

  --- Checks if the level argument in the input command is set
  if command.args.level then
    --- Rounds the level value to the nearest integer
    --- Clamps the level value between 0 and 99
    level = utils.clamp_value(utils.round(command.args.level), 0, 99)

    --- Emits a switch `on` or `off` event depending on the value of level
    device:emit_event(level > 0 and capabilities.switch.switch.on() or capabilities.switch.switch.off())
  end
  
  --- Handles "on/off" and "brightness level" functionality for Z-Wave devices
  --- @param driver (Driver) The driver object
  --- @param device (st.zwave.Device) The device object
  --- @param command (Command) Input command value
  --- @return (nil)
  return function(driver, device, command)
    --- Checks if the device supports the `switchLevel` capability
    if device:supports_capability(capabilities.switchLevel, nil) then
      --- Gets the dimming duration from the input command, or uses the default value
      local dimmingDuration = command.args.rate or constants.DEFAULT_DIMMING_DURATION

      --- Sends the `SwitchMultilevel:Set` command to the device's component with the given level and dimming duration
      device:send_to_component(SwitchMultilevel:Set({value = level, duration = dimmingDuration }),command.component)
    end
    
    --- Calls the function `device:send_to_component(SwitchMultilevel:Get({}))` with a delay of `constants.DEFAULT_GET_STATUS_DELAY`
    device.thread:call_with_delay(constants.DEFAULT_GET_STATUS_DELAY,
      function()
        --- Sends the `SwitchMultilevel:Get` command to the device's component
        device:send_to_component(SwitchMultilevel:Get({}))
      end
    )
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
  -- Check if the key attribute is released, if so, log an error and return as it is not supported by SmartThings
  if (command.args.key_attributes == CentralScene.key_attributes.KEY_RELEASED) then
    log.error("Button Value 'released' is not supported by SmartThings")
    return
  end

  -- Check if the last sequence number is not the same as the current one, if not continue 
  if device:get_field(LAST_SEQ_NUMBER) ~= command.args.sequence_number then
    device:set_field(LAST_SEQ_NUMBER, command.args.sequence_number)
    local event = map_key_attribute_to_capability[command.args.key_attributes][command.args.scene_number]
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
  log.debug(string.format("%s [%s] : operatingMode: %s", device.id, device.device_network_id, device.preferences.operatingMode))
  local operatingMode = tonumber(device.preferences.operatingMode) == 1 and '-status' or ''
  local firmware_version = args.firmware_0_version
  local firmware_sub_version = args.firmware_0_sub_version
  local profile

  -- Iterate through the list of HomeSeer switch fingerprints
  for _, fingerprint in ipairs(HOMESEER_SWITCH_FINGERPRINTS) do
    if device:id_match(fingerprint.mfr, fingerprint.prod, fingerprint.model) then
      log.info(string.format("%s [%s] : %s - Firmware: %s.%s", device.id, device.device_network_id, fingerprint.id, firmware_version, firmware_sub_version))
      profile = 'homeseer-' .. string.lower(string.sub(fingerprint.id, fingerprint.id:match'^.*()/'+1)) .. operatingMode


      if fingerprint.id == "HomeSeer/Dimmer/WD200" then
        -- Check if the firmware version and sub-version match certain values
        if firmware_version == 5 and (firmware_sub_version > 11 and firmware_sub_version < 14) then
          -- Update the device's profile and set a field to indicate that the update has occurred
          profile = profile .. '-' .. firmware_version .. '.' .. firmware_sub_version
          break
          -- Check if the firmware version and sub-version match certain values
        elseif firmware_version == 5 and firmware_sub_version >= 14 then
          -- Update the device's profile and set a field to indicate that the update has occurred
          profile = profile .. '-' .. 'latest'
          break
        end
      -- Check if the fingerprint of the device matches "HomeSeer/Dimmer/WX300S or WX300D"
      elseif fingerprint.id == "HomeSeer/Dimmer/WX300S" or fingerprint.id == "HomeSeer/Dimmer/WX300D" then
        -- Check if the firmware version is greater than 1.12
        if (firmware_version == 1 and firmware_sub_version > 12) then
          -- Set the new profile for the device
          profile = profile .. '-' .. 'latest'
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

--[[ --- @local
local custom_capabilities = {}
custom_capabilities.firmwareVersion = {}
custom_capabilities.firmwareVersion.name = "firmwareVersion"
custom_capabilities.firmwareVersion.capability = capabilities[custom_capabilities.firmwareVersion.name] ]]
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
  local handlers_table = type(handlers) == "function" and { handlers } or handlers
  -- Invoke each function in the handlers table and pass the provided arguments.
  for _, func in ipairs( handlers_table or {} ) do
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
  -- Call the topmost 'infoChanged' lifecycle hander to do any default work
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
    [cc.SWITCH_MULTILEVEL] = {
      [SwitchMultilevel.Set] = switch_multilevel_handler,
      [SwitchMultilevel.Report] = switch_multilevel_handler,
      [SwitchMultilevel.STOP_LEVEL_CHANGE] = switch_multilevel_stop_level_change_handler
    },
    --- Button
    [cc.CENTRAL_SCENE] = {
      [CentralScene.NOTIFICATION] = central_scene_notification_handler
    },
    --- Manufaturer Report
    [cc.MANUFACTURER_SPECIFIC] = {
      [ManufacturerSpecific.Report] = can_handle_homeseer_switches
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