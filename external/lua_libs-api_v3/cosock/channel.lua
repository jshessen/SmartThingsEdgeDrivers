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
local m = {}

-- TODO: move from channel.new() to channel() to match tcp/udp from socket
function m.new()
  local link = {
    queue = {},
    closed = false,
    waker = nil
  }
  return
    -- TODO: I'm unsure about closing on gc.
    setmetatable({link = link}, { __index = m.sender--[[, __gc = m.sender.close]] }),
    setmetatable({link = link}, { __index = m.receiver --[[, __gc = m.receiver.close]] })
end

m.receiver = {}

function m.receiver:close()
  self.link.closed = true
end

function m.receiver:receive()
  while true do
    if #self.link.queue > 0 then
      local event = table.remove(self.link.queue, 1)
      return event.msg
    elseif self.link.closed then
      return nil, "closed"
    else
      local _, _, err = coroutine.yield({self}, nil, self.timeout)
      if err then
        return nil, err
      end
      self.link.waker = nil
    end
  end
end

function m.receiver:settimeout(timeout)
  self.timeout = timeout
end

-- TODO: should this be some kind of generic interface?
function m.receiver:setwaker(kind, waker)
  assert(kind == "recvr", "unsupported wake kind: "..tostring(kind))
  assert(self.link.waker == nil or waker == nil,
         "waker already set, receive can't be waited on from multiple places at once")
  self.link.waker = waker

  -- if messages waiting, immediately wake
  if #self.link.queue > 0 and waker then waker() end
end

m.sender = {}

function m.sender:close()
  self.link.closed = true
  if self.link.waker then
    self.link.waker()
  end
end

function m.sender:send(msg)
  -- TODO: Allow setting an upper level on the queue size for backpressure
  if not self.link.closed then
    -- wapping in table allows `nil` to be sent as a message
    table.insert(self.link.queue, {msg = msg})
    if self.link.waker then
      self.link.waker()
    end
    return true
  else
    return false, "closed"
  end
end

return m
