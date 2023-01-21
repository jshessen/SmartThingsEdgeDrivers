--&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
-- Author: Jeff Hessenflow (jshessen)
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
local capabilities = require "st.capabilities"
local log = require "log"

local cc = require "st.zwave.CommandClass"
-- Switch
local Basic = (require "st.zwave.CommandClass.Basic")({ version=1 })
local SwitchMultilevel = (require "st.zwave.CommandClass.SwitchMultilevel")({ version=4 })
-- Helpers
local fan_speed_helper = (require "zwave_fan_helpers")

--
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



--?????????????????????????????????????????????????????????????????
-- Variables/Constants
--
--- Map HomeSeer Fingerprints
local HOMESEER_FAN_FINGERPRINTS = {
  {mfr = 0x000C, prod = 0x0203, model = 0x0001}, -- HomeSeer FC200 Fan Controller
}
--
--?????????????????????????????????????????????????????????????????



--#################################################################
-- Section: Functions
--
--#######################################################
--- Function: can_handle_homeseer_switches()
--- Determine whether the passed device is HomeSeer device
--
local function can_handle_homeseer_switches(opts, driver, device, ...)
  for _, fingerprint in ipairs(HOMESEER_FAN_FINGERPRINTS) do
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
--- Map Speed to Switch Level
-- 
local function map_fan_4_speed_to_switch_level (speed)
  if speed == fan_speed_helper.fan_speed.OFF then
    return fan_speed_helper.levels_for_4_speed.OFF -- 0
  elseif speed == fan_speed_helper.fan_speed.LOW then
    return fan_speed_helper.levels_for_4_speed.LOW -- 25
  elseif speed == fan_speed_helper.fan_speed.MEDIUM then
    return fan_speed_helper.levels_for_4_speed.MEDIUM -- 50
  elseif speed == fan_speed_helper.fan_speed.HIGH then
    return fan_speed_helper.levels_for_4_speed.HIGH -- 75
  elseif speed == fan_speed_helper.fan_speed.MAX then
    return fan_speed_helper.levels_for_4_speed.MAX -- 99
  else
    log.error (string.format("4 speed fan driver: invalid fan speed: %d", speed))
  end
end

local function map_switch_level_to_fan_4_speed (level)
  if (level == 0) then
    return fan_speed_helper.fan_speed.OFF
  elseif (fan_speed_helper.levels_for_4_speed.OFF < level and level <= fan_speed_helper.levels_for_4_speed.LOW) then
    return fan_speed_helper.fan_speed.LOW
  elseif (fan_speed_helper.levels_for_4_speed.LOW < level and level <= fan_speed_helper.levels_for_4_speed.MEDIUM) then
    return fan_speed_helper.fan_speed.MEDIUM
  elseif (fan_speed_helper.levels_for_4_speed.MEDIUM < level and level <= fan_speed_helper.levels_for_4_speed.HIGH) then
    return fan_speed_helper.fan_speed.HIGH
  elseif (fan_speed_helper.levels_for_4_speed.HIGH < level and level <= fan_speed_helper.levels_for_4_speed.MAX) then
    return fan_speed_helper.fan_speed.MAX
  else
    log.error (string.format("4 speed fan driver: invalid level: %d", level))
  end
end
--
--#######################################################

--#######################################################
--- Function: capability_handlers()
--- 
-- 
local capability_handlers = {}
--
--#######################################################

--#######################################################
--- Function: capability_handlers.fan_speed_set()
--- Issue a level-set command to the specified device.
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param command table ST level capability command
function capability_handlers.fan_speed_set(driver, device, command)
  fan_speed_helper.capability_handlers.fan_speed_set(driver, device, command, map_fan_4_speed_to_switch_level)
end
--
--#######################################################

--#######################################################
--- Function: zwave_handlers()
---
--
local zwave_handlers = {}
--
--#######################################################

--#######################################################
--- Function: zwave_handlers.fan_multilevel_report()
--- Convert `SwitchMultilevel` level {0 - 99}
--- into `FanSpeed` speed { 0, 1, 2, 3, 4}
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.SwitchMultilevel.Report
function zwave_handlers.fan_multilevel_report(driver, device, cmd)
  fan_speed_helper.zwave_handlers.fan_multilevel_report(driver, device, cmd, map_switch_level_to_fan_4_speed)
end
--
--#######################################################
--
--#################################################################



--/////////////////////////////////////////////////////////////////
-- Section: Driver
--
--///////////////////////////////////////////////////////
local homeseer_fans = {
  capability_handlers = {
    [capabilities.fanSpeed.ID] = {
      [capabilities.fanSpeed.commands.setFanSpeed.NAME] = capability_handlers.fan_speed_set
    }
  },
  zwave_handlers = {
    [cc.SWITCH_MULTILEVEL] = {
      [SwitchMultilevel.REPORT] = zwave_handlers.fan_multilevel_report
    },
    [cc.BASIC] = {
      [Basic.REPORT] = zwave_handlers.fan_multilevel_report
    }
  },
  NAME = "Z-Wave fan 4 speed",
  can_handle = can_handle_homeseer_switches,
}
--
--///////////////////////////////////////////////////////

return homeseer_fans
--
--/////////////////////////////////////////////////////////////////
