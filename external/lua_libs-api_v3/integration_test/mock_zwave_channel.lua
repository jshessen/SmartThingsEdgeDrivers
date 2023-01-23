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
local it_utils = require "integration_test.utils"
local mock_generic_channel = require "integration_test.mock_generic_channel"
local zw = require "st.zwave"

local MockZwaveChannel = {}

-- Z-Wave parameters are injected into the Z-Wave channel as a tuple of
-- positional arguments.  Indices are defined below.
local SEND_IDX_ID = 1 -- device UUID
local SEND_IDX_ENCAP = 2 -- security / integrity encapsulation
local SEND_IDX_CMD_CLASS = 3 -- command class
local SEND_IDX_CMD_ID = 4 -- command ID
local SEND_IDX_PAYLOAD = 5 -- opaque payload
local SEND_IDX_SCH = 6 -- source channel
local SEND_IDX_DCH = 7 -- destination channels

--- Raise an error describing that the observed Z-Wave command differs from the expected.
---
--- @param expected table the expected command
--- @param received table the received command
function MockZwaveChannel:__error_messages_not_equal(expected, received)
  local error_message = string.format(
      "Z-Wave send channel was expecting:\n    %s\nbut received:\n    %s",
      zw.Command(
        expected[SEND_IDX_CMD_CLASS],
	expected[SEND_IDX_CMD_ID],
	expected[SEND_IDX_PAYLOAD],
	{
	  encap=expected[SEND_IDX_ENCAP],
	  src_channel=expected[SEND_IDX_SCH],
	  dst_channels=expected[SEND_IDX_DCH]
	}
      ),
      zw.Command(
        received[SEND_IDX_CMD_CLASS],
        received[SEND_IDX_CMD_ID],
        received[SEND_IDX_PAYLOAD],
        {
          encap=received[SEND_IDX_ENCAP],
          src_channel=received[SEND_IDX_SCH],
          dst_channels=received[SEND_IDX_DCH]
	}
      )
  )
  error({ code = it_utils.UNIT_TEST_FAILURE, msg = error_message, fatal = true })
end

--- Raise an error describing that an unexpected Z-Wave command was observed.
---
--- @param received table the unexpected command
function MockZwaveChannel:__error_unexpected_message(received)
  local error_message = string.format(
      "Z-Wave send channel was given unexpected command:\n    %s",
      zw.Command(
        received[SEND_IDX_CMD_CLASS],
        received[SEND_IDX_CMD_ID],
        received[SEND_IDX_PAYLOAD],
        {
          encap=received[SEND_IDX_ENCAP],
          src_channel=received[SEND_IDX_SCH],
          dst_channels=received[SEND_IDX_DCH]
	}
      )
  )
  error({ code = it_utils.UNIT_TEST_FAILURE, msg = error_message, fatal = true })
end

--- Print any Z-Wave commands still in the send verification queue.  These will
--- will have been expected to be sent, but were not.
function MockZwaveChannel:__print_unsent_messages()
  for _, expected in ipairs(self.__send_queue) do
    print(string.format(
      "Z-Wave send channel was not given expected command:\n%s",
      zw.Command(
        expected[SEND_IDX_CMD_CLASS],
	expected[SEND_IDX_CMD_ID],
	expected[SEND_IDX_PAYLOAD],
	{
	  encap=expected[SEND_IDX_ENCAP],
	  src_channel=expected[SEND_IDX_SCH],
	  dst_channels=expected[SEND_IDX_DCH]
	}
      )
    ))
  end
end

function MockZwaveChannel:__convert_to_receive_return(return_msg)
  local ret_val = {
    -- the order shall match expected order at
    -- zw::zw_cmd_handler()
    -- and
    -- st_zwave_socket:receive():
    -- 1) uuid, 2) encap 3) src_channel 4) dst_channels
    -- 5) cmd_class 6) cmd_id 7) payload
    return_msg[1], --device_uuid
    return_msg[2].encap,
    return_msg[2].src_channel,
    return_msg[2].dst_channels,
    return_msg[2].cmd_class,
    return_msg[2].cmd_id,
    return_msg[2].payload
  }
  return ret_val
end

setmetatable(MockZwaveChannel, {
  __index = mock_generic_channel,
})

local my_mock = mock_generic_channel.init(MockZwaveChannel, "zwave")

return my_mock

