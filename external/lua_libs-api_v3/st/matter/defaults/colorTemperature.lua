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
local capabilities = require "st.capabilities"
local clusters = require "st.matter.generated.zap_clusters.init"
local utils = require "st.utils"

local MOST_RECENT_TEMP = "mostRecentTemp"
local CONVERSION_CONSTANT = 1000000

--- @class st.matter.defaults.colorTemperature
--- @field public matter_handlers table
--- @field public subscribed_attributes table
--- @field public capability_handlers table
local color_temp_defaults = {}

local function temp_attr_handler(driver, device, ib, response)
  if ib.data.value ~= nil then
    local temp = utils.round(CONVERSION_CONSTANT / ib.data.value)
    local most_recent_temp = device:get_field(MOST_RECENT_TEMP)
    -- this is to avoid rounding errors from the round-trip conversion of Kelvin to mireds
    if most_recent_temp ~= nil and most_recent_temp
      >= utils.round(CONVERSION_CONSTANT / (ib.data.value - 1)) and most_recent_temp
      <= utils.round(CONVERSION_CONSTANT / (ib.data.value + 1)) then temp = most_recent_temp end
    device:emit_event_for_endpoint(
      ib.endpoint_id, capabilities.colorTemperature.colorTemperature(temp)
    )
  end
end

local function handle_set_color_temperature(driver, device, cmd)
  local endpoint_id = device:component_to_endpoint(cmd.component)
  local temp_in_mired = utils.round(CONVERSION_CONSTANT / cmd.args.temperature)
  local req = clusters.ColorControl.server.commands.MoveToColorTemperature(
                device, endpoint_id, temp_in_mired, 0, 0, 0
              )
  device:set_field(MOST_RECENT_TEMP, cmd.args.temperature)
  device:send(req)
end

color_temp_defaults.matter_handlers = {
  attr = {
    [clusters.ColorControl.ID] = {
      [clusters.ColorControl.attributes.ColorTemperature.ID] = temp_attr_handler,
    },
  },
}
color_temp_defaults.capability_handlers = {
  [capabilities.colorTemperature.commands.setColorTemperature] = handle_set_color_temperature,
}
color_temp_defaults.subscribed_attributes = {clusters.ColorControl.attributes.ColorTemperature}

return color_temp_defaults
