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

local log = require "log"
local capabilities = require "st.capabilities"
local defaults = require "st.zwave.defaults"
local cc = require "st.zwave.CommandClass"
local SwitchBinary = require "st.zwave.CommandClass.SwitchBinary"
local ZwaveDriver = require "st.zwave.driver"
local Basic = (require "st.zwave.CommandClass.Basic")({ version = 1 })
local CentralScene = (require "st.zwave.CommandClass.CentralScene")({ version = 1 })
local constants = require "st.zwave.constants"


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
  }
}

local function central_scene_notification_handler(driver, device, cmd)
  if device:get_field("last_sequence_number") ~= cmd.args.sequence_number then
    device:set_field("last_sequence_number", cmd.args.sequence_number)
    local event_map = map_key_attribute_to_capability[cmd.args.key_attributes]
    local event = event_map and event_map[cmd.args.scene_number]
    if event ~= nil then
      device:emit_event_for_endpoint(cmd.src_channel, event)
    end
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
