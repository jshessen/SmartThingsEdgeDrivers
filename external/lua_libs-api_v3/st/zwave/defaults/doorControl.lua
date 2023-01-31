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
--- @type st.zwave.CommandClass.BarrierOperator
local BarrierOperator = (require "st.zwave.CommandClass.BarrierOperator")({version=1})

--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.BarrierOperator.Report
local function report_handler(driver, device, cmd)
  local event
  local contact_event -- for barrier operators that implement the contact sensor capability
  if cmd.args.state == BarrierOperator.state.CLOSED then
    event = capabilities.doorControl.door.closed()
    contact_event = capabilities.contactSensor.contact.closed()
  elseif cmd.args.state == BarrierOperator.state.CLOSING then
    event = capabilities.doorControl.door.closing()
  elseif cmd.args.state == BarrierOperator.state.STOPPED then
    event = capabilities.doorControl.door.unknown()
  elseif cmd.args.state == BarrierOperator.state.OPENING then
    event = capabilities.doorControl.door.opening()
    contact_event = capabilities.contactSensor.contact.open()
  elseif cmd.args.state == BarrierOperator.state.OPEN then
    event = capabilities.doorControl.door.open()
    contact_event = capabilities.contactSensor.contact.open()
  end

  device:emit_event_for_endpoint(cmd.src_channel, event)
  if (contact_event ~= nil) then device:emit_event_for_endpoint(cmd.src_channel, contact_event) end
end

--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param command table ST capability command
local function open(driver, device, command)
  device:send_to_component(
    BarrierOperator:Set({target_value = BarrierOperator.target_value.OPEN}),
    command.component
  )
end

--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param command table ST capability command
local function close(driver, device, command)
  device:send_to_component(
    BarrierOperator:Set({target_value = BarrierOperator.target_value.CLOSE}),
    command.component
  )
end

--- Return default doorControl refresh commands.
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param component string
--- @param endpoint integer
--- @return table default doorControl refresh commands
local function get_refresh_commands(driver, device, component, endpoint)
  if device:supports_capability_by_id(capabilities.doorControl.ID, component) and device:is_cc_supported(cc.BARRIER_OPERATOR, endpoint) then
    return {BarrierOperator:Get({}, {dst_channels = {endpoint}})}
  end
end

--- @class st.zwave.defaults.doorControl
--- @alias door_control_defaults st.zwave.defaults.doorControl
--- @field public zwave_handlers table
--- @field public capability_handlers table
local door_control_defaults = {
  zwave_handlers = {
    [cc.BARRIER_OPERATOR] = {
      [BarrierOperator.REPORT] = report_handler
    },
  },
  capability_handlers = {
    [capabilities.doorControl.commands.open] = open,
    [capabilities.doorControl.commands.close] = close
  },
  get_refresh_commands = get_refresh_commands,
}

return door_control_defaults
