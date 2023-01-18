--&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
-- Author: ryanjmulder
--
-- Copyright 2022 SmartThings
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- 
--&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&



--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-- Required Libraries
--
local st_device = require "st.device"
local capabilities = require "st.capabilities"
local utils = require "st.utils"
local constants = require "st.zwave.constants"

local cc = require "st.zwave.CommandClass"
-- Switch
local Basic = (require "st.zwave.CommandClass.Basic")({ version = 1, strict = true })
local SwitchBinary = (require "st.zwave.CommandClass.SwitchBinary")({ version = 2, strict = true })
local SwitchMultilevel = (require "st.zwave.CommandClass.SwitchMultilevel")({ version = 4 })
-- Button
local CentralScene = (require "st.zwave.CommandClass.CentralScene")({ version = 1 })
-- Misc

--
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



--?????????????????????????????????????????????????????????????????
-- Variables/Constants
--
local LAST_SEQ_NUMBER = "last_sequence_number"
local BUTTON_VALUES = {
  "up_hold", "down_hold", "held",
  "up", "up_2x", "up_3x", "up_4x", "up_5x",
  "down", "down_2x", "down_3x", "down_4x", "down_5x",
  "pushed", "pushed_2x", "pushed_3x", "pushed_4x", "pushed_5x",
  "double"
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
--- Map HomeSeer Fingerprints
local HOMESEER_SWITCH_FINGERPRINTS = {
  {mfr = 0x000C, prod = 0x4447, model = 0x3033}, -- HomeSeer WS100 Switch
  {mfr = 0x000C, prod = 0x4447, model = 0x3034}, -- HomeSeer WD100 Dimmer
  {mfr = 0x000C, prod = 0x4447, model = 0x3035}, -- HomeSeer WS200 Switch
  {mfr = 0x000C, prod = 0x4447, model = 0x3036}, -- HomeSeer WD200 Dimmer
  {mfr = 0x000C, prod = 0x4447, model = 0x4036}, -- HomeSeer WX300 Switch
  {mfr = 0x000C, prod = 0x4447, model = 0x4037}, -- HomeSeer WX300 Dimmer
  {mfr = 0x0315, prod = 0x4447, model = 0x3033}, -- ZLink ZL-WS-100 Switch - ZWaveProducts.com
  {mfr = 0x0315, prod = 0x4447, model = 0x3034}, -- ZLink ZL-WD-100 Dimmer - ZWaveProducts.com
}
--
--?????????????????????????????????????????????????????????????????



--#################################################################
-- Section: Functions
--
--#######################################################
--- Function: can_handle_homeseer_switches()
--- Determine whether the passed device is HomeSeer switch
--
local function can_handle_homeseer_switches(opts, driver, device, ...)
  for _, fingerprint in ipairs(HOMESEER_SWITCH_FINGERPRINTS) do
    if device:id_match(fingerprint.mfr, fingerprint.prod, fingerprint.model) then
      return true
    end
  end
  return false
end
--
--#######################################################

--#######################################################
--- Function: do_referesh()
--- Determine whether the passed device is HomeSeer switch
-- 
local function do_refresh(driver, device, cmd)
  local component = cmd and cmd.component and cmd.component or "main"

  if device:supports_capability(capabilities.switchLevel) then
    device:send_to_component(SwitchMultilevel:Get({}), component)
  elseif device:supports_capability(capabilities.switch) then
    device:send_to_component(SwitchBinary:Get({}), component)
  end
end
--
--#######################################################

--#######################################################
--- Function: switch_set_on_off()
--- Handles "on/off" functionality
--
local function switch_set_on_off_handler(value)
  return function(driver, device, command)
    local get, set

    if device:supports_capability(capabilities.switchLevel) then
      set = SwitchMultilevel:Set({ value = value, duration = constants.DEFAULT_DIMMING_DURATION })
      get = SwitchMultilevel:Get({})
    elseif device:supports_capability(capabilities.switch) then
      set = SwitchBinary:Set({ target_value = value, duration = 0 })
      get = SwitchBinary:Get({})
    end

    local query_device = function()
      device:send_to_component(get, command.component)
    end

    device:send_to_component(set, command.component)
    device.thread:call_with_delay(constants.DEFAULT_GET_STATUS_DELAY, query_device)
  end
end
--
--#######################################################

--#######################################################
--- Function: dimmer_event()
--- Handles "dimmer" functionality
--
local function dimmer_event(driver, device, cmd)
  local level = cmd.args.value and cmd.args.value or cmd.args.target_value

  device:emit_event(level > 0 and capabilities.switch.switch.on() or capabilities.switch.switch.off())

  level = utils.clamp_value(level, 0, 100)
  device:emit_event(level >= 99 and capabilities.switchLevel.level(100) or capabilities.switchLevel.level(level))
end
--
--#######################################################

--#######################################################
--- Function: switch_multilevel_stop_level_change_handler()
--- Handles "on/off" functionality
--
local function switch_multilevel_stop_level_change_handler(driver, device, cmd)
  device:emit_event(capabilities.switch.switch.on())
  device:send(SwitchMultilevel:Get({}))
end
--
--#######################################################

--#######################################################
--- Function: central_scene_notification_handler
--- Handles "Scene" functionality
--
local function central_scene_notification_handler(driver, device, cmd)
  if (cmd.args.key_attributes == 0x01) then
    log.error("Button Value 'released' is not supported by SmartThings")
    return
  end
  
  if device:get_field(LAST_SEQ_NUMBER) ~= cmd.args.sequence_number then
    device:set_field(LAST_SEQ_NUMBER, cmd.args.sequence_number)
    local event_map = map_key_attribute_to_capability[cmd.args.key_attributes]
    local event = event_map and event_map[cmd.args.scene_number]
    for _, e in ipairs(event) do
      if e ~= nil then
        device:emit_event_for_endpoint(cmd.src_channel, e)
      end
    end
  end
end
--
--#######################################################
--
--#################################################################



--/////////////////////////////////////////////////////////////////
-- Section: Driver
--
--///////////////////////////////////////////////////////
local homeseer_switches = {
  NAME = "HomeSeer Z-Wave Switches",
  zwave_handlers = {
    --- Switch
    [cc.BASIC] = {
      [Basic.SET] = dimmer_event,
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
    init = device_init,
    added = device_added
  },
  can_handle = can_handle_homeseer_switches
}
--
--///////////////////////////////////////////////////////

return homeseer_switches
--
--/////////////////////////////////////////////////////////////////
