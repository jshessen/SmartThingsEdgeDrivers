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
local zcl_clusters = require "st.zigbee.zcl.clusters"
local capabilities = require "st.capabilities"

--- @class st.zigbee.defaults.lock
--- @field public zigbee_handlers table
--- @field public attribute_configurations table
--- @field public capability_handlers table
local lock_defaults = {}


--- Default handler for lock OperatingEventNotification cluster command
---
--- This will look at the event_source, event_value, and user_id to generate a lock.lock event with the appropriate
--- value and data.
---
--- @param driver ZigbeeDriver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param zb_rx st.zigbee.ZigbeeMessageRx the full message this report came in
function lock_defaults.lock_operation_event_handler(driver, device, zb_rx)
  local event_code = zb_rx.body.zcl_body.operation_event_code.value
  local source = zb_rx.body.zcl_body.operation_event_source.value
  local OperationEventCode = require "st.zigbee.generated.zcl_clusters.DoorLock.types.OperationEventCode"
  local METHOD = {
    [0] = "keypad",
    [1] = "command",
    [2] = "manual",
    [3] = "rfid",
    [4] = "fingerprint",
    [5] = "bluetooth"
  }
  local STATUS = {
    [OperationEventCode.LOCK]           = capabilities.lock.lock.locked(),
    [OperationEventCode.UNLOCK]         = capabilities.lock.lock.unlocked(),
    [OperationEventCode.ONE_TOUCH_LOCK] = capabilities.lock.lock.locked(),
    [OperationEventCode.KEY_LOCK]       = capabilities.lock.lock.locked(),
    [OperationEventCode.KEY_UNLOCK]     = capabilities.lock.lock.unlocked(),
    [OperationEventCode.AUTO_LOCK]      = capabilities.lock.lock.locked(),
    [OperationEventCode.MANUAL_LOCK]    = capabilities.lock.lock.locked(),
    [OperationEventCode.MANUAL_UNLOCK]  = capabilities.lock.lock.unlocked()
  }
  local event = STATUS[event_code]
  if (event ~= nil) then
    event["data"] = {}
    if (event_code == OperationEventCode.AUTO_LOCK) then
      event.data.method = "auto"
    else
      event.data.method = METHOD[source]
    end
    if (source == 0) then
      local code_id = zb_rx.body.zcl_body.user_id.value
      local code_name = "Code "..code_id
      local lock_codes = device:get_field("lockCodes")
      if (lock_codes ~= nil and
          lock_codes[code_id] ~= nil) then
        code_name = lock_codes[code_id]
      end
      event.data = {method = METHOD[0], codeId = code_id .. "", codeName = code_name}
    end
    device:emit_event_for_endpoint(zb_rx.address_header.src_endpoint.value, event)
  end
end

--- Default handler for lock state attribute on the door lock cluster
---
--- This converts the lock state value to the appropriate value
---
--- @param driver Driver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param value LockState the value of the door lock cluster lock state attribute
--- @param zb_rx st.zigbee.ZigbeeMessageRx the full message this report came in
function lock_defaults.lock_state_handler(driver, device, value, zb_rx)
  local attr = capabilities.lock.lock
  local LOCK_STATE = {
    [value.NOT_FULLY_LOCKED]     = attr.unknown(),
    [value.LOCKED]               = attr.locked(),
    [value.UNLOCKED]             = attr.unlocked()
  }
  device:emit_event_for_endpoint(zb_rx.address_header.src_endpoint.value, LOCK_STATE[value.value])
end

--- Default handler for the Lock.lock command
---
--- This will send the lock command to the door lock cluster
---
--- @param driver Driver The current driver running containing necessary context for execution
--- @param device st.Device The device this message was received from containing identifying information
--- @param command table The capability command table
function lock_defaults.lock(driver, device, command)
  device:send_to_component(command.component, zcl_clusters.DoorLock.server.commands.LockDoor(device))
end

--- Default handler for the Lock.unlock command
---
--- This will send the unlock command to the door lock cluster
---
--- @param driver Driver The current driver running containing necessary context for execution
--- @param device st.Device The device this message was received from containing identifying information
--- @param command table The capability command table
function lock_defaults.unlock(driver, device, command)
  device:send_to_component(command.component, zcl_clusters.DoorLock.server.commands.UnlockDoor(device))
end


lock_defaults.zigbee_handlers = {
  global = {},
  cluster = {
    [zcl_clusters.DoorLock] = {
      [zcl_clusters.DoorLock.client.commands.OperatingEventNotification] = lock_defaults.lock_operation_event_handler
    }
  },
  attr = {
    [zcl_clusters.DoorLock] = {
      [zcl_clusters.DoorLock.attributes.LockState] = lock_defaults.lock_state_handler
    }
  }
}
lock_defaults.capability_handlers = {
  [capabilities.lock.commands.lock.NAME] = lock_defaults.lock,
  [capabilities.lock.commands.unlock.NAME] = lock_defaults.unlock,
}

return lock_defaults