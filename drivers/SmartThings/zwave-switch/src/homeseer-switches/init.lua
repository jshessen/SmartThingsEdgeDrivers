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
local HOMESEER_SWITCH_FINGERPRINTS = {
  {id = "HomeSeer/Switch/WS100",  mfr = 0x000C, prod = 0x4447, model = 0x3033}, -- HomeSeer WS100 Switch
  {id = "HomeSeer/Dimmer/WD100",  mfr = 0x000C, prod = 0x4447, model = 0x3034}, -- HomeSeer WD100 Dimmer
  {id = "HomeSeer/Switch/WS200",  mfr = 0x000C, prod = 0x4447, model = 0x3035}, -- HomeSeer WS200 Switch
  {id = "HomeSeer/Dimmer/WD200",  mfr = 0x000C, prod = 0x4447, model = 0x3036}, -- HomeSeer WD200 Dimmer
  {id = "HomeSeer/Dimmer/WX300D", mfr = 0x000C, prod = 0x4447, model = 0x4036}, -- HomeSeer WX300 Dimmer
  {id = "HomeSeer/Dimmer/WX300S", mfr = 0x000C, prod = 0x4447, model = 0x4037}, -- HomeSeer WX300 Switch
  {id = "ZLink/Switch/WS100",     mfr = 0x0315, prod = 0x4447, model = 0x3033}, -- ZLink ZL-WS-100 Switch - ZWaveProducts.com
  {id = "ZLink/Dimmer/WD100",     mfr = 0x0315, prod = 0x4447, model = 0x3034}, -- ZLink ZL-WD-100 Dimmer - ZWaveProducts.com
}

--- @function can_handle_homeseer_switches() --
--- Determine whether the passed device is a HomeSeer switch.
--- @param opts (table)
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @vararg ... any
--- @return (boolean)
local function can_handle_homeseer_switches(opts, driver, device, ...)
  for _, fingerprint in ipairs(HOMESEER_SWITCH_FINGERPRINTS) do
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
--- Handles "dimmer/level" functionality
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @param command (Command) Input command value
--- @return (nil)
function zwave_handlers.switch_multilevel_handler(driver, device, command)
  -- Declare local variables 'value', 'level' and 'dimmingDuration'
  local value = command.args.value and command.args.value or command.args.target_value
  local level = command.args.level and utils.clamp_value(math.floor(command.args.level + 0.5), 0, 99)
  local event = (level and level > 0 or value == SwitchBinary.value.ON_ENABLE) and capabilities.switch.switch.on() or capabilities.switch.switch.off()
  local dimmingDuration = command.args.rate or constants.DEFAULT_DIMMING_DURATION

  if command.component == "main" then -- "main" = command.src_channel = endpoint = 0
    -- Emit switch on or off event depending on the value of 'level'
    device:emit_event_for_endpoint(command.src_channel,event)

    -- If the device supports switch level capability
    if device:supports_capability(capabilities.switchLevel, nil) then
      local set = SwitchMultilevel:Set({value = level, duration = dimmingDuration })
      device:send_to_component(set, command.component)
      local get = function()
        device:send_to_component(SwitchBinary:Get({}), command.component)
      end
      device.thread:call_with_delay(constants.DEFAULT_GET_STATUS_DELAY, get)
    end
  else
    if device:supports_capability(capabilities.colorControl,nil) then
      -- If needed?
    end
    command.args.value = event
    helpers.led.set_status_color(device, command)
  end
end

--- @function zwave_handlers.switch_multilevel_stop_level_change_handler() --
--- Handles the stopping of a switch level change on Z-Wave devices
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @param command (Command) Input command value
--- @return (nil)
function zwave_handlers.switch_multilevel_stop_level_change_handler(driver, device, command)
  --- Emits an event with the switch capability "on"
  device:emit_event(capabilities.switch.switch.on())
  
  --- Sends a `SwitchMultilevel:Get` command to the device
  device:send(SwitchMultilevel:Get({}))
end

--- @function zwave_handlers.emit_central_scene_events() --
--- Handles "Scene" functionality
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @param command (Command) Input command value
--- @return (nil)
function zwave_handlers.emit_central_scene_events(driver,device,command)
  helpers.multi_tap.emit_central_scene_events(device,command)
end

--- @function zwave_handlers.switch_color_handler() --
--- Sets component color to closes supported color match
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @param command (table) Input command value
--- @return (nil)
function zwave_handlers.switch_color_handler(driver, device, command)
  command.args.value = SwitchBinary.value.ON_ENABLE
  helpers.led.set_status_color(device, command)
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
    log.info(string.format("%s [%s] : Defined Profile: %s", device.id, device.device_network_id, profile))
  end
end

