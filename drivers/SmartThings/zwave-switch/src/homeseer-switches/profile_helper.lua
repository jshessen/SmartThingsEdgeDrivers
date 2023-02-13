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

-- @type log
local log = require "log"
--- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

--- #################################################################
--- Section: Multi-Tap Management
---
-- ???????????????????????????????????????????????????????
--- Variables/Constants
---

--- @local (table)
local profile = {}
---
--- ???????????????????????????????????????????????????????

--- #######################################################

--- @function profile.get_device_profile() --
--- Adjust profile definition based upon operatingMode
--- @param device (st.zwave.Device) The device object
--- @param args (table)
--- @return (string) The updated profile
function profile.get_device_profile(device, args)
  log.debug(string.format("%s [%s] : operatingMode=%s", device.id, device.device_network_id, device.preferences.operatingMode))
  local operatingMode = tonumber(device.preferences.operatingMode) == 1 and "-status" or ""
  local firmware_version = args.firmware_0_version
  local firmware_sub_version = args.firmware_0_sub_version
  local new_profile

  -- Iterate through the list of HomeSeer switch fingerprints
  for _, fingerprint in ipairs(args.fingerprints) do
    if device:id_match(fingerprint.mfr, fingerprint.prod, fingerprint.model) then
      log.info(string.format("%s [%s] : %s - Firmware: %s.%s", device.id, device.device_network_id, fingerprint.id, firmware_version, firmware_sub_version))
      new_profile = "homeseer-" .. string.lower(string.sub(fingerprint.id, fingerprint.id:match'^.*()/'+1)) .. operatingMode


      if fingerprint.id == "HomeSeer/Dimmer/WD200" then
        -- Check if the firmware version and sub-version match certain values
        if firmware_version == 5 and (firmware_sub_version > 11 and firmware_sub_version < 14) then
          -- Update the device's new_profile and set a field to indicate that the update has occurred
          new_profile = new_profile .. "-" .. firmware_version .. "." .. firmware_sub_version
          break
          -- Check if the firmware version and sub-version match certain values
        elseif firmware_version == 5 and firmware_sub_version >= 14 then
          -- Update the device's new_profile and set a field to indicate that the update has occurred
          new_profile = new_profile .. "-" .. "latest"
          break
        end
      -- Check if the fingerprint of the device matches "HomeSeer/Dimmer/WX300S or WX300D"
      elseif fingerprint.id == "HomeSeer/Dimmer/WX300S" or fingerprint.id == "HomeSeer/Dimmer/WX300D" then
        -- Check if the firmware version is greater than 1.12
        if (firmware_version == 1 and firmware_sub_version > 12) then
          -- Set the new_profile for the device
          new_profile = new_profile .. "-" .. "latest"
          break
        end
      end
    end
  end
  return new_profile
end
---
--- #######################################################
---
--- #################################################################

--- /////////////////////////////////////////////////////////////////
--- Return
---
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

-- @type log
local log = require "log"
--- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

--- #################################################################
--- Section: Multi-Tap Management
---
-- ???????????????????????????????????????????????????????
--- Variables/Constants
---

--- @local (table)
local profile = {}
---
--- ???????????????????????????????????????????????????????

--- #######################################################

--- @function profile.get_device_profile() --
--- Adjust profile definition based upon operatingMode
--- @param device (st.zwave.Device) The device object
--- @param args (table)
--- @return (string) The updated profile
function profile.get_device_profile(device, args)
  log.debug(string.format("%s [%s] : operatingMode=%s", device.id, device.device_network_id, device.preferences.operatingMode))
  local operatingMode = tonumber(device.preferences.operatingMode) == 1 and "-status" or ""
  local firmware_version = args.firmware_0_version
  local firmware_sub_version = args.firmware_0_sub_version
  local new_profile

  -- Iterate through the list of HomeSeer switch fingerprints
  for _, fingerprint in ipairs(args.fingerprints) do
    if device:id_match(fingerprint.mfr, fingerprint.prod, fingerprint.model) then
      log.info(string.format("%s [%s] : %s - Firmware: %s.%s", device.id, device.device_network_id, fingerprint.id, firmware_version, firmware_sub_version))
      new_profile = "homeseer-" .. string.lower(string.sub(fingerprint.id, fingerprint.id:match'^.*()/'+1)) .. operatingMode


      if fingerprint.id == "HomeSeer/Dimmer/WD200" then
        -- Check if the firmware version and sub-version match certain values
        if firmware_version == 5 and (firmware_sub_version > 11 and firmware_sub_version < 14) then
          -- Update the device's new_profile and set a field to indicate that the update has occurred
          new_profile = new_profile .. "-" .. firmware_version .. "." .. firmware_sub_version
          break
          -- Check if the firmware version and sub-version match certain values
        elseif firmware_version == 5 and firmware_sub_version >= 14 then
          -- Update the device's new_profile and set a field to indicate that the update has occurred
          new_profile = new_profile .. "-" .. "latest"
          break
        end
      -- Check if the fingerprint of the device matches "HomeSeer/Dimmer/WX300S or WX300D"
      elseif fingerprint.id == "HomeSeer/Dimmer/WX300S" or fingerprint.id == "HomeSeer/Dimmer/WX300D" then
        -- Check if the firmware version is greater than 1.12
        if (firmware_version == 1 and firmware_sub_version > 12) then
          -- Set the new_profile for the device
          new_profile = new_profile .. "-" .. "latest"
          break
        end
      end
    end
  end
  return new_profile
end
---
--- #######################################################
---
--- #################################################################

--- /////////////////////////////////////////////////////////////////
--- Return
---

return profile
---
--- /////////////////////////////////////////////////////////////////