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
local lsocket = require "socket"
local internals = require "cosock.socket.internals"

local m = {}

local recvmethods = {
  receive = { timeout = true },
}

local sendmethods = {}

setmetatable(m, {__call = function()
  local inner_sock, err = lsocket.driver_lifecycle()
  if not inner_sock then return inner_sock, err end
  inner_sock:settimeout(0)
  return setmetatable({inner_sock = inner_sock, class = "driver_lifecycle{}"}, { __index = m})
end})

local passthrough = internals.passthroughbuilder(recvmethods, sendmethods)

m.receive = passthrough("receive")

function m:settimeout(timeout)
  self.timeout = timeout
end

internals.setuprealsocketwaker(m)

return m
