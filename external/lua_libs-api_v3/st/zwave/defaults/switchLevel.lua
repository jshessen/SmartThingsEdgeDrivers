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
--- @type st.utils
local utils = require "st.utils"
--- @type st.zwave.CommandClass
local cc = require "st.zwave.CommandClass"
--- @type st.zwave.constants
local constants = require "st.zwave.constants"
--- @type st.zwave.CommandClass.Basic
local Basic = (require "st.zwave.CommandClass.Basic")({version=1,strict=true})
--- @type st.zwave.CommandClass.SwitchBinary
local SwitchBinary = (require "st.zwave.CommandClass.SwitchBinary")({version=2,strict=true})
--- @type st.zwave.CommandClass.SwitchMultilevel
local SwitchMultilevel = (require "st.zwave.CommandClass.SwitchMultilevel")({version=4,strict=true})

local zwave_handlers = {}

--- Handle a Switch Multilevel Report command received from a Z-Wave device.
--- Translate to and publish corresponding ST capabilities.
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.SwitchMultilevel.Report | st.zwave.CommandClass.Basic.Report
function zwave_handlers.switch_multilevel_basic_report(driver, device, cmd)
  local event = nil
  local value = cmd.args.value and cmd.args.value or cmd.args.target_value

  if value ~= nil and value > 0 then -- level 0 is switch off, not level set
    if value == 99 or value == 0xFF then
      -- Directly map 99 to 100 to avoid rounding issues remapping 0-99 to 0-100
      -- 0xFF is a (deprecated) reserved value that the spec requires be mapped to 100
      value = 100
    end
    event = capabilities.switchLevel.level(value)
  end

  if event ~= nil then
    device:emit_event_for_endpoint(cmd.src_channel, event)
  end
end

local capability_handlers = {}

--- Issue a level-set command to the specified device.
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param command table ST level capability command
function capability_handlers.switch_level_set(driver, device, command)
  local set
  local get
  local delay = constants.MIN_DIMMING_GET_STATUS_DELAY -- delay in seconds
  local level = utils.round(command.args.level)
  level = utils.clamp_value(level, 1, 99)

  if device:is_cc_supported(cc.SWITCH_MULTILEVEL) then
    local dimmingDuration = command.args.rate or constants.DEFAULT_DIMMING_DURATION -- dimming duration in seconds
    -- delay shall be at least 5 sec.
    if type(dimmingDuration) == "number" then
      delay = math.max(dimmingDuration + constants.DEFAULT_POST_DIMMING_DELAY, delay) -- delay in seconds
    end
    get = SwitchMultilevel:Get({})
    set = SwitchMultilevel:Set({ value=level, duration=dimmingDuration })
  elseif device:is_cc_supported(cc.BASIC) then
    get = Basic:Get({})
    set = Basic:Set({ value=level})
  end
  device:send_to_component(set, command.component)
  local query_level = function()
    device:send_to_component(get, command.component)
  end
  device.thread:call_with_delay(delay, query_level)
end

--- Find single best match from
--- {SwitchMultilevel:Get(), SwitchBinary:Get(), Basic:Get()}
--- based on supported combination of 2 capabilities:{`switch` and `switch level`}
--- and 3 command classes { Basic, SwitchBinary, SwitchMultilevel }
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param component string
--- @param endpoint integer
local function get_refresh_commands(driver, device, component, endpoint)
  if device:supports_capability_by_id(capabilities.switchLevel.ID, component) and device:is_cc_supported(cc.SWITCH_MULTILEVEL, endpoint) then
    -- it is exeeds `SwitchBinary` default driver scope of responcibility
    -- but we want to handle this special case: issue command for `SwitchMultilevel`
    -- if supported
    return {SwitchMultilevel:Get({}, {dst_channels = {endpoint}})}
  elseif device:supports_capability_by_id(capabilities.switchLevel.ID, component) and device:is_cc_supported(cc.BASIC, endpoint) then
    return {Basic:Get({}, {dst_channels = {endpoint}})}
  elseif device:supports_capability_by_id(capabilities.switch.ID, component) and device:is_cc_supported(cc.SWITCH_BINARY, endpoint) then
    return {SwitchBinary:Get({}, {dst_channels = {endpoint}})}
  elseif device:supports_capability_by_id(capabilities.switch.ID, component) and device:is_cc_supported(cc.BASIC, endpoint) then
    return {Basic:Get({}, {dst_channels = {endpoint}})}
  end
end

--- @class st.zwave.defaults.switchLevel
--- @alias switch_level_defaults st.zwave.defaults.switchLevel
--- @field public zwave_handlers table
--- @field public capability_handlers table
--- @field public get_refresh_commands function
local switch_level_defaults = {
  zwave_handlers = {
    [cc.BASIC] = {
      [Basic.REPORT] = zwave_handlers.switch_multilevel_basic_report
    },
    [cc.SWITCH_MULTILEVEL] = {
      [SwitchMultilevel.REPORT] = zwave_handlers.switch_multilevel_basic_report
    }
  },
  capability_handlers = {
    [capabilities.switchLevel.commands.setLevel] = capability_handlers.switch_level_set
  },
  get_refresh_commands = get_refresh_commands
}

return switch_level_defaults
