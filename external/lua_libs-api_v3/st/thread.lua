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
local cosock = require "cosock"
local socket = cosock.socket
local log = require "log"

--- @module st.thread
local thread_module = {}

local nop = function() end

--- @class Thread
--- A handle to a cooperatively scheduled thread that processes events sequentially.
---
--- A thread object provides an abstraction over the cosock coroutine executor allowing for two or more functions to
--- execute in a controlled manner. It also provides utility functions for creating timers (oneshot and periodic) that
--- run on the provided thread.
---
--- @field private driver Driver The driver context this thread will run under
--- @field private sender table A cosock sender channel half used to send events on the thread
--- @field private receiver table A cosock receiver channel half used to receive events on the thread
--- @field private timers table Contains a list of active timers owned by the thread
local Thread = {}
Thread.__index = Thread

--- @function Thread
--- Create a new ``Thread``
---
--- This class table also functions as an initialization function.
---
--- @param driver Driver the core driver this thread is running as a part of
--- @param name string the name of this thread
---
--- @return Thread The created thread object
Thread.init = function(cls, driver, name)
  local thread = {}
  thread.sender, thread.receiver = cosock.channel.new()
  thread.driver = driver
  thread.timers = {}
  thread.watched_sockets = {}

  cosock.spawn(
    function()
      while true do
        local recvt = {thread.receiver}
        for skt,_ in pairs(thread.watched_sockets) do table.insert(recvt, skt) end
        local recvr, _, err = socket.select(recvt, {})
        assert(not err)
        for _, skt in pairs(recvr) do
          if skt == thread.receiver then
            local event, err = thread.receiver:receive()

            if err then
              if err ~= "closed" then
                log.error_with({ hub_logs = true }, err)
              end
              break
            end

            assert(event, "no event, but no error")
            assert(type(event.callback) == "function", "thread callback was not a function")
            local status, err = pcall(event.callback, table.unpack(event.args))
            if not status then
              if driver._fail_on_error == true then
                error(err, 2)
              else
                -- TODO: in the case of an error (or maybe several) should we restart device or driver?
                log.error_with({ hub_logs = true }, string.format("%s thread encountered error: %s", name or driver.NAME, tostring(err)))
              end
            else
              log.debug_with({ hub_logs = true }, string.format("%s device thread event handled", name or driver.NAME))
            end

	    -- stop processing other sockets, event handler may have read/writen on sockets
	    break
          else
            local cfg = assert(thread.watched_sockets[skt], "select returned unwatched socket")

            -- TODO: Should this call with a device handle for device threads somehow?
            local status, err = pcall(cfg.callback, thread.driver, skt)
	    if not status then
              log.warn_with({ hub_logs = true }, string.format("%s handler on %s thread encountered error: %s",
	                             cfg.name or "unnamed",
				     name or "unnamed",
				     tostring(err)))
            end
          end
        end
      end
    end,
    name
  )

  setmetatable(thread, cls)
  return thread
end

--- @function Thread:queue_event
--- Queues an event to run on the thread
---
--- Queues an event in the form of a function and zero or more parameters to pass to that function. The event will be
--- run once any previously queued events have finished running.
---
--- @param callback function The function to be queued
--- @vararg any Zero or more parameters to be passed to the callback function when it is called
function Thread:queue_event(callback, ...)
  local args = {...}
  return self.sender:send({callback = callback, args = args})
end

--- @function Thread:close
--- Closes the thread to new events
---
--- Closes the thread to new events, including expiring timers, but does not clear events that have already been queued.
--- After all already queued events have been processed the thread exits.
function Thread:close()
  -- cancel all active timers
  for timer, _ in pairs(self.timers) do
    self:cancel_timer(timer)
  end

  self.sender:close()
  self.receiver:close()
end

--- @function Thread:call_with_delay
--- Creates a oneshot timer on this thread
---
--- Usage: ``thread:call_with_delay(5.0, my_timer_callback)``
---
--- @param delay_s number The number of seconds to wait before hitting the callback
--- @param callback function The function to call when the timer expires.
--- @param name string an optional name for the timer
--- @return table The created timer if successful, otherwise nil
function Thread:call_with_delay(delay_s, callback, name)
  if type(delay_s) ~= "number" then
    error("Timer delay must be a number", 2)
  end
  local timer = cosock.timer.create_oneshot(delay_s)
  if timer then
    local handler = function()
      self:queue_event(callback)
      timer:handled()
      self:unregister_socket(timer)
      self.timers[timer] = nil
    end
    local timer_name = name or string.format("%s unnamed %ss oneshot", self.label, delay_s)
    self:register_socket(timer, handler, timer_name)
    self.timers[timer] = true
    return timer
  else
    log.error_with({ hub_logs = true }, "Timer API failed to create timer")
    return nil
  end
end

--- @function Thread:call_on_schedule
--- Creates a periodic timer on this thread
---
--- Usage: ``thread:call_on_schedule(5.0, my_timer_callback)``
---
--- @param interval_s number The number of seconds to wait between hitting the callback
--- @param callback function The function to call when the timer expires.
--- @param name string an optional name for the timer
--- @return table The created timer if successful, otherwise nil
function Thread:call_on_schedule(interval_s, callback, name)
  if type(interval_s) ~= "number" then
    error("Timer interval must be a number", 2)
  end
  if interval_s > 0 then
    local timer = cosock.timer.create_interval(interval_s)
    if timer then
      local handler = function()
        self:queue_event(callback)
        timer:handled()
      end

      local timer_name = name or string.format("%s unnamed %ss interval", self.label, interval_s)
      self:register_socket(timer, handler, timer_name)
      self.timers[timer] = true
      return timer
    else
      log.error_with({ hub_logs = true }, "Timer API failed to create timer")
      return nil
    end
  else
    error("Call on schedule requires an interval greater than zero")
    return nil
  end
end

---
--- @function Thread:cancel_timer
--- Cancel a timer set up on this thread
---
--- Usage: ``thread:cancel_timer(my_timer)``
---
--- @param timer Timer The timer to cancel
function Thread:cancel_timer(timer)
  timer:cancel()
  self:unregister_socket(timer)
  self.timers[timer] = nil
end


--- Function to register a socket to be watched for read readiness
---
--- @param self Thread the thread to handle message events
--- @param socket socket the socket to watch
--- @param callback function the callback function to call when there is data to read on the socket
--- @param name string Optional name used for logging
function Thread:register_socket(socket, callback, name)
  self.watched_sockets[socket] = {
    callback = callback,
    name = (name or "unnamed")
  }

  -- wake thread in case this was called from another thread, new socket needs to be `select`ed
  self:queue_event(nop, {})
end


--- Function to unregister a socket currently being watched for read readiness
---
--- @param self Thread the thread on which the socket is currently registered
--- @param socket socket the socket to stop watching
function Thread:unregister_socket(socket)
  self.watched_sockets[socket] = nil
end

setmetatable(
  Thread,
  {
    __call = Thread.init
  }
)

thread_module.Thread = Thread

return thread_module
