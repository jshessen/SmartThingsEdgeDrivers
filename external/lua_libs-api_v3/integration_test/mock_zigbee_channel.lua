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
local zb_utils = require "st.zigbee.utils"
local mock_generic_channel = require "integration_test.mock_generic_channel"

local MockZigbeeChannel = {
  __expected_hub_group_adds = {},
  __expected_hub_group_adds_idx = 1
}

function MockZigbeeChannel:__error_messages_not_equal(expected, received)
  local error_message = string.format(
      "Zigbee message channel send was expecting:\n%s\nbut received:\n%s",
      expected[2]:pretty_print(zb_utils.MULTILINE_FORMAT_CONFIG, 1),
      received[2]:pretty_print(zb_utils.MULTILINE_FORMAT_CONFIG, 1)
  )
  error({ code = it_utils.UNIT_TEST_FAILURE, msg = error_message, fatal = true })
end

function MockZigbeeChannel:__error_unexpected_message(received)
  local error_message = string.format(
      "Zigbee message channel send was given unexpected message:\n%s",
      received[2]:pretty_print(zb_utils.MULTILINE_FORMAT_CONFIG, 1)
  )
  error({ code = it_utils.UNIT_TEST_FAILURE, msg = error_message, fatal = true })
end

function MockZigbeeChannel:__convert_to_receive_return(return_msg)
  return { return_msg[1], return_msg[2]:_serialize() }
end

function MockZigbeeChannel:__print_unsent_messages()
  for _, message in ipairs(self.__send_queue) do
    print(string.format(
        "%s was not sent expected message:\n    %s",
        self.__name,
        message[2]:pretty_print(zb_utils.MULTILINE_FORMAT_CONFIG, 1)
    ))
  end
  for _, group_id in ipairs(self.__expected_hub_group_adds) do
    print(string.format(
        "%s was expecting command to add hub to Zigbee group %d, but did not receive it",
        self.__name,
        group_id
    ))
  end
end

function MockZigbeeChannel:__expect_add_hub_to_group(group_id)
  self.__expected_hub_group_adds[#self.__expected_hub_group_adds + 1] = group_id
end

function MockZigbeeChannel:add_hub_to_group(group_id)
  if self.__expected_hub_group_adds[self.__expected_hub_group_adds_idx] ~= group_id then
    local err_msg = string.format("Driver attempted to add hub to group: %s, was expecting: %s", tostring(group_id), tostring(self.__expected_hub_group_adds[self.__expected_hub_group_adds_idx]))
    error({ code = it_utils.UNIT_TEST_FAILURE, msg = err_msg, fatal = true })
  else
    self.__expected_hub_group_adds_idx = self.__expected_hub_group_adds_idx + 1
  end
  return true
end

function MockZigbeeChannel:reset()
  self.__expected_hub_group_adds = {}
  self.__expected_hub_group_adds_idx = 1
  mock_generic_channel.reset(self)
end

function MockZigbeeChannel:__expecting_additional_send()
  return mock_generic_channel.__expecting_additional_send(self) or
      (self.__expected_hub_group_adds_idx == #self.__expected_hub_group_adds)
end

function MockZigbeeChannel:__check_message_equality(expected, received)
  return (expected[1] == received[1]) and (expected[2]:_serialize() == received[2]:_serialize())
end

setmetatable(MockZigbeeChannel, {
  __index = mock_generic_channel,
})

local my_mock = mock_generic_channel.init(MockZigbeeChannel, "zigbee")

return my_mock