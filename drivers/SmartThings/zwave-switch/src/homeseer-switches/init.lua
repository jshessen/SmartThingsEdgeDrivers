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

local capabilities = require "st.capabilities"
--- @type st.zwave.CommandClass
local cc = require "st.zwave.CommandClass"
--- @type st.utils
local utils = require "st.utils"
--- @type st.zwave.CommandClass.Basic
local Basic = (require "st.zwave.CommandClass.Basic")({ version = 1 })
--- @type st.zwave.CommandClass.Configuration
local Configuration = (require "st.zwave.CommandClass.Configuration")({ version = 1 })
--- @type st.zwave.CommandClass.Meter
local Meter = (require "st.zwave.CommandClass.Meter")({ version = 3 })
--- @type st.zwave.CommandClass.SwitchBinary
local SwitchBinary = (require "st.zwave.CommandClass.SwitchBinary")({ version = 2 })

local HOMESEER_SWITCH_FINGERPRINTS = {
  {mfr = 0x000C, prod = 0x4447, model = 0x3033}, -- HomeSeer WS100 Switch
  {mfr = 0x000C, prod = 0x4447, model = 0x3034}, -- HomeSeer WD100 Switch
  {mfr = 0x000C, prod = 0x4447, model = 0x3035}, -- HomeSeer WS200 Switch
  {mfr = 0x000C, prod = 0x4447, model = 0x3036}, -- HomeSeer WD200 Switch
}


--- Determine whether the passed device is Aeon smart strip
---
--- @param driver Driver driver instance
--- @param device Device device isntance
--- @return boolean true if the device proper, else false
local function can_handle_aeon_smart_strip(opts, driver, device, ...)
  for _, fingerprint in ipairs(HOMESEER_SWITCH_FINGERPRINTS) do
    if device:id_match(fingerprint.mfr, fingerprint.prod, fingerprint.model) then
      return true
    end
  end
  return false
end

local function central_scene_notification_handler(self, device, cmd)
  local map_key_attribute_to_capability = {
    [CentralScene.key_attributes.KEY_PRESSED_1_TIME] = {
      [0x01] = capabilities.button.button.up(),
      [0x02] = capabilities.button.button.down()
    },
    [CentralScene.key_attributes.KEY_PRESSED_2_TIMES] = {
      [0x01] = capabilities.button.button.up_2x(),
      [0x02] = capabilities.button.button.down_2x()
    },
    [CentralScene.key_attributes.KEY_PRESSED_3_TIMES] = {
      [0x01] = capabilities.button.button.up_3x(),
      [0x02] = capabilities.button.button.down_3x()
    },
    [CentralScene.key_attributes.KEY_PRESSED_4_TIMES] = {
      [0x01] = capabilities.button.button.up_4x(),
      [0x02] = capabilities.button.button.down_4x()
    },
    [CentralScene.key_attributes.KEY_PRESSED_5_TIMES] = {
      [0x01] = capabilities.button.button.up_5x(),
      [0x02] = capabilities.button.button.down_5x()
    },
    [CentralScene.key_attributes.KEY_HELD_DOWN] = {
      [0x01] = capabilities.button.button.up_hold(),
      [0x02] = capabilities.button.button.down_hold()
    }

  local event = map_key_attribute_to_capability[cmd.args.key_attributes]
  local button_number = 0
  if cmd.args.key_attributes == 0 or cmd.args.key_attributes == 1 or cmd.args.key_attributes == 2 then
    button_number = cmd.args.scene_number
  elseif cmd.args.key_attributes == 3 then
    button_number = cmd.args.scene_number + 2
  elseif cmd.args.key_attributes == 4 then
    button_number = cmd.args.scene_number + 4
  end
  local component = device.profile.components["button" .. button_number]
  
  if component ~= nil then
    device:emit_component_event(component, event({state_change = true}))
  end
end



local driver_template = {
  supported_capabilities = {
    capabilities.switch,
    capabilities.switchLevel,
    capabilities.fanSpeed,
    capabilities.refresh,
    capabilities.button
  },
  zwave_handlers = {
    [cc.CENTRAL_SCENE] = {
      [CentralScene.NOTIFICATION] = central_scene_notification_handler
    }
  },
  NAME = "homeseer zwave",
}

defaults.register_for_default_handlers(driver_template, driver_template.supported_capabilities)
local homeseer_switch = ZwaveDriver("homeseer-zwave-switch", driver_template)
homeseer_switch:run()
