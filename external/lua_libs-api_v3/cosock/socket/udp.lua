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
local lsocket = require "socket"
local internals = require "cosock.socket.internals"

local m = {}

local recvmethods = {
  receive = { timeout = true },
  receivefrom = { timeout = true },
}

local sendmethods = {
  send = { timeout = true },
  sendto = { timeout = true },
}

setmetatable(m, { __call = function()
  local inner_sock, err = lsocket.udp()
  if not inner_sock then return inner_sock, err end
  inner_sock:settimeout(0)
  return setmetatable({ inner_sock = inner_sock, class = "udp{unconnected}" }, { __index = m })
end })

local passthrough = internals.passthroughbuilder(recvmethods, sendmethods)

m.close = passthrough("close")

m.dirty = passthrough("dirty")

m.getfamily = passthrough("getfamily")

m.getfd = passthrough("getfd")

m.getoption = passthrough("getoption")

m.getpeername = passthrough("getpeername")

m.getsockname = passthrough("getsockname")

m.receive = passthrough("receive")

m.receivefrom = passthrough("receivefrom")

m.send = passthrough("send")

m.sendto = passthrough("sendto")

m.setfd = passthrough("setfd")

m.setoption = passthrough("setoption")

m.setpeername = passthrough("setpeername")

m.setsockname = passthrough("setsockname")

function m:settimeout(timeout)
  self.timeout = timeout

  return 1.0
end

internals.setuprealsocketwaker(m)


return m
