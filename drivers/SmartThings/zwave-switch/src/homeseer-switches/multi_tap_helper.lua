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
local CentralScene = (require "st.zwave.CommandClass.CentralScene")({version = 1})
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

--- @local (table)
local BUTTON_VALUES = {
  "up","up_2x","up_3x","up_4x","up_5x","up_hold",
  "down","down_2x","down_3x","down_4x","down_5x","down_hold",
  "pushed","pushed_2x","pushed_3x","pushed_4x","pushed_5x","held",
  "double"
}
multi_tap.button_values = BUTTON_VALUES
--- @local (table)
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
multi_tap.map_key_attribute_to_capability = map_key_attribute_to_capability
---
--- ???????????????????????????????????????????????????????

--- #######################################################

--- @function multi_tap.update_device_profile() --
--- Adjust profile definition based upon operatingMode
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @param args (table)
--- @return (nil)
function multi_tap.update_device_profile(driver, device, args)
  log.debug(string.format("%s [%s] : operatingMode=%s", device.id, device.device_network_id, device.preferences.operatingMode))
  local operatingMode = tonumber(device.preferences.operatingMode) == 1 and "-status" or ""
  local firmware_version = args.firmware_0_version
  local firmware_sub_version = args.firmware_0_sub_version
  local profile

  -- Iterate through the list of HomeSeer switch fingerprints
  for _, fingerprint in ipairs(args.fingerprints) do
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

--- @function multi_tap.emit_central_scene_events() --
--- Handles "Scene" functionality
--- @param device (st.zwave.Device) The device object
--- @param command (Command) The command object
--- @return (nil)
function multi_tap.emit_central_scene_events(device, command)
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
    local event = multi_tap.map_key_attribute_to_capability[key_attributes][scene_number]
    -- Loop through the events array
    for _, e in ipairs(event) do
      -- Emit the event for the endpoint
      device:emit_event_for_endpoint(command.src_channel, e)
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