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
local st_device = require "st.zwave.Device"
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
--- @type Configuration
local configsMap = require "configurations"

--- Misc
--- @type Version
local Version = (require "st.zwave.CommandClass.Version")({version = 2})
---
--- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

--- ?????????????????????????????????????????????????????????????????
--- Variables/Constants
---

--- @local
local custom_capabilities = {}
custom_capabilities.firmwareVersion = {}
custom_capabilities.firmwareVersion.name = "firmwareVersion"
custom_capabilities.firmwareVersion.capability = capabilities[custom_capabilities.firmwareVersion.name]

--- @local
local LAST_SEQ_NUMBER = "last_sequence_number"

--- @local
local BUTTON_VALUES = {
  "up_hold",
  "down_hold",
  "held",
  "up",
  "up_2x",
  "up_3x",
  "up_4x",
  "up_5x",
  "down",
  "down_2x",
  "down_3x",
  "down_4x",
  "down_5x",
  "pushed",
  "pushed_2x",
  "pushed_3x",
  "pushed_4x",
  "pushed_5x",
  "double"
}
--- Map HomeSeer Fingerprints
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
--- Map Attributes to Capabilities
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
--- ?????????????????????????????????????????????????????????????????

--- #################################################################
--- Section: Can Handle
---
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
      log.info(device.zwave_manufacturer_id)
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
--- Section: Z-Wave Handlers
---
--- ############################################################
--- Subsection: Switch MultiLevel
---
--- #######################################################
---

--- @function dimmer_event --
--- Handles "dimmer" functionality
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @param command (Command) Input command value
--- @return (nil)
local function dimmer_event(driver, device, command)
  local level = command.args.value and command.args.value or command.args.target_value
  local event = level > 0 and capabilities.switch.switch.on() or capabilities.switch.switch.off()
  --- Switch/Dimmer functionality
  if command.src_channel == 0 then
    device:emit_event_for_endpoint(command.src_channel, event)

    level = utils.clamp_value(level, 0, 100)
    if level >= 99 then
      device:emit_event_for_endpoint(command.src_channel, capabilities.switchLevel.level(100))
    else
      device:emit_event_for_endpoint(command.src_channel, capabilities.switchLevel.level(level))
    end
  --- LED Switch functionality
  else
      device:emit_event_for_endpoint(command.src_channel, event)
  end
end
---
--- #######################################################

--- #######################################################
---

--- @function switch_multilevel_stop_level_change_handler --
--- Handles "on/off" functionality
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @param command (Command) Input command value
--- @return (nil)
local function switch_multilevel_stop_level_change_handler(driver, device, command)
  -- Emit an event with the switch capability "on"
  device:emit_event(capabilities.switch.switch.on())
  -- Send a SwitchMultilevel:Get command
  device:send(SwitchMultilevel:Get({}))
end
---
--- #######################################################
---
--- ############################################################

--- ############################################################
--- Subsection: Central Scene
---
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
  if (command.args.key_attributes == 0x01) then
    log.error("Button Value 'released' is not supported by SmartThings")
    return
  end

  -- Check if the last sequence number is not the same as the current one, if not continue 
  if device:get_field(LAST_SEQ_NUMBER) ~= command.args.sequence_number then
    device:set_field(LAST_SEQ_NUMBER, command.args.sequence_number)
    local event_map = map_key_attribute_to_capability[command.args.key_attributes]
    local event = event_map and event_map[command.args.scene_number]
    -- loop through the events array
    for _, e in ipairs(event) do
      if e ~= nil then
        -- emit the event for the endpoint
        device:emit_event_for_endpoint(command.src_channel, e)
      end
    end
  end
end
---
--- #######################################################
---
--- ############################################################

--- ############################################################
--- Subsection: Version
---
--- #######################################################
---

