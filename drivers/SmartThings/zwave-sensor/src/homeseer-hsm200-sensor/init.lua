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

-- @type st.capabilities
local capabilities = require "st.capabilities"

--- @type st.zwave.CommandClass
local cc = require "st.zwave.CommandClass"

--- @type st.zwave.constants
local constants = require "st.zwave.constants"
-- @type st.utils
local utils = require "st.utils"
-- @type log
local log = require "log"


--- Switch
--- @type st.zwave.CommandClass.Basic
local Basic = (require "st.zwave.CommandClass.Basic")({version=1,strict=true})
--- @type st.zwave.CommandClass.SwitchBinary
local SwitchBinary = (require "st.zwave.CommandClass.SwitchBinary")({version=2,strict=true})

--- Color
--- @type st.zwave.CommandClass.SwitchColor
local SwitchColor = (require "st.zwave.CommandClass.SwitchColor")({version=3,strict=true})

--- Notification
--- @type st.zwave.CommandClass.Notification
local Notification = (require "st.zwave.CommandClass.Notification")({version=3})


--- @type string
local CAP_CACHE_KEY = "st.capabilities." .. capabilities.colorControl.ID
--- @type table
local helpers = {}
helpers.color = (require "homeseer-hsm200-sensor.color_helper")



local HOMESEER_MULTIPURPOSE_SENSOR_FINGERPRINTS = {
  { id = "EZmultiPli/Sensor/EZMP",  manufacturerId = 0x0018, productType = 0x0004, productId = 0x0001 }, -- EZmultiPli
  { id = "HomeSeer/Sensor/HSM200",  manufacturerId = 0x0004, productType = 0x0004, productId = 0x0001 } -- HomeSeer HSM200
}

--- @function can_handle_homeseer_multipurpose_sensor() --
--- Determine whether the passed device is a HomeSeer sensor.
--- @param opts (table)
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @vararg ... any
--- @return (boolean)
local function can_handle_homeseer_multipurpose_sensor(opts, driver, device, ...)
  for _, fingerprint in ipairs(HOMESEER_MULTIPURPOSE_SENSOR_FINGERPRINTS) do
    if device:id_match(fingerprint.mfr, fingerprint.prod, fingerprint.model) then
      return true
    end
  end
  return false
end



--- @local table
local zwave_handlers = {}
--- @local table
local capability_handlers = {}

--- @function zwave_handlers.basic_report_handler() -- 
--- Handles basic report commands for a Z-Wave switch device.
--- @param driver (Driver) The driver instance.
--- @param device (st.zwave.Device) The device instance.
--- @param command (Command) The command table.
function zwave_handlers.basic_report_handler(driver, device, command)
  local value = command.args.target_value or command.args.value

  log.trace(string.format("%s: basic_report_handler -- I'm in", device:pretty_print()))
  if value == SwitchBinary.value.OFF_DISABLE then
    local hueEvent = capabilities.colorControl.hue(0)
    local saturationEvent = capabilities.colorControl.saturation(0)
    local offEvent = capabilities.switch.switch.off()

    log.trace(string.format("%s: basic_report_handler -- OFF", device:pretty_print()))

    if not device:emit_event_for_endpoint(command.src_channel, offEvent) then
      log.error(string.format("%s: Failed to emit event for turning off the switch.", device:pretty_print()))
    end
    if not device:emit_event_for_endpoint(command.src_channel, hueEvent, saturationEvent) then
      log.error(string.format("%s: Failed to emit event for setting hue and saturation to 0.", device:pretty_print()))
    end
  else
    log.trace(string.format("%s: basic_report_handler -- ON", device:pretty_print()))
    local onEvent = capabilities.switch.switch.on()
    if not device:emit_event_for_endpoint(command.src_channel, onEvent) then
      log.error(string.format("%s: Failed to emit event for turning on the switch.", device:pretty_print()))
    end
  end
end

--- @function zwave_handlers.switch_color_handler() --
--- Sets the switch color for a device based on a command.
--- @param driver (Driver) The driver object.
--- @param device (st.zwave.Device) The device object.
--- @param command (table) The input command.
function zwave_handlers.switch_color_handler(driver, device, command)
  log.trace(string.format("%s: switch_color_handler -- I'm in", device:pretty_print()))
  local color = helpers.color.map[7]
  local hue = command.args.color.hue
  local saturation = command.args.color.saturation
  if command.args.color then
    log.trace(string.format("%s: basic_report_handler -- A color was passed to this function", device:pretty_print()))
    log.trace(string.format("%s: basic_report_handler -- hue=", device:pretty_print(), hue))
    log.trace(string.format("%s: basic_report_handler -- saturation=", device:pretty_print(),saturation))
    
    --log.trace(string.format("%s: basic_report_handler -- Find the closest supported color", device:pretty_print()))
    color = helpers.color.find_closest_color(hue, saturation, nil)
  end
  log.trace(string.format("%s: basic_report_handler -- OFF", device:pretty_print()))
  --local r, g, b = helpers.color.hex_to_rgb(color.hex)
  local r, g, b = utils.hsl_to_rgb(hue,saturation,nil)

  log.trace(string.format("%s: basic_report_handler -- r=%s,g=%s,b=%s", device:pretty_print(),r,g,b))
  if not r then
    log.error(string.format("%s: Failed to convert color hex to RGB. color.hex=%s", device:pretty_print(), color.hex))
    return
  end

  local myhue, mysaturation, mylightness = utils.rgb_to_hsl(r, g, b)
  log.trace(string.format("%s: basic_report_handler -- myhue=%s,mysat=%s", device:pretty_print(),myhue, mysaturation))
  command.args.color = {
    hue = myhue,
    saturation = mysaturation,
  }
  device:set_field(CAP_CACHE_KEY, command)

  helpers.color.set_switch_color(device, command, r, g, b)
end
capability_handlers.switch_color_handler = zwave_handlers.switch_color_handler


local TIMER = "timed_clear"
function zwave_handlers.notification_report_handler(self, device, cmd)
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



local homeseer_multipurpose_sensor = {
  NAME = "HomeSeer Multipurpose Sensor",
  zwave_handlers = {
    [cc.BASIC] = {
      [Basic.REPORT] = zwave_handlers.basic_report_handler
    },
--[[     [cc.NOTIFICATIONS] = {
      [Notification.REPORT] = zwave_handlers.notification_report_handler
    } ]]
  },
  capability_handlers = {
    [capabilities.colorControl.ID] = {
      [capabilities.colorControl.commands.setColor.NAME] = capability_handlers.switch_color_handler
    }
  },
  can_handle = can_handle_homeseer_multipurpose_sensor
}

return homeseer_multipurpose_sensor