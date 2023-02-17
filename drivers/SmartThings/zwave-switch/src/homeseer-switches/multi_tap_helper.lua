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

-- @type log
local log = require "log"

--- Button
--- @type CentralScene
local CentralScene = (require "st.zwave.CommandClass.CentralScene")({ version = 1 })
---
--- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

--- #################################################################
--- Section: Multi-Tap Management
---
-- ???????????????????????????????????????????????????????
--- Variables/Constants
---

--- @local (table)
local multi_tap = {}
--- @local (string)
local LAST_SEQ_NUMBER = "last_sequence_number"

local button_prefixes = { "up", "down", "pushed" }
local button_suffixes = { "", "_2x", "_3x", "_4x", "_5x", "_hold" }
local button_values = {}
for _, prefix in ipairs(button_prefixes) do
  for i, suffix in ipairs(button_suffixes) do
    button_values[#button_values+1] = prefix .. suffix
  end
end
button_values[#button_values+1] = "double"
multi_tap.button_values = button_values

local button = capabilities.button.button
--- Map Attributes to Capabilities
local map_key_attribute_to_capability = {
  [CentralScene.key_attributes.KEY_PRESSED_1_TIME] = {
    [0x01] = { button.up(),button.pushed() },
    [0x02] = { button.down(),button.pushed() }
  },
  [CentralScene.key_attributes.KEY_PRESSED_2_TIMES] = {
    [0x01] = { button.up_2x(),button.pushed_2x(),button.double() },
    [0x02] = { button.down_2x(),button.pushed_2x(),button.double() }
  },
  [CentralScene.key_attributes.KEY_PRESSED_3_TIMES] = {
    [0x01] = { button.up_3x(),button.pushed_3x() },
    [0x02] = { button.down_3x(),button.pushed_3x() }
  },
  [CentralScene.key_attributes.KEY_PRESSED_4_TIMES] = {
    [0x01] = { button.up_4x(),button.pushed_4x() },
    [0x02] = { button.down_4x(),button.pushed_4x() }
  },
  [CentralScene.key_attributes.KEY_PRESSED_5_TIMES] = {
    [0x01] = { button.up_5x(),button.pushed_5x() },
    [0x02] = { button.down_5x(),button.pushed_5x() }
  },
  [CentralScene.key_attributes.KEY_HELD_DOWN] = {
    [0x01] = { button.up_hold(),button.held() },
    [0x02] = { button.down_hold(),button.held() }
  },
  [CentralScene.key_attributes.KEY_RELEASED] = {
    [0x01] = { button.held() },
    [0x02] = { button.held() }
  }
}
multi_tap.map_key_attribute_to_capability = map_key_attribute_to_capability
---
--- ???????????????????????????????????????????????????????

--- #######################################################
---

--- @function multi_tap.handle_central_scene_functionality() --
--- Handles "Scene" functionality
--- @param device (st.zwave.Device) The device object
--- @param command (Command) The command object
--- @return (nil)
function multi_tap.handle_central_scene_functionality(device, command)
  -- Store the values of sequence number, scene number, and key attributes in local variables
  local seq_number = command.args.sequence_number
  local scene_number = command.args.scene_number
  local key_attributes = command.args.key_attributes
  local key_map = multi_tap.map_key_attribute_to_capability

  -- Check if the key attribute is set to KEY_RELEASED
  if key_attributes == CentralScene.key_attributes.KEY_RELEASED then
    log.error("Button Value \"released\" is not supported by SmartThings")
    return
  end

  -- Check if the key_attributes and scene_number are present in the map
  if not key_map[key_attributes] or not key_map[key_attributes][scene_number] then
    log.error("No events found for key attributes %s and scene number %s", key_attributes, scene_number)
    return
  end

  -- Try to set the field LAST_SEQ_NUMBER and catch any errors
  local success, err = pcall(device.set_field, device, LAST_SEQ_NUMBER, seq_number)
  if not success then
    log.error("Error setting field LAST_SEQ_NUMBER: %s", err)
    return
  end

  -- Get the events associated with the current scene_number and key_attributes
  local event = key_map[key_attributes][scene_number]

  -- Loop through the events array and catch any errors
  for _, e in ipairs(event) do
    success, err = pcall(device.emit_event_for_endpoint, device, command.src_channel, e)
    if not success then
      log.error("Error emitting event %s for endpoint %s: %s", e, command.src_channel, err)
    end
  end
end
---
--- #################################################################

--- /////////////////////////////////////////////////////////////////
--- Return
---

return multi_tap
---
--- /////////////////////////////////////////////////////////////////
