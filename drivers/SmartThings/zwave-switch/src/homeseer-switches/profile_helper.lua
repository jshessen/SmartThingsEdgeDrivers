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
--- @return (string|nil) The updated profile or nil if no profile is found
function profile.get_device_profile(device, args)
  if not device then log.error("device is nil") return nil end
  if not args.firmware_0_version then log.error("firmware_0_version is nil") return nil end
  if not args.firmware_0_sub_version then log.error("firmware_0_sub_version is nil") return nil end
  if not args.fingerprints then log.error("fingerprints is nil") return nil end

  local operatingMode = tonumber(device.preferences.operatingMode) == 1 and "-status" or ""
  local firmware_version = args.firmware_0_version
  local firmware_sub_version = args.firmware_0_sub_version

  for _, fingerprint in ipairs(args.fingerprints) do
    if device:id_match(fingerprint.mfr, fingerprint.prod, fingerprint.model) then
      local id = fingerprint.id
      local lowercase_id = string.lower(string.sub(id, id:match'^.*()/'+1))
      local prefix = "homeseer-" .. lowercase_id .. operatingMode

      if id == "HomeSeer/Dimmer/WD200" then
        if firmware_version == 5 then
          if firmware_sub_version > 11 and firmware_sub_version < 14 then
            return prefix .. "-" .. firmware_version .. "." .. "12"
          elseif firmware_sub_version >= 14 then
            return prefix .. "-" .. "latest"
          end
        end
      elseif id == "HomeSeer/Dimmer/WX300S" or id == "HomeSeer/Dimmer/WX300D" then
        if firmware_version == 1 and firmware_sub_version > 12 then
          return prefix .. "-" .. "latest"
        end
      end
    end
  end

  -- if no profile is found, return nil
  return nil
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