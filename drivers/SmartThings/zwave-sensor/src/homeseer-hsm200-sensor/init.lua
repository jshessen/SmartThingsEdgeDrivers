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
-- @type st.utils
local utils = require "st.utils"
--- @type st.zwave.CommandClass
local cc = require "st.zwave.CommandClass"
--- @type st.zwave.constants
local constants = require "st.zwave.constants"
--- @type st.zwave.CommandClass.Basic
local Basic = (require "st.zwave.CommandClass.Basic")({version=1,strict=true})
--- @type st.zwave.CommandClass.SwitchColor
local SwitchColor = (require "st.zwave.CommandClass.SwitchColor")({version=3,strict=true})
--- @type st.zwave.CommandClass.SwitchBinary
local SwitchBinary = (require "st.zwave.CommandClass.SwitchBinary")({version=2,strict=true})
--- @type st.zwave.CommandClass.Notification
local Notification = (require "st.zwave.CommandClass.Notification")({version=4})

local helpers = {}
helpers.color = (require "homeseer-switches.color_helper")

local CAP_CACHE_KEY = "st.capabilities." .. capabilities.colorControl.ID

local HOMESEER_MULTIPURPOSE_SENSOR_FINGERPRINTS = {
  { manufacturerId = 0x001E, productType = 0x0004, productId = 0x0001 }, -- EZmultiPli
  { manufacturerId = 0x0004, productType = 0x0004, productId = 0x0001 } -- HomeSeer HSM200
}

local function can_handle_homeseer_multipurpose_sensor(opts, driver, device, ...)
  for _, fingerprint in ipairs(HOMESEER_MULTIPURPOSE_SENSOR_FINGERPRINTS) do
    if device:id_match(fingerprint.manufacturerId, fingerprint.productType, fingerprint.productId) then
      return true
    end
  end
  return false
end

local function basic_report_handler(driver, device, cmd)
  local event
  local value = (cmd.args.target_value ~= nil) and cmd.args.target_value or cmd.args.value
  if value == SwitchBinary.value.OFF_DISABLE then
    event = capabilities.switch.switch.off()
    device:emit_event_for_endpoint(cmd.src_channel, capabilities.colorControl.hue(0))
    device:emit_event_for_endpoint(cmd.src_channel, capabilities.colorControl.saturation(0))
  else
    event = capabilities.switch.switch.on()
  end

  device:emit_event_for_endpoint(cmd.src_channel, event)
end

local TIMER = "timed_clear"
local function notification_report_handler(self, device, cmd)
  local event
  if cmd.args.notification_type == Notification.notification_type.HOME_SECURITY then
    if cmd.args.event == Notification.event.home_security.MOTION_DETECTION then
      event = capabilities.home_security.motion.active()
      local timer = device:get_field(TIMER)
      local delay = device:get_field("motionDelayTime")
      if timer ~= nil then --received a new event before the clear fired
        device.thread:cancel_timer(timer)
      end
      timer = device.thread:call_with_delay(delay, function(d)
        device:emit_event(capabilities.home_security.motion.inactive())
        device:set_field(TIMER, nil)
      end)
      device:set_field(TIMER, timer)
    elseif cmd.args.event == Notification.event.home_security.STATE_IDLE then
      event = capabilities.motionSensor.motion.inactive()
    end
  end

  if event ~= nil then
    device:emit_event(event)
  end
end

local function set_color(driver, device, command)
  local hue = command.args.color.hue
  local saturation = command.args.color.saturation

  local duration = constants.DEFAULT_DIMMING_DURATION
  local r, g, b = utils.hsl_to_rgb(hue, saturation, nil)

  r = (r >= 191) and 255 or 0
  g = (g >= 191) and 255 or 0
  b = (b >= 191) and 255 or 0

  local myhue, mysaturation = utils.rgb_to_hsl(r, g, b)

  command.args.color.hue = myhue
  command.args.color.saturation = mysaturation

  device:set_field(CAP_CACHE_KEY, command)

  helpers.color.set_switch_color(device, command, r,g,b)
end

local homeseer_multipurpose_sensor = {
  NAME = "HomeSeer Multipurpose Sensor",
  zwave_handlers = {
    [cc.BASIC] = {
      [Basic.REPORT] = basic_report_handler
    },
    [cc.NOTIFICATIONS] = {
      [Notification.REPORT] = notification_report_handler
    }
  },
  capability_handlers = {
    [capabilities.colorControl.ID] = {
      [capabilities.colorControl.commands.setColor.NAME] = set_color
    }
  },
  can_handle = can_handle_homeseer_multipurpose_sensor
}

return homeseer_multipurpose_sensor
