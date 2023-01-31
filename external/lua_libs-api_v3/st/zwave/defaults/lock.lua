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
--- @type st.zwave.CommandClass
local cc = require "st.zwave.CommandClass"
--- @type st.zwave.CommandClass.Notification
local Notification = (require "st.zwave.CommandClass.Notification")({version=3})
local access_control_event = Notification.event.access_control
--- @type st.zwave.CommandClass.DoorLock
local DoorLock = (require "st.zwave.CommandClass.DoorLock")({version=1})
--- @type st.zwave.constants
local constants = require "st.zwave.constants"

local METHOD = {
  KEYPAD = "keypad",
  MANUAL = "manual",
  COMMAND = "command",
  AUTO = "auto"
}

--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.Notification.Report
local function notification_report_handler(driver, device, cmd)
  if (cmd.args.notification_type == Notification.notification_type.ACCESS_CONTROL) then
    local event
    local event_code = cmd.args.event
    if ((event_code >= access_control_event.MANUAL_LOCK_OPERATION and
          event_code <= access_control_event.KEYPAD_UNLOCK_OPERATION) or
            event_code == access_control_event.AUTO_LOCK_LOCKED_OPERATION) then
      -- even event codes are unlocks, odd event codes are locks
      local events = {[0] = capabilities.lock.lock.unlocked(), [1] = capabilities.lock.lock.locked()}
      event = events[event_code & 1]
    elseif (event_code >= access_control_event.MANUAL_NOT_FULLY_LOCKED_OPERATION and
            event_code <= access_control_event.LOCK_JAMMED) then
      event = capabilities.lock.lock.unknown()
    end

    if (event ~= nil) then
      local method_map = {
        [access_control_event.MANUAL_UNLOCK_OPERATION] = METHOD.MANUAL,
        [access_control_event.MANUAL_LOCK_OPERATION] = METHOD.MANUAL,
        [access_control_event.MANUAL_NOT_FULLY_LOCKED_OPERATION] = METHOD.MANUAL,
        [access_control_event.RF_LOCK_OPERATION] = METHOD.COMMAND,
        [access_control_event.RF_UNLOCK_OPERATION] = METHOD.COMMAND,
        [access_control_event.RF_NOT_FULLY_LOCKED_OPERATION] = METHOD.COMMAND,
        [access_control_event.KEYPAD_LOCK_OPERATION] = METHOD.KEYPAD,
        [access_control_event.KEYPAD_UNLOCK_OPERATION] = METHOD.KEYPAD,
        [access_control_event.AUTO_LOCK_LOCKED_OPERATION] = METHOD.AUTO,
        [access_control_event.AUTO_LOCK_NOT_FULLY_LOCKED_OPERATION] = METHOD.AUTO
      }

      event["data"] = {method = method_map[event_code]}

      -- SPECIAL CASES:
      if (event_code == access_control_event.MANUAL_UNLOCK_OPERATION and cmd.args.event_parameter == 2) then
        -- functionality from DTH, some locks can distinguish being manually locked via keypad
        event.data.method = METHOD.KEYPAD
      elseif (event_code == access_control_event.KEYPAD_LOCK_OPERATION or event_code == access_control_event.KEYPAD_UNLOCK_OPERATION) then
        if (device:supports_capability(capabilities.lockCodes)) then
          local lock_codes = device:get_field(constants.LOCK_CODES)
          local code_id = tostring(cmd.args.v1_alarm_level)
          if cmd.args.event_parameter ~= nil and string.len(cmd.args.event_parameter) ~= 0 then
            local event_params = {cmd.args.event_parameter:byte(1,-1)}
            code_id = (#event_params == 1) and tostring(event_params[1]) or tostring(event_params[3])
          end
          local code_name = lock_codes[code_id] == nil and lock_codes[code_id] or "Code " .. code_id
          event["data"] = { codeId = code_id, codeName = code_name, method = event["data"].method}
        end
      end
      device:emit_event(event)
    end
  end
end

--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.CommandClass.DoorLock.OperationReport
local function door_lock_operation_report_handler(driver, device, cmd)
  local event
  if (cmd.args.door_lock_mode == DoorLock.door_lock_mode.DOOR_SECURED) then
    event = capabilities.lock.lock.locked()
  elseif (cmd.args.door_lock_mode == DoorLock.door_lock_mode.DOOR_UNSECURED_WITH_TIMEOUT) then
    event = capabilities.lock.lock.unlocked_with_timeout()
  elseif (cmd.args.door_lock_mode == DoorLock.door_lock_mode.DOOR_LOCK_STATE_UNKNOWN) then
    event = capabilities.lock.lock.unknown()
  else
    -- fail to unlocked just to be safe
    event = capabilities.lock.lock.unlocked()
  end

  device:emit_event(event)
end

--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param command number
local function lock_and_check(driver, device, command)
  device:send(DoorLock:OperationSet({door_lock_mode = command}))

  local follow_up_poll = function()
    device:send(DoorLock:OperationGet({}))
  end

  driver:call_with_delay(4.2, follow_up_poll)
end

--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
local function unlock(driver, device)
  lock_and_check(driver, device, DoorLock.door_lock_mode.DOOR_UNSECURED)
end

--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
local function lock(driver, device)
  lock_and_check(driver, device, DoorLock.door_lock_mode.DOOR_SECURED)
end

--- @param self st.zwave.Driver
--- @param device st.zwave.Device
--- @param component string
--- @param endpoint integer
local function get_refresh_commands(driver, device, component, endpoint)
  if device:supports_capability_by_id(capabilities.lock.ID, component) and device:is_cc_supported(cc.DOOR_LOCK, endpoint) then
    return {DoorLock:OperationGet({}, {dst_channels = {endpoint}})}
  end
end

--- @class st.zwave.defaults.lock
--- @alias lock_defaults
--- @field public zwave_handlers table
--- @field public capability_handlers table
local lock_defaults = {
  zwave_handlers = {
    [cc.NOTIFICATION] = {
      [Notification.REPORT] = notification_report_handler
    },
    [cc.DOOR_LOCK] = {
      [DoorLock.OPERATION_REPORT] = door_lock_operation_report_handler
    }
  },
  capability_handlers = {
    [capabilities.lock.commands.unlock] = unlock,
    [capabilities.lock.commands.lock] = lock
  },
  get_refresh_commands = get_refresh_commands
}

return lock_defaults