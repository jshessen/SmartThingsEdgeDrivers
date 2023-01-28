-- Copyright 2021 SmartThings
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
--- @type st.zwave.CommandClass.SceneActivation
local SceneActivation = (require "st.zwave.CommandClass.SceneActivation")({version=1,strict=true})
--- @type st.zwave.CommandClass.CentralScene
local CentralScene = (require "st.zwave.CommandClass.CentralScene")({version=1,strict=true})

local map_key_attribute_to_capability = {
  [CentralScene.key_attributes.KEY_PRESSED_1_TIME] = capabilities.button.button.pushed,
  [CentralScene.key_attributes.KEY_RELEASED] = capabilities.button.button.held,
  [CentralScene.key_attributes.KEY_HELD_DOWN] = capabilities.button.button.down_hold,
  [CentralScene.key_attributes.KEY_PRESSED_2_TIMES] = capabilities.button.button.double,
  [CentralScene.key_attributes.KEY_PRESSED_3_TIMES] = capabilities.button.button.pushed_3x,
  [CentralScene.key_attributes.KEY_PRESSED_4_TIMES] = capabilities.button.button.pushed_4x,
  [CentralScene.key_attributes.KEY_PRESSED_5_TIMES] = capabilities.button.button.pushed_5x,
}

--- Generates and send button capability event
---
--- @param device st.zwave.Device
--- @param capability_attribute function generates capability event
--- @param  button_number number
local function send_button_capability_event(device, capability_attribute, button_number, cmd)
  local additional_fields = {
    state_change = true
  }
  local event
  if capability_attribute ~= nil then
    event = capability_attribute(additional_fields)
  end

  if event ~= nil then
    device:emit_event_for_endpoint(cmd.src_channel, event)
  end
end

--- Default handler for scene notification command class reports
---
--- Shall emit appropriate capabilities.button event ( `pushed`, `held` etc.)
--- based on command's key_attributes
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.CentralScene.Notification
---           expected command arguments:
---           args={key_attributes="KEY_PRESSED_1_TIME",
---                 scene_number=0, sequence_number=0, slow_refresh=false}
local function central_scene_notification_handler(self, device, cmd)
  local button_number = 1
  if ( cmd.args.scene_number ~= nil and cmd.args.scene_number ~= 0 ) then
    button_number = cmd.args.scene_number
  end
  send_button_capability_event(device,
    map_key_attribute_to_capability[cmd.args.key_attributes],
    button_number,
    cmd)
end

--- Default handler for scene activation command class reports
---
--- Shall emit appropriate capabilities.button event ( `pushed` or `held`)
--- based on command's scene_id argument value
---
--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.SceneActivation.Set The z-wave command object.
---         expected command arguments: {args={dimming_duration=0, scene_id=0}
local function scene_activation_handler(self, device, cmd)
  local capability
  local scene_id = 1
  if ( cmd.args.scene_id ~= nil and cmd.args.scene_id ~= 0 ) then
    scene_id = cmd.args.scene_id
  end

  if scene_id % 2 == 0 then
    capability = capabilities.button.button.held
  else
    capability = capabilities.button.button.pushed
  end
  send_button_capability_event(device, capability, (scene_id + 1) // 2, cmd)
end

--- @class st.zwave.defaults.button
--- @alias button_defaults st.zwave.defaults.button
--- @field public zwave_handlers table
local button_defaults = {
  zwave_handlers = {
    [cc.SCENE_ACTIVATION] = {
      [SceneActivation.SET] = scene_activation_handler
    },
    [cc.CENTRAL_SCENE] = {
      [CentralScene.NOTIFICATION] = central_scene_notification_handler
    }
  },
}

return button_defaults
