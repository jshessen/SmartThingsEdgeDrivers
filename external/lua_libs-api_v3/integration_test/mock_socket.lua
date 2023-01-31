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
local GenericChannel = require "integration_test.mock_generic_channel"
require "integration_test.mock_os_time"

local socket = {
  __sock_cache = {},
  __time_advance = 0,
  _socket_close_queue = {}
}

local mock_noop_func = function(...) end

local func_mocks = {
  choose = mock_noop_func,
  dns = mock_noop_func,
  gettime = mock_noop_func,
  newtry = mock_noop_func,
  protect = mock_noop_func,
  sink = mock_noop_func,
  sinkt = mock_noop_func,
  skip = mock_noop_func,
  source = mock_noop_func,
  sourcet = mock_noop_func,
  try = mock_noop_func,
  udp6 = mock_noop_func,
  tcp6 = mock_noop_func,
}

--- Add a specific mock socket that will be returned on the usage of `socket.key_name()`
---
--- @param key string the name of the socket
--- @param mock_sock table the mock socket to use
function socket:add_mock_socket(key, mock_sock)
  self.__sock_cache[key] = mock_sock
end

--- Automatically advance time when a receive message is processed
---
--- For the mock global socket, set the mocked global time to
--- automatically advance by the given amount of time
--- @param time_advance number the amount to move time forward per select (in seconds)
function socket:set_time_advance_per_select(time_advance)
  self.__time_advance = time_advance
end

local function get_ready_socket(socket_list)
  for _, sock in pairs(socket_list) do
    if (sock.__receive_ready or function(...) return false end)(sock) then
      return { sock }
    end
  end
end

function socket.select(recvt, sendt, timeout)
  assert(sendt == nil or #sendt == 0, "test framework doesn't support select on send readiness")
  os.__advance_time(socket.__time_advance)
  -- If there are any messages ready to receive return those first
  local ready_sock = get_ready_socket(recvt)
  if ready_sock ~= nil then
    return ready_sock, {}
  end

  if timeout then
    assert(type(timeout) == "number", "non numeric timeout")
    os.__advance_time(timeout)
    return {}, {}, "timeout"
  end

  -- If there is a manifest, execute blocks until there is a channel with
  -- a receive ready
  local co = rawget(socket, "__co")
  if co ~= nil then
    local more = true
    local mess
    while get_ready_socket(recvt) == nil and more do
      more, mess = coroutine.resume(co)
    end
    if not more and mess ~= "cannot resume dead coroutine" then
      error(mess, 2)
    end
    ready_sock = get_ready_socket(recvt)
    if ready_sock ~= nil then
      return ready_sock, {}
    end
  end

  -- if all manifest messages have been processed and there are no sockets still
  -- ready to receive, the test is over.
  error({code = it_utils.END_OF_TESTS, msg = "end of tests", fatal = true})
end

function socket.gettime()
  return os.time()
end

function socket:__prepare_coroutine_test(co)
  self.__co = co
end

function socket:__reset()
  self.__co = nil
end

function socket:__set_valid_channels(channel_list)
  self.__valid_channels = channel_list
end

setmetatable(socket, {
  __index = function(self, key)
    local raw = rawget(self, key)
    if raw ~= nil then
      return raw
    elseif func_mocks[key] ~= nil then
      return func_mocks[key]
    elseif self.__sock_cache[key] ~= nil then
      return self.__sock_cache[key]
    else
      if self.__valid_channels[key] then
        self.__sock_cache[key] = GenericChannel(key)
        return self.__sock_cache[key]
      else
        -- Don't need to use test failure error format as this error comes outside the test pcall wrapper
        error(string.format("Invalid channel used for test: \"%s\"", key))
      end
    end
  end
})

return socket
