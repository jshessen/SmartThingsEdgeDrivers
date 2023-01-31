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
--- @type st.zwave.CommandClass.SwitchColor
local SwitchColor = (require "st.zwave.CommandClass.SwitchColor")({version=3,strict=true})

-- We must cache data in order to translate between Z-Wave color reports and
-- ST color capability events, which do not have a 1:1 mapping.  Claim portions
-- of the device data store key space prefixed with our associated capability
-- and Z-Wave color component IDs to avoid collisions.
local CAP_CACHE_KEY = "st.capabilities." .. capabilities.colorControl.ID
local ZW_CACHE_PREFIX = "st.zwave.SwitchColor."
local HUE_CACHE = "_cached_hue"
local SAT_CACHE = "_cached_sat"
local HUE_SAT_DELAY_TIMER = "_hue_sat_delay"

local zwave_handlers = {}

--- Handle an RGB Switch Color Report command received from a Z-Wave device.
--- Translate to and publish a corresponding ST color capability.
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.SwitchColor.Report
function zwave_handlers.switch_color_report(driver, device, cmd)
  local id = cmd.args.color_component_id
  if id ~= SwitchColor.color_component_id.RED
    and id ~= SwitchColor.color_component_id.GREEN
    and id ~= SwitchColor.color_component_id.BLUE then
    return
  end
  local value
  if cmd.args.target_value ~= nil then
    -- Target value is our best inidicator of eventual state.
    -- If we see this, it should be considered authoritative.
    value = cmd.args.target_value
  else
    value = cmd.args.value
  end
  device:set_field(ZW_CACHE_PREFIX .. id, value, { persist=false })
  local cached_cmd = device:get_field(CAP_CACHE_KEY)
  local r = device:get_field(ZW_CACHE_PREFIX .. SwitchColor.color_component_id.RED)
  local g = device:get_field(ZW_CACHE_PREFIX .. SwitchColor.color_component_id.GREEN)
  local b = device:get_field(ZW_CACHE_PREFIX .. SwitchColor.color_component_id.BLUE)
  if cached_cmd ~= nil then
    local h = cached_cmd.args.color.hue
    local s = cached_cmd.args.color.saturation
    device:emit_event_for_endpoint(cmd.src_channel, capabilities.colorControl.hue(h))
    device:emit_event_for_endpoint(cmd.src_channel, capabilities.colorControl.saturation(s))
  elseif r ~= nil and g ~= nil and b ~= nil and (r > 0 or b > 0 or g > 0) then
    local h, s = utils.rgb_to_hsl(r, g, b)
    device:emit_event_for_endpoint(cmd.src_channel, capabilities.colorControl.hue(h))
    device:emit_event_for_endpoint(cmd.src_channel, capabilities.colorControl.saturation(s))
  end
end

local capability_handlers = {}

local function forward_to_set_color(driver, device, component, hue, saturation)
  local command = {
    component = component,
    args = {
      color = {
        hue = hue,
        saturation = saturation
      }
    }
  }
  local timer = device:get_field(HUE_SAT_DELAY_TIMER..component)
  if timer then
    driver:cancel_timer(timer)
  end
  timer = device.thread:call_with_delay(.2, function()
    capability_handlers.set_color(driver, device, command)
  end)
  device:set_field(HUE_SAT_DELAY_TIMER..component, timer)
end

function capability_handlers.set_hue(driver, device, command)
  device:set_field(HUE_CACHE..command.component, command.args.hue)
  local saturation = device:get_field(SAT_CACHE..command.component) or
    device:get_latest_state(command.component,
      capabilities.colorControl.ID,
      capabilities.colorControl.saturation.NAME,
      0
    )
  device:set_field(SAT_CACHE..command.component, nil)
  forward_to_set_color(driver, device, command.component, command.args.hue, saturation)
end

function capability_handlers.set_saturation(driver, device, command)
  device:set_field(SAT_CACHE..command.component, command.args.saturation)
  local hue = device:get_field(HUE_CACHE..command.component) or
    device:get_latest_state(command.component,
      capabilities.colorControl.ID,
      capabilities.colorControl.hue.NAME,
      0
    )
  device:set_field(HUE_CACHE..command.component, nil)
  forward_to_set_color(driver, device, command.component, hue, command.args.saturation)
end

--- Issue an RGB color set command to the specified device.
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param command table ST color control capability command
function capability_handlers.set_color(driver, device, command)
  local duration = constants.DEFAULT_DIMMING_DURATION
  local r, g, b = utils.hsl_to_rgb(command.args.color.hue, command.args.color.saturation)
  device:set_field(CAP_CACHE_KEY, command)
  local set = SwitchColor:Set({
    color_components = {
      { color_component_id=SwitchColor.color_component_id.RED, value=r },
      { color_component_id=SwitchColor.color_component_id.GREEN, value=g },
      { color_component_id=SwitchColor.color_component_id.BLUE, value=b },
      { color_component_id=SwitchColor.color_component_id.WARM_WHITE, value=0 },
      { color_component_id=SwitchColor.color_component_id.COLD_WHITE, value=0 },
    },
    duration=duration
  })
  device:send_to_component(set, command.component)
  local query_color = function()
    -- Use a single RGB color key to trigger our callback to emit a color
    -- control capability update.
    device:send_to_component(
      SwitchColor:Get({ color_component_id=SwitchColor.color_component_id.RED }),
      command.component
    )
  end
  device.thread:call_with_delay(constants.MIN_DIMMING_GET_STATUS_DELAY, query_color)
end

--- If the device supports the colorControl capability and the Switch Color
--- command class, return an array of Switch Color GET commands to retrieve
--- RGB state.
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param component string
--- @param endpoint integer
local function get_refresh_commands(driver, device, component, endpoint)
  if device:supports_capability_by_id(capabilities.colorControl.ID, component) and device:is_cc_supported(cc.SWITCH_COLOR, endpoint) then
    return {
      SwitchColor:Get({ color_component_id=SwitchColor.color_component_id.RED }, {dst_channels = {endpoint}}),
      SwitchColor:Get({ color_component_id=SwitchColor.color_component_id.GREEN }, {dst_channels = {endpoint}}),
      SwitchColor:Get({ color_component_id=SwitchColor.color_component_id.BLUE }, {dst_channels = {endpoint}}),
   }
  end
end

--- @class st.zwave.defaults.colorControl
--- @alias color_control_defaults st.zwave.defaults.colorControl
--- @field public zwave_handlers table
--- @field public capability_handlers table
local color_control_defaults = {
  zwave_handlers = {
    [cc.SWITCH_COLOR] = {
      [SwitchColor.REPORT] = zwave_handlers.switch_color_report
    }
  },
  capability_handlers = {
    [capabilities.colorControl.commands.setColor] = capability_handlers.set_color,
    [capabilities.colorControl.commands.setHue] = capability_handlers.set_hue,
    [capabilities.colorControl.commands.setSaturation] = capability_handlers.set_saturation,
  },
  get_refresh_commands = get_refresh_commands,
}

return color_control_defaults
