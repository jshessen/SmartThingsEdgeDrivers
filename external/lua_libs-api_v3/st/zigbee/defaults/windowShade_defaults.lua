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

--- @class st.zigbee.defaults.windowShade
--- @field public zigbee_handlers table
--- @field public attribute_configurations table
--- @field public capability_handlers table
--- @field public default_window_covering_configuration st.zigbee.defaults.windowShade.WindowCoveringConfiguration
local windowShade_defaults = {}

local TIMER = "partial_open_timer"

--- Default handler for current lift percentage attribute on the window covering cluster
---
--- This converts the Uint8 value to Open, Close or partially open event
---
--- @param driver Driver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param value Uint8 the value of the current lift percentage of the window covering cluster
--- @param zb_rx st.zigbee.ZigbeeMessageRx the full message this report came in
function windowShade_defaults.default_current_lift_percentage_handler(driver, device, value, zb_rx)
  local component = {id = device:get_component_id_for_endpoint(zb_rx.address_header.src_endpoint.value)}
  local last_level = device:get_latest_state(component.id, capabilities.windowShadeLevel.ID, capabilities.windowShadeLevel.shadeLevel.NAME)
  local windowShade = capabilities.windowShade.windowShade
  local event = nil
  local current_level = value.value
  if current_level ~= last_level or last_level == nil then
    last_level = last_level and last_level or 0
    device:emit_component_event(component, capabilities.windowShadeLevel.shadeLevel(current_level))
    if current_level == 0 or current_level == 100 then
      event = current_level == 0 and windowShade.closed() or windowShade.open()
    else
      event = last_level < current_level and windowShade.opening() or windowShade.closing()
    end
  end
  if event ~= nil then
    device:emit_component_event(component, event)
    local timer = device:get_field(TIMER)
    if timer ~= nil then driver:cancel_timer(timer) end
    timer = device.thread:call_with_delay(2, function(d)
      if current_level ~= 0 and current_level ~= 100 then
        device:emit_component_event(component, windowShade.partially_open())
      end
    end
    )
    device:set_field(TIMER, timer)
  end
end

--- Default Command handler for Window Shade
---
--- handle builder for Open, Close, Pause commands
--- @param driver Driver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param command CapabilityCommand The capability command table
local function build_window_shade_cmd(cmd_type)
  return function(driver, device, command)
    device:send_to_component(command.component, cmd_type(device))
  end
end

windowShade_defaults.zigbee_handlers = {
  attr = {
    [zcl_clusters.WindowCovering] = {
      [zcl_clusters.WindowCovering.attributes.CurrentPositionLiftPercentage] = windowShade_defaults.default_current_lift_percentage_handler
    }
  }
}
windowShade_defaults.capability_handlers = {
  [capabilities.windowShade.commands.open.NAME] = build_window_shade_cmd(zcl_clusters.WindowCovering.server.commands.UpOrOpen),
  [capabilities.windowShade.commands.close.NAME] = build_window_shade_cmd(zcl_clusters.WindowCovering.server.commands.DownOrClose),
  [capabilities.windowShade.commands.pause.NAME] = build_window_shade_cmd(zcl_clusters.WindowCovering.server.commands.Stop)
}

--- @class st.zigbee.defaults.windowShade.WindowCoveringConfiguration
--- @field public cluster number WindowCovering cluster ID 0x0102
--- @field public attribute number CurrentPositionLiftPercentage attribute ID 0x0008
--- @field public minimum_interval number 0 seconds
--- @field public maximum_interval number 600 seconds (10 mins)
--- @field public data_type Boolean the Uint8 class
local window_covering_configuration = {
  cluster = zcl_clusters.WindowCovering.ID,
  attribute = zcl_clusters.WindowCovering.attributes.CurrentPositionLiftPercentage.ID,
  minimum_interval = 0,
  maximum_interval = 600,
  data_type = zcl_clusters.WindowCovering.attributes.CurrentPositionLiftPercentage.base_type,
  reportable_change = 1
}

windowShade_defaults.default_window_covering_configuration = window_covering_configuration

windowShade_defaults.attribute_configurations = {
  window_covering_configuration
}

return windowShade_defaults
