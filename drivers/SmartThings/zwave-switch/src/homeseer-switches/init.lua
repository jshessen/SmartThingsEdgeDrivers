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

--- @type st.device
local st_device = require "st.device"
--- @module capabilities
local capabilities = require "st.capabilities"
--- @module utils
local utils = require "st.utils"
--- @module constants
local constants = require "st.zwave.constants"
--- @module log
local log = require "log"
--- @module cc
local cc = require "st.zwave.CommandClass"

--- Switch
--- @type Basic
local Basic = (require "st.zwave.CommandClass.Basic")({version = 1, strict = true})
--- @type SwitchBinary
local SwitchBinary = (require "st.zwave.CommandClass.SwitchBinary")({version = 2, strict = true})
--- @type SwitchMultilevel
local SwitchMultilevel = (require "st.zwave.CommandClass.SwitchMultilevel")({version = 4})
--- Button
--- @type CentralScene
local CentralScene = (require "st.zwave.CommandClass.CentralScene")({version = 1})

--- Misc
--- @type Version
local Version = (require "st.zwave.CommandClass.Version")({version = 2})

--- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

--- ?????????????????????????????????????????????????????????????????
--- Variables/Constants

--- @local
local PROFILE_CHANGED = "profile_changed"
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
  {id = "HomeSeer/Dimmer/WX300S", mfr = 0x000C, prod = 0x4447, model = 0x4036}, -- HomeSeer WX300 Switch
  {id = "HomeSeer/Dimmer/WX300D", mfr = 0x000C, prod = 0x4447, model = 0x4037}, -- HomeSeer WX300 Dimmer
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

--- ?????????????????????????????????????????????????????????????????

--- #################################################################
--- Section: Can Handle
--- #######################################################

--- @function can_handle_homeseer_switches --
--- @param opts table
--- @param driver table
--- @param device table
--- @vararg ... any
--- Determine whether the passed device is a HomeSeer switch.
--- Iterates over the fingerprints in `HOMESEER_SWITCH_FINGERPRINTS` and
--- checks if the device's id matches the fingerprint's manufacturer, product, and model id.
--- If a match is found, the function returns true, else it returns false.
local function can_handle_homeseer_switches(opts, driver, device, ...)
  for _, fingerprint in ipairs(HOMESEER_SWITCH_FINGERPRINTS) do
    if device:id_match(fingerprint.mfr, fingerprint.prod, fingerprint.model) then
      info(device.zwave_manufacturer_id)
      return true
    end
  end
  return false
end

--- #######################################################

--- #################################################################

--- #################################################################
--- Section: Z-Wave Handlers

--- ############################################################
--- Subsection: Switch MultiLevel

--- #######################################################

--- @function dimmer_event --
--- Handles "dimmer" functionality
--- @param driver string
--- @param device string
--- @param cmd string
local function dimmer_event(driver, device, cmd)
    local level = cmd.args.value and cmd.args.value or cmd.args.target_value
    if level > 0 then
        device:emit_event(capabilities.switch.switch.on())
    else
        device:emit_event(capabilities.switch.switch.off())
    end
    level = utils.clamp_value(level, 0, 100)
    if level >= 99 then
        device:emit_event(capabilities.switchLevel.level(100))
    else
        device:emit_event(capabilities.switchLevel.level(level))
    end
end

--- #######################################################

--- #######################################################

--- @function switch_multilevel_stop_level_change_handler --
--- Handles "on/off" functionality
--- @param driver table
--- @param device table
--- @param cmd table
local function switch_multilevel_stop_level_change_handler(driver, device, cmd)
  -- Emit an event with the switch capability "on"
  device:emit_event(capabilities.switch.switch.on())
  -- Send a SwitchMultilevel:Get command
  device:send(SwitchMultilevel:Get({}))
end

--- #######################################################

--- ############################################################

--- ############################################################
--- Subsection: Central Scene

--- #######################################################

--- @function central_scene_notification_handler --
--- Handles "Scene" functionality
--- @param driver Driver
--- @param device Device
--- @param cmd Command
local function central_scene_notification_handler(driver, device, cmd)
  -- Check if the key attribute is released, if so, log an error and return as it is not supported by SmartThings
  if (cmd.args.key_attributes == 0x01) then
    log.error("Button Value 'released' is not supported by SmartThings")
    return
  end

  -- Check if the last sequence number is not the same as the current one, if not continue 
  if device:get_field(LAST_SEQ_NUMBER) ~= cmd.args.sequence_number then
    device:set_field(LAST_SEQ_NUMBER, cmd.args.sequence_number)
    local event_map = map_key_attribute_to_capability[cmd.args.key_attributes]
    local event = event_map and event_map[cmd.args.scene_number]
    -- loop through the events array
    for _, e in ipairs(event) do
      if e ~= nil then
        -- emit the event for the endpoint
        device:emit_event_for_endpoint(cmd.src_channel, e)
      end
    end
  end
end


--- #######################################################

--- ############################################################

--- ############################################################
--- Subsection: Version

--- #######################################################

