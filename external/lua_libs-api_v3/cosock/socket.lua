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
local luasocket = require "socket"

local tcp = assert(require "cosock.socket.tcp")
local udp = assert(require "cosock.socket.udp")

--- socket: a coroutine wrapped luasocket interface
---
--- The goal of socket is to provide as close to a pure luasocket interface as
--- possible which can be run within recursive coroutines.
---
--- (It's not 100% there yet.)
local m = {}

-- extraced from luasocket 3.0-rc1
m._VERSION = "socket 3.0-rc1"
m._SETSIZE = 1024
m.BLOCKSIZE = 2048

m.bind = function(host, port, backlog)
  local ret
  local skt, err = m.tcp()
  if not skt then return nil, err end

  ret, err = skt:bind(host, port)
  if not ret then return nil, err end

  ret, err = skt:listen(backlog)
  if not ret then return nil, err end

  -- I don't know why, but this is what the docs say
  ret, err = skt:setoption("reuseaddr", true)
  if not ret then return nil, err end

  return skt
end

m.choose = luasocket.choose

m.connect = function(address, port, locaddr, locport)
  local skt, createerr = m.tcp()
  if not skt then return nil, createerr end

  if locaddr then
    locport = locport or 0
    local status, err = skt:bind(locaddr, locport)
    if not status then return nil, err end
  end

  local status, err = skt:connect(address, port)
  if not status then return nil, err end

  return skt
end

m.connect4 = m.connect

m.connect6 = function(address, port, locaddr, locport)
  local skt, createerr = m.tcp6()
  if not skt then return nil, createerr end

  if locaddr then
    locport = locport or 0
    local status, err = skt:bind(locaddr, locport)
    if not status then return nil, err end
  end

  local status, err = skt:connect(address, port)
  if not status then return nil, err end

  return skt
end

-- these block the runtime, TODO: do something about that, somehow
m.dns = luasocket.dns

m.gettime = luasocket.gettime

m.newtry = luasocket.newtry

m.protect = luasocket.protect

m.select = function(recvt, sendt, timeout)
  return coroutine.yield(recvt, sendt, timeout)
end

m.sink = luasocket.sink

m.sinkt = luasocket.sinkt

m.skip = luasocket.skip

m.sleep = function(time)
  m.select(nil, nil, time)
end

m.source = luasocket.source

m.sourcet = luasocket.sourcet

m.tcp = tcp

m.tcp6 = function()
  local inner_sock, err = luasocket.tcp6()
  if not inner_sock then return inner_sock, err end
  inner_sock:settimeout(0)
  return setmetatable({inner_sock = inner_sock, class = "tcp{master}"}, { __index = tcp})
end

m.try = luasocket.try

m.udp = udp

m.udp6 = function()
  local inner_sock, err = luasocket.udp6()
  if not inner_sock then return inner_sock, err end
  inner_sock:settimeout(0)
  return setmetatable({inner_sock = inner_sock, class = "udp{unconnected}"}, { __index = udp})
end

-- ST custom sockets

m.environment_update = require "cosock.socket.environment_update"
m.device_lifecycle = require "cosock.socket.device_lifecycle"
m.driver_lifecycle = require "cosock.socket.driver_lifecycle"
m.capability = require "cosock.socket.capability"
m.discovery = require "cosock.socket.discovery"
m.zigbee = require "cosock.socket.zigbee"
m.zwave = require "cosock.socket.zwave"
m.matter = require "cosock.socket.matter"

return m