--- @function version_report_handler --
--- Adjust profile definition based upon reported firmware version
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @param command (Command) Input command value
--- @return (nil)
local function version_report_handler(driver, device, command)

  local new_profile = ''
  local operatingMode = command.args.preferences.operatingMode == true and '-status' or ''

  -- Iterate through the list of HomeSeer switch fingerprints
  for _, fingerprint in ipairs(HOMESEER_SWITCH_FINGERPRINTS) do
    if fingerprint.id == "HomeSeer/Dimmer/WD200" then
      -- Check if the firmware version and sub-version match certain values
      if (command.args.firmware_version == 5 and (command.args.firmware_sub_version > 11 and command.args.firmware_sub_version < 14)) then
        -- Update the device's profile and set a field to indicate that the update has occurred
        new_profile = 'homeseer-' .. 'wd200' .. operatingMode .. '-' .. command.args.firmware_version .. '.' .. command.args.firmware_sub_version
        break
        -- Check if the firmware version and sub-version match certain values
      elseif (command.args.firmware_version == 5 and command.args.firmware_sub_version >= 14) then
        -- Update the device's profile and set a field to indicate that the update has occurred
        new_profile = 'homeseer-' .. 'wd200' .. operatingMode .. '-' .. 'latest'
        break
      end
    -- Check if the fingerprint of the device matches "HomeSeer/Dimmer/WX300S"
    elseif fingerprint.id == "HomeSeer/Dimmer/WX300S" then
      -- Check if the firmware version is greater than 1.12
      if (command.args.firmware_version == 1 and command.args.firmware_sub_version > 12) then
        -- Set the new profile for the device
        new_profile = 'homeseer-' .. 'wx300s' .. operatingMode .. '-' .. 'latest'
        break
      end
    -- Check if the fingerprint of the device matches "HomeSeer/Dimmer/WX300D"
    elseif fingerprint.id == "HomeSeer/Dimmer/WX300D" then
      -- Check if the firmware version is greater than 1.12
      if (command.args.firmware_version == 1 and command.args.firmware_sub_version > 12) then
        -- Set the new profile for the device
        new_profile = 'homeseer-' .. 'wx300d' .. operatingMode .. '-' .. 'latest'
        break
      end
    end
  end
  assert (device:try_update_metadata({profile = new_profile}), "Failed to change device profile")
  log.warn('Changed to new profile. App restart required.')
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
    local component = command and command.component and command.component or "main"
    --- Check if the device supports switch level capability
    if (device:supports_capability(capabilities.switchLevel, component)) then
        --- Send Get command to the switch level component
        device:send_to_component(SwitchMultilevel:Get({}), component)
        --- Send Get command to the Version component
        device:send(Version:Get({}))
    --- Check if the device supports switch capability
    elseif device:supports_capability(capabilities.switch, component) then
        --- Send Get command to the switch component
        device:send_to_component(SwitchBinary:Get({}), component)
    end
end
---
--- #######################################################

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

--- #######################################################
---

--- @function switch_set_on_off_handler --
--- Handles "on/off" functionality
--- @param value number
--- @return function
local function switch_set_on_off_handler(value)
  --- Handles "on/off" functionality
  --- @param driver (Driver) The driver object
  --- @param device (st.zwave.Device) The device object
  --- @param command (Command) Input command value
  --- @return (nil)
  return function(driver, device, command)
    local get, set

    if device:supports_capability(capabilities.switchLevel, nil) then
      local dimmingDuration = command.args.rate or constants.DEFAULT_DIMMING_DURATION
      set = SwitchMultilevel:Set({value = value, duration = dimmingDuration })
      get = SwitchMultilevel:Get({})
    elseif device:supports_capability(capabilities.switch, nil) then
      set = SwitchBinary:Set({target_value = value, duration = 0})
      get = SwitchBinary:Get({})
    end

    local query_device = function()
      device:send_to_component(get, command.component)
    end

    device:send_to_component(set, command.component)
    device.thread:call_with_delay(constants.DEFAULT_GET_STATUS_DELAY, query_device)
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
---

local function device_init(self, device)
  device:init()
end
---
--- #######################################################

--- #######################################################
---

