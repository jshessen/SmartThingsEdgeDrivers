--&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
-- Author: Jeff Hessenflow (jshessen)
--
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
-- 
--&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&



--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-- Required Libraries
--

local st_device = require "st.device"
-- @type st.capabilities
local capabilities = require "st.capabilities"
-- @type st.zwave.CommandClass
local cc = require "st.zwave.CommandClass"

-- @type log
local log = require "log"

-- Notification
-- @type st.zwave.CommandClass.Notification
local Notification = (require "st.zwave.CommandClass.Notification")({ version = 3 })
-- Switch
local Basic = (require "st.zwave.CommandClass.Basic")({ version = 1, strict = true })
local SwitchBinary = (require "st.zwave.CommandClass.SwitchBinary")({ version = 2, strict = true })

--
--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



--?????????????????????????????????????????????????????????????????
-- Variables/Constants
--

--- Map HomeSeer Fingerprints
local HOMESEER_FLOODLIGHT_SENSOR_FINGERPRINTS = {
  {mfr = 0x000C, prod = 0x0201, model = 0x000B}, -- HomeSeer FLS100 Floodlight Sensor
  {mfr = 0x000C, prod = 0x0201, model = 0x000C}, -- HomeSeer FLS100-G2 Floodlight Sensor
}

--
--?????????????????????????????????????????????????????????????????



--- #################################################################
--- Section: Can Handle
--- #######################################################
---

--- @function can_handle_homeseer_sensors --
--- Determine whether the passed device is a HomeSeer switch.
--- Iterates over the fingerprints in `HOMESEER_FLOODLIGHT_SENSOR_FINGERPRINTS` and
--- checks if the device's id matches the fingerprint's manufacturer, product, and model id.
--- If a match is found, the function returns true, else it returns false.
--- @param opts (table)
--- @param driver (Driver) The driver object
--- @param device (st.Device) The device object
--- @vararg ... any
--- @return (boolean)
local function can_handle_homeseer_sensors(opts, driver, device, ...)
  for _, fingerprint in ipairs(HOMESEER_FLOODLIGHT_SENSOR_FINGERPRINTS) do
    if device:id_match(fingerprint.mfr, fingerprint.prod, fingerprint.model) then
      log.info(device.zwave_manufacturer_id)
      return true
    end
  end
  return false
end

---
--- #######################################################
---
--- #################################################################



--- #################################################################
--- Section: Z-Wave Handlers
---
--- ############################################################
--- Subsection: Notification
---
--- #######################################################
---

--- @function notification_report_handler
--- @param self any
--- @param device (st.Device) The device object
--- @param command (Command) Input command value
--- @return (nil)
local function notification_report_handler(self, device, command)
  local event
  if command.args.notification_type == Notification.notification_type.POWER_MANAGEMENT then
    if command.args.event == Notification.event.power_management.AC_MAINS_DISCONNECTED then
      event = capabilities.powerSource.powerSource.battery()
    elseif command.args.event == Notification.event.power_management.AC_MAINS_RE_CONNECTED then
      event = capabilities.powerSource.powerSource.dc()
    end
  end

  if event ~= nil then
    device:emit_event(event)
  end
end

---
--- #######################################################
---
--- ############################################################
---
--- #################################################################



--- #################################################################
--- Section: Capability Handlers
---
--- #######################################################
---

--- @function: do_referesh --
--- Refresh Device
--- @param driver (Driver) The driver object
--- @param device (st.Device) The device object
--- @param command (Command) Input command value
--- @return (nil)
local function do_refresh(driver, device, command)
    --- Determine the component for the command
    local component = command and command.component and command.component or "main"
    --- Check if the device supports switch level capability
    if device:supports_capability(capabilities.switch, component) then
        --- Send Get command to the switch component
        device:send_to_component(SwitchBinary:Get({}), component)
    end
end

---
--- #######################################################
---
--- #################################################################



--/////////////////////////////////////////////////////////////////
-- Section: Driver
--
--///////////////////////////////////////////////////////
local homeseer_floodlight_sensor = {
  NAME = "HomeSeer Z-Wave Sensor",
  can_handle = can_handle_homeseer_sensors,
  zwave_handlers = {
    [cc.NOTIFICATION] = {
      [Notification.REPORT] = notification_report_handler
    }
  },
  capability_handlers = {
    [capabilities.refresh.ID] = {
      [capabilities.refresh.commands.refresh.NAME] = do_refresh
    },
  },
  lifecycle_handlers = {
--[[     init = device_init,
    added = added_handler,
    doConfigure = do_configure,
    infoChanged = info_changed,
    driverSwitched = driver_switched,
    removed = removed ]]
  }
}
--
--///////////////////////////////////////////////////////

return homeseer_floodlight_sensor
--
--/////////////////////////////////////////////////////////////////