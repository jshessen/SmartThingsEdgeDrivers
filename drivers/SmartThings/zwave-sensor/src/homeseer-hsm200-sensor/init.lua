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
--- @type st.zwave.CommandClass.SwitchBinary
local SwitchMultilevel = (require "st.zwave.CommandClass.SwitchMultilevel")({version = 4})

--- Color
--- @type st.zwave.CommandClass.SwitchColor
local SwitchColor = (require "st.zwave.CommandClass.SwitchColor")({version=3,strict=true})

--- Notification
--- @type st.zwave.CommandClass.Notification
local Notification = (require "st.zwave.CommandClass.Notification")({version=3})

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

--- @function zwave_handlers.switch_multilevel_handler() -- 
--- Handles basic report commands for a Z-Wave switch device.
--- @param driver (Driver) The driver instance.
--- @param device (st.zwave.Device) The device instance.
--- @param command (Command) The command table.
function zwave_handlers.switch_multilevel_handler(driver, device, command)
  -- Declare local variables 'level' and 'value'
  local level = command.args.value or command.args.target_value -- Simplify if-else statement
  local value = (level > 0 or level == SwitchBinary.value.ON_ENABLE) and SwitchBinary.value.ON_ENABLE
                                                                    or SwitchBinary.value.OFF_DISABLE

  if command.component == "main" then
    --local set = SwitchBinary:Set({ target_value=value, duration=0 })
    local set = Basic:Set({ value=value })
    device:send(set)
    if value == SwitchBinary.value.ON_ENABLE then
      device:emit_event(capabilities.switch.switch.on())
    else
      device:emit_event(capabilities.switch.switch.off())
      local hue=capabilities.colorControl.hue(0)
      local saturation=capabilities.colorControl.saturation(0)
      device:emit_event_for_endpoint(command.src_channel,hue,saturation)
    end
    if device:supports_capability(capabilities.switchLevel, nil) then
      local dimmingDuration = command.args.rate or constants.DEFAULT_DIMMING_DURATION
      level = math.floor(level + 0.5) -- Round off 'level' to the nearest integer
      level = utils.clamp_value(level, 0, 99) -- Clamp 'level' to the range [0, 99]
  
      set = SwitchMultilevel:Set({value = level, duration = dimmingDuration })
      device:send(set) -- Send the 'set' command directly to the device
      local get = function()
        device:send(SwitchBinary:Get({})) -- Send a 'get' command to the device to get its current status
      end
      device.thread:call_with_delay(dimmingDuration, get)
    end
  end
end

--- @function zwave_handlers.switch_color_handler() --
--- Sets the switch color for a device based on a command.
--- @param driver (Driver) The driver object.
--- @param device (st.zwave.Device) The device object.
--- @param command (table) The input command.
function zwave_handlers.switch_color_handler(driver, device, command)
  local color = helpers.color.map[7]
  local hue
  local saturation
  if command.args.color then
    hue = command.args.color.hue
    saturation = command.args.color.saturation
    log.trace(string.format("***** HSM200 Driver *****: hue=%s, saturation=%s", hue, saturation))
    
    --log.trace(string.format("%s: basic_report_handler -- Find the closest supported color", device:pretty_print()))
    --color = helpers.color.find_closest_color(hue, saturation, nil)
  end
  --local r, g, b = helpers.color.hex_to_rgb(color.hex)
  local r, g, b = utils.hsl_to_rgb(hue,saturation,nil)
  
  if not r then
    log.error(string.format("%s: Failed to convert color Hue/Saturation to RGB.", device:pretty_print()))
    return
  end
  log.trace(string.format("***** HSM200 Driver *****: r=%s,g=%s,b=%s", r,g,b))
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



--- @function capability_handlers.switch_binary_handler() --
--- Handles "on/off" functionality
--- @param value (st.zwave.CommandClass.SwitchBinary.value)
--- @return (function)
function capability_handlers.switch_binary_handler(value)
    --- Hand off to zwave_handlers.switch_multilevel_handler
    --- @param driver (Driver) The driver object
    --- @param device (st.zwave.Device) The device object
    --- @param command (Command) Input command value
    --- @return (nil)
  return function(driver, device, command)
      command.args.value = value
      zwave_handlers.switch_multilevel_handler(device,device,command)
  end
end



local homeseer_multipurpose_sensor = {
  NAME = "HomeSeer Multipurpose Sensor",
  zwave_handlers = {
    [cc.BASIC] = {
      [Basic.REPORT] = zwave_handlers.switch_multilevel_handler
    },
    [cc.SWITCH_MULTILEVEL] = {
      [SwitchMultilevel.REPORT] = zwave_handlers.switch_multilevel_handler
    }
--[[     [cc.NOTIFICATIONS] = {
      [Notification.REPORT] = zwave_handlers.notification_report_handler
    } ]]
  },
  capability_handlers = {
    [capabilities.switch.ID] = {
      [capabilities.switch.switch.on.NAME] = capability_handlers.switch_binary_handler(SwitchBinary.value.ON_ENABLE),
      [capabilities.switch.switch.off.NAME] = capability_handlers.switch_binary_handler(SwitchBinary.value.OFF_DISABLE)
    },
    [capabilities.colorControl.ID] = {
      [capabilities.colorControl.commands.setColor.NAME] = capability_handlers.switch_color_handler
    }
  },
  can_handle = can_handle_homeseer_multipurpose_sensor
}

return homeseer_multipurpose_sensor