--- @function added_handler --
--- @param self (Driver) Reference to the current object
--- @param device (st.zwave.Device) Device object that is added
local function added_handler(self, device)
  log.debug('Device Added')

  -- Refresh the device
  device:refresh()
  -- Get the device parameters from configsMap
  local configs = configsMap.get_device_parameters(device)
  -- Check if configs are available
  if configs then
    -- Loop through the device components
    for _, comp in pairs(device.profile.components) do
      -- Check if the device supports the button capability by id
      if device:supports_capability_by_id(capabilities.button.ID, comp.id) then
        -- Assign number_of_buttons based on comp.id
        local number_of_buttons = comp.id == "main" and configs.number_of_buttons or 1
        -- Emit an event for the numberOfButtons capability with the value and visibility set
        device:emit_component_event(comp, capabilities.button.numberOfButtons({ value=number_of_buttons }, { visibility = { displayed = false } }))
        -- Emit an event for the supportedButtonValues capability with the configs.supported_button_values and visibility set
        device:emit_component_event(comp, capabilities.button.supportedButtonValues(BUTTON_VALUES, { visibility = { displayed = false } }))
      end
    end
  end
end
---
--- #######################################################

--- #######################################################

--- @function do_configure --
--- @param self (Driver) Reference to the current object
--- @param device (st.zwave.Device) Device object that is added
local function do_configure(self, device)
  log.debug('Configure Device')
  device:refresh()
  device:configure()
end
---
--- #######################################################

--- #######################################################
---

--- @function info_changed --
--- @param self (Driver) Reference to the current object
--- @param device (st.zwave.Device) Device object that is added
--- @param event (Event)
--- @param args (any)
local function info_changed(self, device, event, args)
  log.info(device.id .. ": " .. device.device_network_id .. " > INFO CHANGED")

  if args.old_st_store.preferences.operatingMode ~= device.preferences.operatingMode then
    device:send(Version:Get({}))
  end
end
---
--- #######################################################

--- #######################################################

--- @function driver_switched --
--- @param self (Driver) Reference to the current object
--- @param device (st.zwave.Device) Device object that is added
local function driver_switched(self, device)
  log.info('device.id .. ": " .. device.device_network_id .. " > DRIVER_SWITCHED"')
end
---
--- #######################################################

--- #######################################################
---

--- @function removed --
--- @param self (Driver) Reference to the current object
--- @param device (st.zwave.Device) Device object that is added
local function removed(self, device)
  log.info(device.id .. ": " .. device.device_network_id .. " > DRIVER_REMOVED")
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
      [Basic.SET] = dimmer_event,
      [Basic.REPORT] = dimmer_event
    },
    --- Dimmer
    [cc.SWITCH_MULTILEVEL] = {
      [SwitchMultilevel.SET] = dimmer_event,
      [SwitchMultilevel.REPORT] = dimmer_event,
      [SwitchMultilevel.STOP_LEVEL_CHANGE] = switch_multilevel_stop_level_change_handler
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
      [capabilities.switch.switch.on.NAME] = switch_set_on_off_handler(SwitchBinary.value.ON_ENABLE),
      [capabilities.switch.switch.off.NAME] = switch_set_on_off_handler(SwitchBinary.value.OFF_DISABLE)
    },
    [capabilities.switchLevel.ID] = {
      [capabilities.switchLevel.commands.setLevel.NAME] = dimmer_event
    },
    --- Placeholder
    [capabilities.firmwareUpdate] = {
      [capabilities.firmwareUpdate.commands.checkForFirmwareUpdate] = checkForFirmwareUpdate_handler,
      [capabilities.firmwareUpdate.commands.updateFirmware] = updateFirmware_handler
    }
  },
  lifecycle_handlers = {
    init = device_init,
    added = added_handler,
    doConfigure = do_configure,
    infoChanged = info_changed,
    driverSwitched = driver_switched,
    removed = removed
  }
}
---
--- ///////////////////////////////////////////////////////

return homeseer_switches

--- /////////////////////////////////////////////////////////////////