--- @function capability_handlers.do_refresh() --
--- Refresh Device
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @param command (Command) Input command value
--- @return (nil)
function capability_handlers.do_refresh(driver, device, command)
  --- Determine the component for the command
  local component = command and command.component or "main"
  local capability = device:supports_capability(capabilities.switch, component) and capabilities.switch or
                      device:supports_capability(capabilities.switchLevel, component) and capabilities.switchLevel
  --- Check if the device supports switch level capability
  if capability then
    device:send_to_component(capability == capabilities.switch and SwitchBinary:Get({}) or SwitchMultilevel:Get({}), component)
  end
end

--- @local (table)
local custom_capabilities = {}
custom_capabilities.firmwareVersion = {}
custom_capabilities.firmwareVersion.name = "firmwareVersion"
custom_capabilities.firmwareVersion.capability = capabilities[custom_capabilities.firmwareVersion.name]

--- @function capability_handlers.checkForFirmwareUpdate_handler() --
--- Check to see if there is a firmware update available for the device
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @param command (Command) Input command value
--- @return (nil)
function capability_handlers.checkForFirmwareUpdate_handler(driver, device, command)
    --- Check if the device supports Firmware capability
    if (device:supports_capability(capabilities.firmwareUpdate, nil)) then
      log.info_with({hub_logs=true}, string.format("Current Firmware: %s", device.firmware_version))
    end
end

--- @function capability_handlers.updateFirmware_handler() --
--- Check to see if there is a firmware update available for the device
--- @param driver (Driver) The driver object
--- @param device (st.zwave.Device) The device object
--- @param command (Command) Input command value
--- @return (nil)
function capability_handlers.updateFirmware_handler(driver, device, command)
    --- Check if the device supports Firmware capability
    if (device:supports_capability(capabilities.firmwareUpdate, nil)) then
      log.info_with({hub_logs=true}, string.format("Current Firmware: %s", device.firmware_version))
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
  --- Check if the network type is not ZWAVE
  if device.network_type ~= st_device.NETWORK_TYPE_ZWAVE then
    return
  end

  --- Log the device init message
  log.info(string.format("%s: %s > DEVICE INIT", device.id, device.device_network_id))
  
  device:set_component_to_endpoint_fn(component_to_endpoint)
  device:set_endpoint_to_component_fn(endpoint_to_component)

  --- Call the init lifecycle handler
  call_parent_handler(self.lifecycle_handlers.init, self, device, event, args)
end

--- @function info_changed()
--- @param self (Driver) Reference to the current object
--- @param device (st.zwave.Device) Device object that is added
--- @param event (Event)
--- @param args (any)
local function info_changed(self, device, event, args)
  --- Log the device id and network id
  log.info(string.format("%s: %s > INFO_CHANGED", device.id, device.device_network_id))
    --- Check if the operating mode has changed
    if args.old_st_store.preferences.operatingMode ~= device.preferences.operatingMode then
        -- We may need to update our device profile
        device:send(Version:Get({}))
    end
  -- Call the topmost "infoChanged" lifecycle hander to do any default work
  call_parent_handler(self.lifecycle_handlers.infoChanged, self, device, event, args)
end



local homeseer_switches = {
  NAME = "HomeSeer Z-Wave Switches",
  can_handle = can_handle_homeseer_switches,
  zwave_handlers = {
    --- Switch
    [cc.BASIC] = {
      [Basic.Set] = zwave_handlers.switch_multilevel_handler,
      [Basic.Report] = zwave_handlers.switch_multilevel_handler
    },
    [cc.SWITCH_BINARY] = {
      [SwitchBinary.Set] = zwave_handlers.switch_multilevel_handler,
      [SwitchBinary.Report] = zwave_handlers.switch_multilevel_handler
    },
    [cc.SWITCH_MULTILEVEL] = {
      [SwitchMultilevel.Set] = zwave_handlers.switch_multilevel_handler,
      [SwitchMultilevel.Report] = zwave_handlers.switch_multilevel_handler,
      [SwitchMultilevel.STOP_LEVEL_CHANGE] = zwave_handlers.switch_multilevel_stop_level_change_handler
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
    [capabilities.refresh.ID] = {
      [capabilities.refresh.commands.refresh.NAME] = capability_handlers.do_refresh
    },
    [capabilities.colorControl.ID] = {
      [capabilities.colorControl.commands.setColor.NAME] = capability_handlers.switch_color_handler --- alias to zwave_handlers.switch_color_handler
    },
    --- Placeholder
    [capabilities.firmwareUpdate] = {
      [capabilities.firmwareUpdate.commands.checkForFirmwareUpdate] = capability_handlers.checkForFirmwareUpdate_handler,
      [capabilities.firmwareUpdate.commands.updateFirmware] = capability_handlers.updateFirmware_handler
    }
  },
  lifecycle_handlers = {
    init = device_init,
    --added = added_handler,
    --doConfigure = do_configure,
    infoChanged = info_changed,
    --driverSwitched = driver_switched,
    --removed = removed
  }
}
return homeseer_switches