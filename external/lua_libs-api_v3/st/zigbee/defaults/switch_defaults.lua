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
local zcl_clusters = require "st.zigbee.zcl.clusters"
local zcl_global_commands = require "st.zigbee.zcl.global_commands"
local capabilities = require "st.capabilities"
local Status = require "st.zigbee.generated.types.ZclStatus"

--- @class st.zigbee.defaults.switch
--- @field public zigbee_handlers table
--- @field public attribute_configurations table
--- @field public capability_handlers table
--- @field public default_on_off_configuration st.zigbee.defaults.switch.OnOffConfiguration
local switch_defaults = {}

--- Global handler for default response on the on off cluster
---
--- This converts the command from 0x01 -> Switch.switch.on and 0x00 to Switch.switch.off.
---
--- @param driver ZigbeeDriver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param zb_rx st.zigbee.ZigbeeMessageRx the full message this report came in
function switch_defaults.default_response_handler(driver, device, zb_rx)
  local status = zb_rx.body.zcl_body.status.value

  if status == Status.SUCCESS then
    local cmd = zb_rx.body.zcl_body.cmd.value
    local event = nil

    if cmd == zcl_clusters.OnOff.server.commands.On.ID then
      event = capabilities.switch.switch.on()
    elseif cmd == zcl_clusters.OnOff.server.commands.Off.ID then
      event = capabilities.switch.switch.off()
    end

    if event ~= nil then
      device:emit_event_for_endpoint(zb_rx.address_header.src_endpoint.value, event)
    end
  end
end

--- Default handler for on off attribute on the on off cluster
---
--- This converts the boolean value from true -> Switch.switch.on and false to Switch.switch.off.
---
--- @param driver ZigbeeDriver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param value st.zigbee.data_types.Boolean the value of the On Off cluster On Off attribute
--- @param zb_rx st.zigbee.ZigbeeMessageRx the full message this report came in
function switch_defaults.on_off_attr_handler(driver, device, value, zb_rx)
  local attr = capabilities.switch.switch
  device:emit_event_for_endpoint(zb_rx.address_header.src_endpoint.value, value.value and attr.on() or attr.off())
end

--- Default handler for the Switch.on command
---
--- This will send the on command to the on off cluster
---
--- @param driver ZigbeeDriver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param command CapabilityCommand The capability command table
function switch_defaults.on(driver, device, command)
  device:send_to_component(command.component, zcl_clusters.OnOff.server.commands.On(device))
end

--- Default handler for the Switch.off command
---
--- This will send the off command to the on off cluster
---
--- @param driver ZigbeeDriver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param command CapabilityCommand The capability command table
function switch_defaults.off(driver, device, command)
  device:send_to_component(command.component, zcl_clusters.OnOff.server.commands.Off(device))
end


switch_defaults.zigbee_handlers = {
  global = {
    [zcl_clusters.OnOff] = {
      [zcl_global_commands.DEFAULT_RESPONSE_ID] = switch_defaults.default_response_handler
    }
  },
  cluster = {},
  attr = {
    [zcl_clusters.OnOff] = {
      [zcl_clusters.OnOff.attributes.OnOff] = switch_defaults.on_off_attr_handler
    }
  }
}
switch_defaults.capability_handlers = {
  [capabilities.switch.commands.on.NAME] = switch_defaults.on,
  [capabilities.switch.commands.off.NAME] = switch_defaults.off
}

--- @class st.zigbee.defaults.switch.OnOffConfiguration
--- @field public cluster number On/Off cluster ID 0x0006
--- @field public attribute number On/Off attribute ID 0x0000
--- @field public minimum_interval number 0 seconds
--- @field public maximum_interval number 300 seconds (5 mins)
--- @field public data_type Boolean the Boolean class
local on_off_configuration =   {
  cluster = zcl_clusters.OnOff.ID,
  attribute = zcl_clusters.OnOff.attributes.OnOff.ID,
  minimum_interval = 0,
  maximum_interval = 300,
  data_type = zcl_clusters.OnOff.attributes.OnOff.base_type
}

switch_defaults.default_on_off_configuration = on_off_configuration

switch_defaults.attribute_configurations = {
  on_off_configuration
}

return switch_defaults
