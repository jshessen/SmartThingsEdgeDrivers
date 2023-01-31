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
--- @type st.zwave.constants
local constants = require "st.zwave.constants"
--- @type st.zwave.CommandClass.Basic
local Basic = (require "st.zwave.CommandClass.Basic")({ version=1 })
--- @type st.zwave.CommandClass.SwitchMultilevel
local SwitchMultilevel = (require "st.zwave.CommandClass.SwitchMultilevel")({ version=4 })

--- Default handler for basic and switch multilevel reports for implementing devices
---
--- This converts operated level to the equivalent smartthings capability value
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.Basic.Report | st.zwave.CommandClass.SwitchMultilevel.Report
local function basic_and_switch_multilevel_report_handler(driver, device, cmd)
  local event
  local level = cmd.args.value and cmd.args.value or cmd.args.target_value
  level = device.preferences.reverse and 99 - level or level
  if level >= 99 then
    event = capabilities.windowShadeLevel.shadeLevel(100)
  elseif level <= 0 then
    event = capabilities.windowShadeLevel.shadeLevel(0)
  else
    event = capabilities.windowShadeLevel.shadeLevel(level)
  end
  device:emit_event_for_endpoint(cmd.src_channel, event)
end

local capability_handlers = {}

--- Issue a set window shade level command to the specified device.
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param command table ST level capability command
function capability_handlers.set_shade_level(driver, device, command)
  local set
  local get
  local level = math.max(math.min(command.args.shadeLevel, 99), 0)
  level = device.preferences.reverse and 99 - level or level
  if device:is_cc_supported(cc.SWITCH_MULTILEVEL) then
    set = SwitchMultilevel:Set({
      value = level,
      duration = constants.DEFAULT_DIMMING_DURATION
    })
    get = SwitchMultilevel:Get({})
  else
    set = Basic:Set({
      value = level
    })
    get = Basic:Get({})
  end
  device:send_to_component(set, command.component)
  local query_device = function()
    device:send_to_component(get, command.component)
  end
  device.thread:call_with_delay(constants.MIN_DIMMING_GET_STATUS_DELAY, query_device)
end

--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param component string
--- @param endpoint integer
local function get_refresh_commands(driver, device, component, endpoint)
  if device:supports_capability_by_id(capabilities.windowShadeLevel.ID, component) and device:is_cc_supported(cc.SWITCH_MULTILEVEL, endpoint) then
    return { SwitchMultilevel:Get({}, {dst_channels = {endpoint}}) }
  elseif device:supports_capability_by_id(capabilities.windowShadeLevel.ID, component) and device:is_cc_supported(cc.BASIC, endpoint) then
    return { Basic:Get({}, {dst_channels = {endpoint}}) }
  end
end

--- @class st.zwave.defaults.windowShadeLevel
--- @alias window_shade_level_defaults st.zwave.defaults.windowShadeLevel
--- @field public zwave_handlers table
--- @field public capability_handlers table
local window_shade_level_defaults = {
  zwave_handlers = {
    [cc.BASIC] = {
        [Basic.REPORT] = basic_and_switch_multilevel_report_handler
      },
    [cc.SWITCH_MULTILEVEL] = {
      [SwitchMultilevel.REPORT] = basic_and_switch_multilevel_report_handler
    }
  },
  capability_handlers = {
    [capabilities.windowShadeLevel.commands.setShadeLevel] = capability_handlers.set_shade_level
  },
  get_refresh_commands = get_refresh_commands
}

return window_shade_level_defaults
