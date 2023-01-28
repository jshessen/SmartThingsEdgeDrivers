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
local log = require "log"
--- @type st.zwave.CommandClass
local cc  = require "st.zwave.CommandClass"
--- @type st.zwave.constants
local constants = require "st.zwave.constants"
--- @type st.zwave.CommandClass.Basic
local Basic = (require "st.zwave.CommandClass.Basic")({version=1,strict=true})
--- @type st.zwave.CommandClass.SwitchBinary
local SwitchBinary = (require "st.zwave.CommandClass.SwitchBinary")({version=2,strict=true})
--- @type st.zwave.CommandClass.SwitchMultilevel
local SwitchMultilevel = (require "st.zwave.CommandClass.SwitchMultilevel")({version=4,strict=true})

local zwave_handlers = {}

--- Default handler for basic, binary and multilevel switch reports for
--- switch-implementing devices
---
--- This converts the command value from 0 -> Switch.switch.off, otherwise
--- Switch.switch.on.
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.SwitchMultilevel.Report|st.zwave.CommandClass.SwitchBinary.Report|st.zwave.CommandClass.Basic.Report
function zwave_handlers.report(driver, device, cmd)
  local event
  if cmd.args.value ~= nil then
    if cmd.args.value == SwitchBinary.value.OFF_DISABLE then
      event = capabilities.switch.switch.off()
    else
      event = capabilities.switch.switch.on()
    end
  else
    if cmd.args.target_value == SwitchBinary.value.OFF_DISABLE then
      event = capabilities.switch.switch.off()
    else
      event = capabilities.switch.switch.on()
    end
  end
  device:emit_event_for_endpoint(cmd.src_channel, event)
end

--- Interrogate the device's supported command classes to determine whether a
--- BASIC, SWITCH_BINARY or SWITCH_MULTILEVEL set should be issued to fulfill
--- the on/off capability command.
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param value number st.zwave.CommandClass.SwitchBinary.value.OFF_DISABLE or st.zwave.CommandClass.SwitchBinary.value.ON_ENABLE
--- @param command table The capability command table
local function switch_set_helper(driver, device, value, command)
  local set
  local get
  local delay = constants.DEFAULT_GET_STATUS_DELAY
  if device:is_cc_supported(cc.SWITCH_BINARY) then
    log.trace_with({ hub_logs = true }, "SWITCH_BINARY supported.")
    set = SwitchBinary:Set({
      target_value = value,
      duration = 0
    })
    get = SwitchBinary:Get({})
  elseif device:is_cc_supported(cc.SWITCH_MULTILEVEL) then
    log.trace_with({ hub_logs = true }, "SWITCH_MULTILEVEL supported.")
    set = SwitchMultilevel:Set({
      value = value,
      duration = constants.DEFAULT_DIMMING_DURATION
    })
    delay = constants.MIN_DIMMING_GET_STATUS_DELAY
    get = SwitchMultilevel:Get({})
  else
    log.trace_with({ hub_logs = true }, "SWITCH_BINARY and SWITCH_MULTILEVEL NOT supported. Use Basic.Set()")
    set = Basic:Set({
      value = value
    })
    get = Basic:Get({})
  end
  device:send_to_component(set, command.component)
  local query_device = function()
    device:send_to_component(get, command.component)
  end
  device.thread:call_with_delay(delay, query_device)
end

local capability_handlers = {}

--- Issue a switch-on command to the specified device.
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param command table The capability command table
function capability_handlers.on(driver, device, command)
  switch_set_helper(driver, device, SwitchBinary.value.ON_ENABLE, command)
end

--- Issue a switch-off command to the specified device.
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param command table The capability command table
function capability_handlers.off(driver, device, command)
  switch_set_helper(driver, device, SwitchBinary.value.OFF_DISABLE, command)
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
  elseif device:supports_capability_by_id(capabilities.switch.ID, component) and device:is_cc_supported(cc.SWITCH_BINARY, endpoint) then
    return {SwitchBinary:Get({}, {dst_channels = {endpoint}})}
  elseif device:supports_capability_by_id(capabilities.switch.ID, component) and device:is_cc_supported(cc.BASIC, endpoint) then
    return {Basic:Get({}, {dst_channels = {endpoint}})}
  end
end

--- @class st.zwave.defaults.switch
--- @alias switch_defaults st.zwave.defaults.switch
--- @field public zwave_handlers table
--- @field public capability_handlers table
--- @field public get_refresh_commands function
local switch_defaults = {
  zwave_handlers = {
    [cc.BASIC] = {
      [Basic.REPORT] = zwave_handlers.report
    },
    [cc.SWITCH_BINARY] = {
      [SwitchBinary.REPORT] = zwave_handlers.report
    },
    [cc.SWITCH_MULTILEVEL] = {
      [SwitchMultilevel.REPORT] = zwave_handlers.report
    }
  },
  capability_handlers = {
    [capabilities.switch.commands.on] = capability_handlers.on,
    [capabilities.switch.commands.off] = capability_handlers.off
  },
  get_refresh_commands = get_refresh_commands,
}

return switch_defaults
