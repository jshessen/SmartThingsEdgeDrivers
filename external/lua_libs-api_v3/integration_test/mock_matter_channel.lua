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
local it_utils = require "integration_test.utils"
local utils = require "st.utils"
local mock_generic_channel = require "integration_test.mock_generic_channel"
local MockMatterChannel = { }

function MockMatterChannel:__expect_send(message)
  local message_refactored = {
    message[1],
    message[2].type,
    message[2].info_blocks,
    message[2].timed
  }
  table.insert(self.__send_queue, message_refactored)
end

function MockMatterChannel:__convert_to_receive_return(return_msg)
  local info_blocks = {}
  -- flatten the wrapped info blocks
  for _, ib in pairs(return_msg[2].info_blocks) do
    if ib.info_block ~= nil then
      for key, value in pairs(ib.info_block) do
        ib[key] = value
      end
      ib.info_block = nil
    end
    table.insert(info_blocks, ib)
  end
  local message = { device_uuid = return_msg[1], info_blocks = info_blocks,  timed = timed}
  if return_msg[2].type ~= nil then message.response_type = return_msg[2].type end
  return {message}
end

function MockMatterChannel:__check_message_equality(expected, received)
  local im  = require "st.matter.interaction_model"
  local res = true
  res = res and (expected[1] == received[1]) --device id
  res = res and (expected[2] == received[2]) --interaction type
  res = res and (#expected[3] == #expected[3]) --same number of info blocks
  if not res then return res end

  -- each expected info block is present in the received message, order doesn't matter
  for _, ib_exp in ipairs(expected[3]) do
    local found = false
    for _, ib_rcv in ipairs(received[3]) do
      if im.InteractionInfoBlock.equals(ib_exp, ib_rcv) then
        found = true
        goto continue
      end
    end
    ::continue::
    res = res and found
  end
  return res
end

function MockMatterChannel:__print_unsent_messages()
  local im  = require "st.matter.interaction_model"
  for _, message in ipairs(self.__send_queue) do
    local unsent = im.InteractionRequest(message[2], message[3])
    print(string.format(
        "%s was not sent expected message:\n    %s",
        self.__name,
        unsent
    ))
  end
end

function MockMatterChannel:__error_messages_not_equal(expected, received)
  local im  = require "st.matter.interaction_model"
  local exp = im.InteractionRequest(expected[2], expected[3])
  local recv = im.InteractionRequest(received[2], received[3])
  local error_message = string.format(
      "%s message channel send was expecting:\n    %s\nbut received:\n    %s",
      self.__name,
      exp,
      recv
  )
  error({ code = it_utils.UNIT_TEST_FAILURE, msg = error_message, fatal = true })
end

function MockMatterChannel:__error_unexpected_message(received)
  local im  = require "st.matter.interaction_model"
  local recv = im.InteractionRequest(received[2], received[3])
  local error_message = string.format(
      "%s message channel send was given unexpected message:\n    %s",
      self.__name,
      recv
  )
  error({ code = it_utils.UNIT_TEST_FAILURE, msg = error_message, fatal = true })
end

setmetatable(MockMatterChannel, {
  __index = mock_generic_channel,
})

local my_mock = mock_generic_channel.init(MockMatterChannel, "matter")

return my_mock