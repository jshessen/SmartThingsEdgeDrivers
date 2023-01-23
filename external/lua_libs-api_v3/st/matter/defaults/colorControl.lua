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
local ColorControl = clusters.ColorControl
local OnOff = clusters.OnOff
local log = require "log"
local utils = require "st.utils"

local CURRENT_X = "current_x_value" -- y value from xyY color space
local CURRENT_Y = "current_y_value" -- x value from xyY color space
local Y_TRISTIMULUS_VALUE = "y_tristimulus_value" -- Y tristimulus value which is used to convert color xyY -> RGB -> HSV
local HUESAT_TIMER = "huesat_timer"
local TARGET_HUE = "target_hue"
local TARGET_SAT = "target_sat"
local RECEIVED_X = "receivedX"
local RECEIVED_Y = "receivedY"
local HUESAT_SUPPORT = "huesatSupport"

--- @class st.matter.defaults.colorControl
--- @field public matter_handlers table
--- @field public subscribed_attributes table
--- @field public capability_handlers table
local color_control_defaults = {}

local function hue_attr_handler(driver, device, ib, response)
  if ib.data.value ~= nil then
    local hue = math.floor((ib.data.value / 0xFE * 100) + 0.5)
    device:emit_event_for_endpoint(ib.endpoint_id, capabilities.colorControl.hue(hue))
  end
end

local function sat_attr_handler(driver, device, ib, response)
  if ib.data.value ~= nil then
    local sat = math.floor((ib.data.value / 0xFE * 100) + 0.5)
    device:emit_event_for_endpoint(ib.endpoint_id, capabilities.colorControl.saturation(sat))
  end
end

local function x_attr_handler(driver, device, ib, response)
  local y = device:get_field(RECEIVED_Y)
  -- TODO it is likely that both x and y attributes are in the response (not guaranteed though)
  -- if they are we can avoid setting fields on the device.
  if y == nil then
    device:set_field(RECEIVED_X, ib.data.value)
  else
    local x = ib.data.value
    local h, s, _ = utils.safe_xy_to_hsv(x, y)
    device:emit_event_for_endpoint(ib.endpoint_id, capabilities.colorControl.hue(h))
    device:emit_event_for_endpoint(ib.endpoint_id, capabilities.colorControl.saturation(s))
    device:set_field(RECEIVED_Y, nil)
  end
end

local function y_attr_handler(driver, device, ib, response)
  local x = device:get_field(RECEIVED_X)
  if x == nil then
    device:set_field(RECEIVED_Y, ib.data.value)
  else
    local y = ib.data.value
    local h, s, _ = utils.safe_xy_to_hsv(x, y)
    device:emit_event_for_endpoint(ib.endpoint_id, capabilities.colorControl.hue(h))
    device:emit_event_for_endpoint(ib.endpoint_id, capabilities.colorControl.saturation(s))
    device:set_field(RECEIVED_X, nil)
  end
end

local function color_cap_attr_handler(driver, device, ib, response)
  if ib.data.value ~= nil then
    if ib.data.value & 0x1 then device:set_field(HUESAT_SUPPORT, true) end
  end
end

local query_device = function(device)
  return function()
    device:send(ColorControl.attributes.CurrentX:read(device))
    device:send(ColorControl.attributes.CurrentY:read(device))
  end
end

local function store_xyY_values(device, x, y, Y)
  device:set_field(Y_TRISTIMULUS_VALUE, Y)
  device:set_field(CURRENT_X, x)
  device:set_field(CURRENT_Y, y)
end

local function handle_set_color(driver, device, cmd)
  -- Cancel the hue/sat timer if it's running, since setColor includes both hue and saturation
  local huesat_timer = device:get_field(HUESAT_TIMER)
  if huesat_timer ~= nil then
    device.thread:cancel_timer(huesat_timer)
    device:set_field(HUESAT_TIMER, nil)
  end

  local hue = (cmd.args.color.hue ~= nil and cmd.args.color.hue > 99) and 99 or cmd.args.color.hue
  local sat = cmd.args.color.saturation

  local x, y, Y = utils.safe_hsv_to_xy(hue, sat)
  store_xyY_values(device, x, y, Y)

  local endpoint_id = device:component_to_endpoint(cmd.component)
  local req = clusters.OnOff.server.commands.On(device, endpoint_id)
  device:send(req)
  device:send(ColorControl.server.commands.MoveToColor(device, endpoint_id, x, y, 0, 0, 0))

  device:set_field(TARGET_HUE, nil)
  device:set_field(TARGET_SAT, nil)
  device.thread:call_with_delay(2, query_device(device))
end

local huesat_timer_callback = function(driver, device, cmd)
  return function()
    local hue = device:get_field(TARGET_HUE)
    local sat = device:get_field(TARGET_SAT)
    hue = hue ~= nil and hue
            or device:get_latest_state(
              "main", capabilities.colorControl.ID, capabilities.colorControl.hue.NAME
            )
    sat = sat ~= nil and sat or device:get_latest_state(
            "main", capabilities.colorControl.ID, capabilities.colorControl.saturation.NAME
          )
    cmd.args = {color = {hue = hue, saturation = sat}}
    handle_set_color(driver, device, cmd)
  end
end

local function set_hue_sat_helper(driver, device, cmd, hue, sat)
  local huesat_timer = device:get_field(HUESAT_TIMER)
  if huesat_timer ~= nil then
    device.thread:cancel_timer(huesat_timer)
    device:set_field(HUESAT_TIMER, nil)
  end
  if hue ~= nil and sat ~= nil then
    cmd.args = {color = {hue = hue, saturation = sat}}
    handle_set_color(driver, device, cmd)
  else
    if hue ~= nil then
      device:set_field(TARGET_HUE, hue)
    elseif sat ~= nil then
      device:set_field(TARGET_SAT, sat)
    end
    device:set_field(
      HUESAT_TIMER, device.thread:call_with_delay(0.2, huesat_timer_callback(driver, device, cmd))
    )
  end
end

local function handle_set_hue(driver, device, cmd)
  set_hue_sat_helper(driver, device, cmd, cmd.args.hue, device:get_field(TARGET_SAT))
end

local function handle_set_saturation(driver, device, cmd)
  set_hue_sat_helper(driver, device, cmd, device:get_field(TARGET_HUE), cmd.args.saturation)
end

color_control_defaults.matter_handlers = {
  attr = {
    [clusters.ColorControl.ID] = {
      [clusters.ColorControl.attributes.CurrentHue.ID] = hue_attr_handler,
      [clusters.ColorControl.attributes.CurrentSaturation.ID] = sat_attr_handler,
      [clusters.ColorControl.attributes.CurrentX.ID] = x_attr_handler,
      [clusters.ColorControl.attributes.CurrentY.ID] = y_attr_handler,
      [clusters.ColorControl.attributes.ColorCapabilities.ID] = color_cap_attr_handler,
    },
  },
}
color_control_defaults.capability_handlers = {
  [capabilities.colorControl.commands.setColor] = handle_set_color,
  [capabilities.colorControl.commands.setHue] = handle_set_hue,
  [capabilities.colorControl.commands.setSaturation] = handle_set_saturation,
}
color_control_defaults.subscribed_attributes = {
  clusters.ColorControl.attributes.CurrentHue,
  clusters.ColorControl.attributes.CurrentSaturation,
  clusters.ColorControl.attributes.CurrentX,
  clusters.ColorControl.attributes.CurrentY,
}

return color_control_defaults
