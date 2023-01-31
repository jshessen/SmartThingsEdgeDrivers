local cosock = require "cosock"
local Error = require "luxure.error"
local lunch_utils = require "luncheon.utils"
local log = require "log"

---@class Sse @
---
---Wrapper around the Request object for handeling
---Server Sent Event replies
---@field private tx cosock.channel
local Sse = {}

Sse.__index = Sse;

---@class Event
---
---A single Server Sent Event, this implements a builder pattern, so after calling `new`
---all other methods return the instance being updated.
---@field private _id string|nil
---@field private _comment string|nil
---@field private _data string|nil
---@field private _retry number|nil
local Event = {}
Event.__index = Event

---Constructor of an empty event
---@return Event
function Event.new() return setmetatable({}, Event) end

---Set the comment for this event
---@param comment string
---@return Event
function Event:comment(comment)
  self._comment = comment
  return self
end

---Set the event name for this event
---@param event string
---@return Event
function Event:event(event)
  self._event = event
  return self
end

---Set the id for this event
---@param id string|number
---@return Event
function Event:id(id)
  self._id = id
  return self
end

---Set the data for this event
---@param data string
---@return Event
function Event:data(data)
  self._data = data
  return self
end

---Set the retry for this event
---@param retry string|number
---@return Event
function Event:retry(retry)
  self._retry = retry
  return self
end

function format_part(name, data)
  if data == nil then return nil end
  return string.format("%s:%s", name, data)
end

---Serialize this event into the sse format
---@return any
function Event:to_string()
  local ret = {}
  table.insert(ret, format_part("", self._comment))
  table.insert(ret, format_part("event", self._event))
  if self._data ~= nil then
    for line in string.gmatch(self._data, "[^\n]+") do
      table.insert(ret, string.format("data:%s", line))
    end
  end
  table.insert(ret, format_part("id", self._id))
  table.insert(ret, format_part("retry", self._retry))
  table.insert(ret, "\n") -- 2 new lines at the end
  return table.concat(ret, "\n")
end

local function tick(rx, res, timeout)
  local succ, ready, err
  local readt = {rx, res.socket}
  ready, _, err = cosock.socket.select(readt, nil, timeout)
  if err then
    if err == "timeout" then
      local event = Event.new():comment("")
      succ, err = Error.pcall(lunch_utils.send_all, res.socket,
                              event:to_string())
      if not succ then return nil, err end
    else
      -- client disconnect or other IO error, exits loop and close socket
      return nil, "disconnect"
    end
  elseif (ready or {})[1] == res.socket then
    res.socket:receive()
    return nil, "recv" -- received from socket
  else
    local event = rx:receive()
    succ, err = Error.pcall(lunch_utils.send_all, res.socket, event:to_string())
    if not succ then return nil, err end
  end
  return 1
end

---Wrap a Response in a new server sent event handle. This will spawn
---a cosock task that will manage the keepalive messages along with any
---the sending of any intentional events or data
---
---if `keepalive` is a number it will be used to determine the wait between events
---otherwise if truthy, it will default to set to 15 seconds
---
---Note: This requires that the server is configured with the `async` property
---set to `true`
---@param res Response The response to wrap
---@param keepalive boolean|integer if a number the maximum number of seconds to wait between events to send an empty comment
---@return Sse @A handle to the server sent event task
function Sse.new(res, keepalive)
  res:add_header("Content-Type", "text/event-stream")
  res:add_header("Cache-Control", "no-cache")
  res.headers._inner.content_length = nil
  res.hold_open = true;
  Error.assert(res:send_preamble())
  Error.assert(res:send_header())
  Error.assert(res:send_header())
  Error.assert(res:send_header())
  local tx, rx = cosock.channel.new()
  cosock.spawn(function()
    local timeout = nil
    if type(keepalive) == "number" then
      timeout = keepalive
    elseif keepalive then
      timeout = 15
    end
    while true do
      local succ, err = tick(rx, res, timeout)
      if not succ then
        log.error("error in sse tick", err)
        break
      end
    end
    res.socket:close()
    rx:close()
  end)
  return setmetatable({tx = tx}, Sse)
end

---Send an event
---@param ev Event
---@return integer|nil
---@return string
function Sse:send(ev) return self.tx:send(ev) end

return {Sse = Sse, Event = Event}
