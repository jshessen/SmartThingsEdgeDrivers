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
--- @type st.zwave.Device
local st_device = require "st.zwave.device"
-- @type st.zwave.CommandClass
local cc = require "st.zwave.CommandClass"

-- @type st.zwave.constants
local constants = require "st.zwave.constants"
-- @type st.utils
local utils = require "st.utils"
-- @type log
local log = require "log"
local preferences = require "preferences"



--- Switch
--- @type Basic
local Basic = (require "st.zwave.CommandClass.Basic")({version = 2, strict = true})
--- @type SwitchBinary
local SwitchBinary = (require "st.zwave.CommandClass.SwitchBinary")({version = 2, strict = true})

--- Dimmer
--- @type SwitchMultilevel
local SwitchMultilevel = (require "st.zwave.CommandClass.SwitchMultilevel")({version = 4})

--- Color
--- @type SwitchColor
local SwitchColor = (require "st.zwave.CommandClass.SwitchColor")({version = 3, strict = true})

--- Button
--- @type CentralScene
local CentralScene = (require "st.zwave.CommandClass.CentralScene")({version = 1})

--- Misc
--- @type Version
local Version = (require "st.zwave.CommandClass.Version")({version = 3})
--- @type table
local helpers = {}
helpers.color = (require "homeseer-switches.color_helper")
helpers.multi_tap = (require "homeseer-switches.multi_tap_helper")
helpers.profile = (require "homeseer-switches.profile_helper")
helpers.led = (require "homeseer-switches.led_helper")

--- @local (table)
local HOMESEER_FAN_FINGERPRINTS = {
  {id = "HomeSeer/Dimmer/WD200",  mfr = 0x000C, prod = 0x0203, model = 0x0001}, -- HomeSeer FC200 Fan Controller
}

--- @function can_handle_homeseer_fan_controller() --
--- Determine whether the passed device is a HomeSeer Fan Controller.
--- @param opts (table)
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @vararg ... any
--- @return (boolean)
local function can_handle_homeseer_fan_controller(opts, driver, device, ...)
  for _, fingerprint in ipairs(HOMESEER_FAN_FINGERPRINTS) do
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


--- @function zwave_handlers.fan_multilevel_handler() --
--- Convert `SwitchMultilevel` level {0 - 99}
--- into `FanSpeed` speed { 0, 1, 2, 3, 4}
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @param command (st.zwave.CommandClass.SwitchMultilevel.Report)
--- @return (nil)
function zwave_handlers.fan_multilevel_handler(driver, device, command)
  if device.preferences.fanType then
    fan_speed_helper.capability_handlers.fan_speed_set(driver, device, command, zwave_fan_4_speed.map_switch_level_to_fan_4_speed)
  else
    fan_speed_helper.capability_handlers.fan_speed_set(driver, device, command, zwave_fan_3_speed.map_switch_level_to_fan_3_speed)
  end
end

--- @function zwave_handlers.emit_central_scene_events() --
--- Handles "Scene" functionality
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @param command (Command) Input command value
--- @return (nil)
function zwave_handlers.emit_central_scene_events(driver,device,command)
  helpers.multi_tap.handle_central_scene_functionality(device,command)
end

--- @function zwave_handlers.switch_color_handler() --
--- Sets component color to closes supported color match
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @param command (table) Input command value
--- @return (nil)
function zwave_handlers.switch_color_handler(driver, device, command)
  local success, err_msg = pcall(function()
    command.args.value = SwitchBinary.value.ON_ENABLE
    helpers.led.set_status_color(device, command)
  end)

  if not success then
    log.error(string.format("%s: Failed to set color for device. Error: %s", device:pretty_print(), err_msg))
  end
end
capability_handlers.switch_color_handler = zwave_handlers.switch_color_handler

--- @function zwave_handlers.version_report_handler() --
--- Adjust profile definition based upon reported firmware version
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @param command (Command) Input command value
function zwave_handlers.version_report_handler(driver, device, command)
  command.args.fingerprints = HOMESEER_SWITCH_FINGERPRINTS
  local profile = helpers.profile.get_device_profile(device,command.args)
  if profile then
    assert (device:try_update_metadata({profile = profile}), "Failed to change device profile")
    log.info(string.format("%s: Defined Profile=%s", device:pretty_print(), profile))
  end
end



--- @function capability_handlers.fan_speed_set() --
--- Issue a level-set command to the specified device.
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @param command (table) ST level capability command
--- @return (nil)
function capability_handlers.fan_speed_set(driver, device, command)
  local operatingMode = tonumber(device.preferences.fanType)
  if device.preferences.fanType then
    fan_speed_helper.capability_handlers.fan_speed_set(driver, device, command, zwave_fan_4_speed.map_fan_4_speed_to_switch_level)
  else
    fan_speed_helper.capability_handlers.fan_speed_set(driver, device, command, zwave_fan_3_speed.map_fan_3_speed_to_switch_level)
  end
end



--- @function call_parent_handler() --
--- Invoke handlers for a specific event
--- @param handlers (function|table) Function or tables of functions to call as event handlers.
--- @param self (Driver) Reference to the current object
--- @param device (st.zwave.Device) Device object that is added
--- @param event (Event)
--- @param args (any)
local function call_parent_handler(handlers, self, device, event, args)
  -- check if `handlers` is not a table; if true wrap as table
  local handlers_table = (type(handlers) == "function" and { handlers } or handlers) --[[@as table]];
  -- Invoke each function in the handlers table and pass the provided arguments.
  for i, func in pairs( handlers_table or {} ) do
      func(self, device, event, args)
  end
