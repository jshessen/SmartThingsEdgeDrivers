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
local capabilities = require "st.capabilities"
local switch_defaults = require "st.zigbee.defaults.switch_defaults"
local data_types = require "st.zigbee.data_types"

--- @class st.zigbee.defaults.colorControl
--- @field public zigbee_handlers table
--- @field public attribute_configurations table
--- @field public capability_handlers table
local color_control_defaults = {}

--- Default handler for the current hue attribute on the color control cluster
---
--- This converts the Uint8 value of the current hue attribute on the color control cluster to
--- ColorControl.hue
---
--- @param driver ZigbeeDriver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param value st.zigbee.data_types.Uint8 the color control current hue value
--- @param zb_rx st.zigbee.ZigbeeMessageRx the full message this report came in
function color_control_defaults.color_hue_handler(driver, device, value, zb_rx)
  device:emit_event_for_endpoint(
      zb_rx.address_header.src_endpoint.value,
      capabilities.colorControl.hue(math.floor(value.value / 0xFE * 100))
  )
end

--- Default handler for the current saturation attribute on the color control cluster
---
--- This converts the Uint8 value of the current saturation attribute on the color control cluster to
--- ColorControl.saturation
---
--- @param driver ZigbeeDriver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param value st.zigbee.data_types.Uint8 the color control current saturation value
--- @param zb_rx st.zigbee.ZigbeeMessageRx the full message this report came in
function color_control_defaults.color_sat_handler(driver, device, value, zb_rx)
  device:emit_event_for_endpoint(
      zb_rx.address_header.src_endpoint.value,
      capabilities.colorControl.saturation(math.floor(value.value / 0xFE * 100))
  )
end

--- Default handler for the ColorControl.setColor command
---
--- This will send an on command to the on off cluster, followed by a move to hue and saturation command to the
--- color control cluster
---
--- @param driver ZigbeeDriver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param command CapabilityCommand The capability command table
function color_control_defaults.set_color(driver, device, command)
  switch_defaults.on(driver, device, command)
  local hue = math.floor((command.args.color.hue * 0xFE) / 100.0 + 0.5)
  local sat = math.floor((command.args.color.saturation * 0xFE) / 100.0 + 0.5)
  device:send_to_component(command.component, zcl_clusters.ColorControl.server.commands.MoveToHueAndSaturation(device, hue, sat, 0x0000))

  local color_read = function(d)
    device:send_to_component(command.component, zcl_clusters.ColorControl.attributes.CurrentHue:read(device))
    device:send_to_component(command.component, zcl_clusters.ColorControl.attributes.CurrentSaturation:read(device))
  end

  device.thread:call_with_delay(2, color_read, "setColor delayed read")
end

--- Default handler for the ColorControl.setHue command
---
--- This will send an on command to the OnOff cluster, followed by a move to hue command to the color control cluster
---
--- @param driver ZigbeeDriver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param command CapabilityCommand The capability command table
function color_control_defaults.set_hue(driver, device, command)
  switch_defaults.on(driver, device, command)
  local value = math.floor((command.args.hue * 0xFE) / 100.0 + 0.5)
  device:send_to_component(command.component, zcl_clusters.ColorControl.commands.MoveToHue(device, value, 0x00, 0x0000))

  local hue_read = function(d)
    device:send_to_component(command.component, zcl_clusters.ColorControl.attributes.CurrentHue:read(device))
  end

  device.thread:call_with_delay(2, hue_read, "setHue delayed read")
end

--- Default handler for the ColorControl.setSaturation command
---
--- This will send an on command to the OnOff cluster, followed by a move to saturation command to the color control cluster
---
--- @param driver ZigbeeDriver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param command CapabilityCommand The capability command table
function color_control_defaults.set_saturation(driver, device, command)
  switch_defaults.on(driver, device, command)
  local value = math.floor((command.args.saturation * 0xFE) / 100.0 + 0.5)
  device:send_to_component(command.component, zcl_clusters.ColorControl.commands.MoveToSaturation(device, value, 0x0000))

  local saturation_read = function(d)
    device:send_to_component(command.component, zcl_clusters.ColorControl.attributes.CurrentSaturation:read(device))
  end

  device.thread:call_with_delay(2, saturation_read, "setSaturation delayed read")
end

--- @class st.zigbee.defaults.colorControl.CurrentHueConfiguration
--- @field public cluster number ColorControl ID 0x0300
--- @field public attribute number CurrentHue ID 0x0000
--- @field public minimum_interval number 1 second
--- @field public maximum_interval number 3600 seconds (1 hour)
--- @field public data_type st.zigbee.data_types.Uint8 the data type class of this attribute
--- @field public reportable_change number 16 ()
local default_current_hue_config = {
  cluster = zcl_clusters.ColorControl.ID,
  attribute = zcl_clusters.ColorControl.attributes.CurrentHue.ID,
  minimum_interval = 1,
  maximum_interval = 3600,
  data_type = data_types.Uint8,
  reportable_change = 16
}

--- @class st.zigbee.defaults.colorControl.CurrentSaturationConfiguration
--- @field public cluster number ColorControl ID 0x0300
--- @field public attribute number CurrentSaturation ID 0x0001
--- @field public minimum_interval number 1 second
--- @field public maximum_interval number 3600 seconds (1 hour)
--- @field public data_type st.zigbee.data_types.Uint8 the data type class of this attribute
--- @field public reportable_change number 16 ()
local default_current_saturation_config = {
  cluster = zcl_clusters.ColorControl.ID,
  attribute = zcl_clusters.ColorControl.attributes.CurrentSaturation.ID,
  minimum_interval = 1,
  maximum_interval = 3600,
  data_type = data_types.Uint8,
  reportable_change = 16
}

color_control_defaults.zigbee_handlers = {
  global = {},
  cluster = {},
  attr = {
    [zcl_clusters.ColorControl] = {
      [zcl_clusters.ColorControl.attributes.CurrentHue] = color_control_defaults.color_hue_handler,
      [zcl_clusters.ColorControl.attributes.CurrentSaturation] = color_control_defaults.color_sat_handler,
    }
  }
}
color_control_defaults.capability_handlers = {
  [capabilities.colorControl.commands.setColor.NAME] = color_control_defaults.set_color,
  [capabilities.colorControl.commands.setHue.NAME] = color_control_defaults.set_hue,
  [capabilities.colorControl.commands.setSaturation.NAME] = color_control_defaults.set_saturation
}

color_control_defaults.attribute_configurations = {
  default_current_hue_config,
  default_current_saturation_config
}

return color_control_defaults
