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
local cc  = require "st.zwave.CommandClass"
--- @type st.zwave.constants
local constants = require "st.zwave.constants"
--- @type st.zwave.CommandClass.Basic
local Basic = (require "st.zwave.CommandClass.Basic")({ version=1, strict=true })
--- @type st.zwave.CommandClass.SwitchBinary
local SwitchBinary = (require "st.zwave.CommandClass.SwitchBinary")({ version=2, strict=true })
--- @type log
local log = require "log"

local zwave_handlers = {}

--- Default handler binary switch reports for
--- valve (switch-implementing) devices
---
--- This converts the Z-Wave command value
--- to capability.valve open/closed
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.SwitchBinary.Report|st.zwave.CommandClass.Basic.Report
function zwave_handlers.report(driver, device, cmd)
  local event
  if cmd.args.value == SwitchBinary.value.OFF_DISABLE then
    event = capabilities.valve.valve.closed()
  else
    event = capabilities.valve.valve.open()
  end
  device:emit_event_for_endpoint(cmd.src_channel, event)
end

--- Interrogate the device's supported command classes to determine whether a
--- BASIC, SWITCH_BINARY set should be issued to fulfill
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
  else
    log.trace_with({ hub_logs = true }, "SWITCH_BINARY supported. Use Basic.Set()")
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

--- Issue a valve open command to the specified device.
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param command table The capability command table
function capability_handlers.open(driver, device, command)
  switch_set_helper(driver, device, SwitchBinary.value.ON_ENABLE, command)
end

--- Issue a valve closed ( switch.OFF) command to the specified device.
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param command table The capability command table
function capability_handlers.close(driver, device, command)
  switch_set_helper(driver, device, SwitchBinary.value.OFF_DISABLE, command)
end

--- Find single best match from
--- SwitchBinary:Get(), Basic:Get()}
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param component string
--- @param endpoint integer
local function get_refresh_commands(driver, device, component, endpoint)
  if device:supports_capability_by_id(capabilities.valve.ID, component) then
    if device:is_cc_supported(cc.SWITCH_BINARY, endpoint) then
      return {SwitchBinary:Get({}, {dst_channels = {endpoint}})}
    else
      return {Basic:Get({}, {dst_channels = {endpoint}})}
    end
  end
end

--- @class st.zwave.defaults.valve
--- @alias valve_defaults valve_defaults st.zwave.defaults.valve
--- @field public zwave_handlers table
--- @field public capability_handlers table
--- @field public get_refresh_commands function
local valve_defaults = {
  zwave_handlers = {
    [cc.BASIC] = {
      [Basic.REPORT] = zwave_handlers.report
    },
    [cc.SWITCH_BINARY] = {
      [SwitchBinary.REPORT] = zwave_handlers.report
    },
  },
  capability_handlers = {
    [capabilities.valve.commands.open] = capability_handlers.open,
    [capabilities.valve.commands.close] = capability_handlers.close,
  },
  get_refresh_commands = get_refresh_commands,
}

return valve_defaults