--- @function version_report_handler --
--- Adjust profile definition based upon reported firmware version
--- @param driver table
--- @param device table
--- @param cmd table
--- @return nil
local function version_report_handler(driver, device, cmd)
  -- Iterate through the list of HomeSeer switch fingerprints
  for _, fingerprint in ipairs(HOMESEER_SWITCH_FINGERPRINTS) do
    if fingerprint.id == "HomeSeer/Dimmer/WD200" then
      -- Check if the firmware version and sub-version match certain values
      if (cmd.args.firmware_0_version == 5 and (cmd.args.firmware_0_sub_version > 11 and cmd.args.firmware_0_sub_version < 14)) and
      device:get_field(PROFILE_CHANGED) ~= true then
        -- Update the device's profile and set a field to indicate that the update has occurred
        local new_profile = "homeseer-wd200-5.12"
        device:try_update_metadata({profile = new_profile})
        device:set_field(PROFILE_CHANGED, true, {persist = true})
      -- Check if the firmware version and sub-version match certain values
      elseif (cmd.args.firmware_0_version == 5 and cmd.args.firmware_0_sub_version >= 14) and
      device:get_field(PROFILE_CHANGED) ~= true then
        -- Update the device's profile and set a field to indicate that the update has occurred
        local new_profile = "homeseer-wd200-5.14"
        device:try_update_metadata({profile = new_profile})
        device:set_field(PROFILE_CHANGED, true, {persist = true})
      end
      break
    end

    -- Check if the fingerprint of the device matches "HomeSeer/Dimmer/WX300S"
    if fingerprint.id == "HomeSeer/Dimmer/WX300S" then
          
      -- Check if the firmware version is greater than 1.12 and the PROFILE_CHANGED field is not true
      if (cmd.args.firmware_0_version == 1 and cmd.args.firmware_0_sub_version > 12) and
      device:get_field(PROFILE_CHANGED) ~= true then
        
        -- Set the new profile for the device
        local new_profile = "homeseer-wx300s-1.13"
        device:try_update_metadata({profile = new_profile})
        -- Persist the change in the PROFILE_CHANGED field
        device:set_field(PROFILE_CHANGED, true, {persist = true})
        break
      end
    end

    -- Check if the fingerprint of the device matches "HomeSeer/Dimmer/WX300D"
    if fingerprint.id == "HomeSeer/Dimmer/WX300D" then
          
      -- Check if the firmware version is greater than 1.12 and the PROFILE_CHANGED field is not true
      if (cmd.args.firmware_0_version == 1 and cmd.args.firmware_0_sub_version > 12) and
      device:get_field(PROFILE_CHANGED) ~= true then
        
        -- Set the new profile for the device
        local new_profile = "homeseer-wx300d-1.13"
        device:try_update_metadata({profile = new_profile})
        -- Persist the change in the PROFILE_CHANGED field
        device:set_field(PROFILE_CHANGED, true, {persist = true})
        break
      end
    end
  end
end


--- #######################################################

--- ############################################################

--- #################################################################
--- Section: Capability Handlers

--- #######################################################

--- @function: do_referesh --
--- Refresh Device
--- @param driver Driver
--- @param device Device
--- @param cmd Command
local function do_refresh(driver, device, cmd)
    --- Determine the component for the command
    local component = cmd and cmd.component and cmd.component or "main"
    --- Check if the device supports switch level capability
    if device:supports_capability(capabilities.switchLevel) then
        --- Send Get command to the switch level component
        device:send_to_component(SwitchMultilevel:Get({}), component)
        --- Send Get command to the Version component
        device:send(Version:Get({}))
    --- Check if the device supports switch capability
    elseif device:supports_capability(capabilities.switch) then
        --- Send Get command to the switch component
        device:send_to_component(SwitchBinary:Get({}), component)
    end
end

--- #######################################################

--- #######################################################

--- @function switch_set_on_off_handler --
--- Handles "on/off" functionality
--- @param value number
--- @return function
local function switch_set_on_off_handler(value)
  --- Handles "on/off" functionality
  --- @param driver Driver
  --- @param device Device
  --- @param command table
  return function(driver, device, command)
    local get, set

    if device:supports_capability(capabilities.switchLevel) then
      set = SwitchMultilevel:Set({value = value, duration = constants.DEFAULT_DIMMING_DURATION})
      get = SwitchMultilevel:Get({})
    elseif device:supports_capability(capabilities.switch) then
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

--- #######################################################

--- #################################################################

--- #################################################################
--- Section: Lifecycle Handlers

--- #######################################################

--- #######################################################

--- #################################################################

--- /////////////////////////////////////////////////////////////////
---  Section: Driver

--- ///////////////////////////////////////////////////////

--- @type homeseer_switches
local homeseer_switches = {
  NAME = "HomeSeer Z-Wave Switches",
  can_handle = can_handle_homeseer_switches,
  zwave_handlers = {
    --- Switch
    [cc.BASIC] = {
      [Basic.SET] = dimmer_event
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
    }
  },
  lifecycle_handlers = {
    --init = device_init,
    --added = device_added
  }
}

--- ///////////////////////////////////////////////////////

return homeseer_switches

--- /////////////////////////////////////////////////////////////////