end

--- @function component_to_endpoint() --
--- Map component to end_points (channels)
--- @param device (st.zwave.Device)
--- @param component_id (string) ID
--- @return table dst_channels destination channels e.g. {2} for Z-Wave channel 2 or {} for unencapsulated
local function component_to_endpoint(device, component_id)
  if component_id == "main" then
    return { 0 }
  else
    local ep_num = component_id:match("LED-(%d)")
    return { ep_num and tonumber(ep_num) }
  end
end

--- @function component_to_endpoint() --
--- Map component to end_points (channels)
--- @param device (st.zwave.Device)
--- @param ep (number)
--- @return (string) component_id
local function endpoint_to_component(device, ep)
  local led_comp = string.format("LED-%d", ep)
  if device.profile.components[led_comp] ~= nil then
    return led_comp
  else
    return "main"
  end
end



--- @function device_init() --
--- Initialize device
--- @param self (Driver) Reference to the current object
--- @param device (st.zwave.Device) Device object that is added
--- @param event (Event)
--- @param args (any)
local function device_init(self, device, event, args)
  -- Check if the network type is not ZWAVE
  if device.network_type ~= st_device.NETWORK_TYPE_ZWAVE then
    return
  end

  device:set_component_to_endpoint_fn(component_to_endpoint)
  device:set_endpoint_to_component_fn(endpoint_to_component)

  -- Call the info_changed lifecycle handler
  call_parent_handler(self.lifecycle_handlers.init, self, device, event, args)
end

--- @function info_changed()
--- @param self (Driver) Reference to the current object
--- @param device (st.zwave.Device) Device object that is added
--- @param event (Event)
--- @param args (any)
local function info_changed(self, device, event, args)
  -- Check if the operating mode has changed
  if args.old_st_store.preferences.operatingMode ~= device.preferences.operatingMode then
    -- We may need to update our device profile
    device:send(Version:Get({}))
  end

  -- Handle blink functionality
  local old_blink_freq = args.old_st_store.preferences.ledBlinkFrequency
  local new_blink_freq = device.preferences.ledBlinkFrequency
  if old_blink_freq ~= new_blink_freq then
    if new_blink_freq == 0 or old_blink_freq == 0 then
      helpers.led.set_blink_bitmask(device)
    end
  end

  for id = 1, device:component_count()-1 do
    local blink_id = "ledStatusBlink" .. id
    if args.old_st_store.preferences[blink_id] ~= device.preferences[blink_id] then
      helpers.led.set_blink_bitmask(device)
    end
  end

  -- Call the info_changed lifecycle handler
  call_parent_handler(self.lifecycle_handlers.infoChanged, self, device, event, args)
end

--- @function driver_switched()
--- @param self (Driver) Reference to the current object
--- @param device (st.zwave.Device) Device object that is added
--- @param event (Event)
--- @param args (any)
local function driver_switched(self, device, event, args)
  device:send(Version:Get({}))
  device:refresh()
  -- Call the info_changed lifecycle handler
  call_parent_handler(self.lifecycle_handlers.driverSwitched, self, device, event, args)
end

--- @function do_configure()
--- @param self (Driver) Reference to the current object
--- @param device (st.zwave.Device) Device object that is added
--- @param event (Event)
--- @param args (any)
local function do_configure(self, device, event, args)
  device:refresh()
  -- Call the info_changed lifecycle handler
  call_parent_handler(self.lifecycle_handlers.doConfigure, self, device, event, args)
end



local homeseer_fan_controller = {
  NAME = "HomeSeer Z-Wave Fan Controller",
  zwave_handlers = {
    --- Switch
    [cc.BASIC] = {
      [Basic.REPORT] = zwave_handlers.fan_multilevel_handler
    },
    [cc.SWITCH_MULTILEVEL] = {
      [SwitchMultilevel.REPORT] = zwave_handlers.fan_multilevel_handler
    },
    [cc.SWITCH_COLOR] = {
      [SwitchColor.Report] = zwave_handlers.switch_color_handler
    },
    --- Button
    [cc.CENTRAL_SCENE] = {
      [CentralScene.NOTIFICATION] = zwave_handlers.emit_central_scene_events
    },
    --- Return firmware version
    [cc.VERSION] = {
      [Version.REPORT] = zwave_handlers.version_report_handler
    }    
  },
  capability_handlers = {
    [capabilities.fanSpeed.ID] = {
      [capabilities.fanSpeed.commands.setFanSpeed.NAME] = capability_handlers.fan_speed_set
    },
    [capabilities.colorControl.ID] = {
      [capabilities.colorControl.commands.setColor.NAME] = capability_handlers.switch_color_handler --- alias to zwave_handlers.switch_color_handler
    }
  },
  lifecycle_handlers = {
    init = device_init,
    --added = added_handler,
    doConfigure = do_configure,
    infoChanged = info_changed,
    driverSwitched = driver_switched,
    --removed = removed
  },
  can_handle = can_handle_homeseer_fan_controller,
}

return homeseer_fan_controller