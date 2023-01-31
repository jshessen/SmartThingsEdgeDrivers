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
local st_utils = require "st.utils"
local it_utils = require "integration_test.utils"

local GenericChannel = {}

function GenericChannel.init(cls, name)
  local out = {
    __name = name,
    __receive_queue = {},
    __send_queue = {},
    __ordering = "strict"
  }
  setmetatable(out, {
    __index = cls,
    __call = function(...) return out end
  })
  return out
end

--- Set "strict" or "relaxed" ordering
---
--- Under relaxed ordering, it will just check that each message "sent" over the channel
--- matches one of the expected messages in the queue.  With strict ordering (the default)
--- messages must be sent in the order they were added to the expected queue
---
--- @param ordering string "relaxed" or "strict"
function GenericChannel:__set_channel_ordering(ordering)
  self.__ordering = ordering
end

--- Add a message to the back of the expected send queue
---
--- Add a message to this channels expected send queue.  As the driver under test sends
--- messages over channels (e.g. socket.zigbee():send(...)) it will expect that message
--- to have been added as an expected message, if it is not, this is considered a failure
---
--- @param message table this is an arbitrary structure representing a message that is specific to the channel
function GenericChannel:__expect_send(message)
  table.insert(self.__send_queue, message)
end

--- Add a message to the back of the channel receive queue
---
--- Messages in this queue will be returned from the driver under tests :run loop select
--- call.  These will always be returned in the order they were queued regardless of the
--- ordering set.  There is no guaranteed order on messages between channels.
---
--- @param message table this is an arbitrary structure representing a message that is specific to the channel
function GenericChannel:__queue_receive(message)
  table.insert(self.__receive_queue, message)
end

--- Return true if this channel will return something with a receive call
---
--- @return boolean true if there is something in the receive queue
function GenericChannel:__receive_ready()
  return #self.__receive_queue > 0
end

--- Return true if there are still unsent expected messages in the send queue
---
--- @return boolean true if there is something in the expected send queue
function GenericChannel:__expecting_additional_send()
  return #self.__send_queue > 0
end

--- Reset this channel to clean state
---
--- This is meant to be used between tests to clean up any side effects of
--- a previous test
function GenericChannel:reset()
  self.__receive_queue = {}
  self.__send_queue = {}
  self.__ordering = "strict"
end

--- Check if the two messages are equal
---
--- This default implementation will just use `stringify_table` to compare the two
--- messages
---
--- @return boolean true if the messgaes are equal
function GenericChannel:__check_message_equality(expected, received)
  return st_utils.stringify_table(expected) == st_utils.stringify_table(received)
end

--- Print any messages still in the send queue
---
--- This is expected to be used when a test is finished running to show a
--- representation of all of the messages that weren't sent, that had been expected
function GenericChannel:__print_unsent_messages()
  for _, message in ipairs(self.__send_queue) do
    print(string.format(
        "%s was not sent expected message:\n%s",
        self.__name,
        st_utils.stringify_table(message)
    ))
  end
end

--- Raise an error with a message describing the two unequal messages
---
--- This will just use `stringify_table` to display a string representation of each
--- of the messages.
---
--- @param expected table the expected message
--- @param received table the received message
function GenericChannel:__error_messages_not_equal(expected, received)
  local error_message = string.format(
      "%s message channel send was expecting:\n    %s\nbut received:\n    %s",
      self.__name,
      st_utils.stringify_table(expected),
      st_utils.stringify_table(received)
  )
  error({ code = it_utils.UNIT_TEST_FAILURE, msg = error_message, fatal = true })
end

--- Raise an error with a message describing that an unexpected message was received
---
--- This is used to produce an error with a message when a message was sent to this channel
--- and there wasn't a specific expected message.
---
--- @param received table the unexpected message
function GenericChannel:__error_unexpected_message(received)
  local error_message = string.format(
      "%s message channel send was given unexpected message:\n    %s",
      self.__name,
      st_utils.stringify_table(received)
  )
  error({ code = it_utils.UNIT_TEST_FAILURE, msg = error_message, fatal = true })
end

--- Convert the value stored in the receive queue to the form needed for the actual receive
---
--- This is primarily useful to allow the `__receive_queue` to store the messages in a richer
--- format (ZigbeeMessageTx, lua table etc) and then convert it to the serialized version that
--- needs to be returned only when being returned.  The return value from this should be a single
--- table which will be `table.unpack`ed before being returned from receive to support multiple
--- return values
---
--- @param return_msg table the message as stored in the __receive_queue
--- @return table the table that will be unpacked to be returned from receive
function GenericChannel:__convert_to_receive_return(return_msg)
  return return_msg
end

--- The mocked send method for the channel, that will verify against the expected
---
--- This will take the args (i.e. "message") beint sent on the channel matches the
--- next (or any if ordering is relaxed) message in the __send_queue.  It will call
--- out to the other helper methods for testing equality and generating errors/messages
--- on failure cases.  This is to allow for this generic send function to be reused
--- across most of the mocks, and just control the equality testing and display in the
--- specific mock channels
---

function GenericChannel:send(...)
  local received_message = {...}
  if #self.__send_queue == 0 then
    self:__error_unexpected_message(received_message)
  end
  if self.__ordering == "strict" then
    local expected_without_callback = {}
    for k, v in pairs(self.__send_queue[1]) do
      if k ~= "callback" then
        expected_without_callback[k] = v
      end
    end
    if not self:__check_message_equality(expected_without_callback, received_message) then
      self:__error_messages_not_equal(expected_without_callback, received_message)
    else
      if self.__send_queue[1].callback ~= nil then
        self.__send_queue[1].callback()
      end
      table.remove(self.__send_queue, 1)
    end
  else
    local found = nil
    for i, message in ipairs(self.__send_queue) do
      local expected_without_callback = {}
      for k, v in pairs(message) do
        if k ~= "callback" then
          expected_without_callback[k] = v
        end
      end
      if self:__check_message_equality(expected_without_callback, received_message) then
        found = self.__send_queue[i]
        table.remove(self.__send_queue, i)
        break
      end
    end
    if not found then
      self:__error_unexpected_message(received_message)
    elseif found.callback ~= nil then
      found.callback()
    end
  end
end

--- The mocked receive method for the channel
---
--- This will return the next message in the `__receive_queue` or raise an error if there are none
function GenericChannel:receive()
  if #self.__receive_queue == 0 then
    error({code = it_utils.UNIT_TEST_FAILURE, msg = self.__name .. " message channel receive called with no message in the receive queue", fatal = true})
  else
    local return_msg = self.__receive_queue[1]
    if return_msg.callback ~= nil then
      return_msg.callback()
      return_msg.callback = nil
    end
    table.remove(self.__receive_queue, 1)
    return table.unpack(self:__convert_to_receive_return(return_msg))
  end
end

--- Set the timeout for blockable mocked functions
function GenericChannel:settimeout(timeout)
  self.timeout = timeout
end

setmetatable(GenericChannel, {
  __call = GenericChannel.init
})

return GenericChannel
