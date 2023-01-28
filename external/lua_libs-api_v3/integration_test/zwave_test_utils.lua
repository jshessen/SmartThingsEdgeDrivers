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
local zwave_test_utils = {}
--- mocks Z-Wave command sent by driver (driver-to-mesh)
---
--- @param device ZwaveDevice Z-Wave device instance
--- @param command zw.Command Z-Wave command
--- e.g. binary switch SET ON command:
---  {
---    args={duration=1, target_value=255},
---    cmd_class="SWITCH_BINARY",
---    cmd_id="SET",
---    payload="\xFF\x01",
---    version=2,
---    encap=0,
---    src_channel=0,
---    dst_chanels={2}
---  }
---
--- @return table list of Z-Wave command positional parameters as are passed to
--- runner/src/envlib/socket.lua st_zwave_socket:send.
---
---  e.g for mock_device and binary switch SET ON command shall return:
---  {"00000000-1111-2222-3333-000000000001", 0, 37, 1, "\xFF\x01", 0, {2}}
---  where
---  00000000-1111-2222-3333-000000000001   -- mock device ID
---  0                                      -- AUTO encapsulation
---  cmd_class=0x25                         -- COMMAND_CLASS_SWITCH_BINARY
---  cmd_id=0x01,                           -- SWITCH_BINARY_SET
---  payload="\xFF\x01",                    -- ON_ENABLE and duration=1
---  src_channel=0,                         -- implicit root endpoint 0
---  dst_channels={2}                       -- destination endpoint 2
function zwave_test_utils.zwave_test_build_send_command(device, command)
    return {
        device.id,
        command.encap,
        command.cmd_class,
        command.cmd_id,
        command.payload,
        command.src_channel,
        command.dst_channels
    }
end

--- mocks Z-Wave command received by driver (mesh-to-driver)
---
--- @param command Z-Wave command e.g. for binary switch report ON:
--- {
---    args={current_value=255, duration=0, target_value=0},
---    cmd_class="SWITCH_BINARY",
---    cmd_id="REPORT",
---    payload="\xFF",
---    version=2,
---    ...
--- }
---
--- @return zw.Command - currently a transparent pass-through
function zwave_test_utils.zwave_test_build_receive_command(command)
    return command
end

return zwave_test_utils

