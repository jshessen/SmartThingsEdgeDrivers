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
local utils = require "st.utils"
local log = require "log"

--- @class MessageDispatcher
---
--- The MessageDispatcher class can be used to construct a hierarchical structure for handling
--- a message of some sort.  Message dispatchers contain sets of `default_handlers` with
--- implmentation-specific structure.  Each MessageDispatcher can contain any number of
--- `child_dispatchers`, which are themselves MessageDispatchers.  Each message dispatcher must
--- implement a `can_handle` method which will recurse to return true if the dispatcher or one of
--- its children can handle the message.  The class also has a `dispatch` function that will find
--- handlers for the message.  If a child dispatcher says it can handle it, it will be forwarded
--- there.  If multiple children at a given recursion level report they can handle a message, all
--- children will receive the message.  If no child reports it can handle a message, it will be
--- sent to a default handler at the current level, if any exists.
---
--- @field public name string A logging string to describe this recursion level of the dispatcher
--- @field public child_dispatchers MessageDispatcher[] those below this message dispatcher in the hierarchy
--- @field public default_handlers table implementation-specific structure containing the default handlers
--- @field public dispatcher_class_name string The dispatcher type
--- @field public error_handler fun(driver, device, vararg) A function that will be called if any of the matching handlers raises an error during execution
--- @field public fallback_handler fun(driver, device, vararg) A function that will be called if no matching handler is found when dispatch is called
local MessageDispatcher = {}

--- Initialize a MessageDispatcher.
---
--- @param cls MessageDispatcher the class we are initing (probably a child class)
--- @param name string the name of this dispatcher
--- @param dispatcher_filter function a can_handle function for this MessageDispatcher (in addition to normal child/default matching)
--- @param default_handlers table implementation specific structure of default handlers
--- @param dispatcher_class_name string the class name for logging purposes
function MessageDispatcher.init(cls, name, dispatcher_filter, default_handlers, dispatcher_class_name)
  if type(dispatcher_filter) ~= "function" then
    error("filter function must be a function")
  end
  local filter = dispatcher_filter
  local handlers = default_handlers
  if name == nil then
    error("Must give a dispatcher a name")
  end
  dispatcher_class_name = dispatcher_class_name or "Generic"
  if handlers == nil and filter == nil then
    log.info_with({ hub_logs = true },
        string.format(
            "Created dispatcher [%s]%s that had no handlers or filter.  Defaulting as a passthrough.",
            dispatcher_class_name,
            name
        )
    )
    handlers = {}
    filter = function(...) return true end
  elseif handlers ~= nil and filter == nil then
    error("Cannot have a dispatcher set with default handlers, but no filter")
  elseif filter ~= nil and handlers == nil then
    log.info_with({ hub_logs = true },
        string.format(
            "Created dispatcher [%s]%s that had no handlers",
            dispatcher_class_name,
            name
        )
    )
    handlers = {}
  end

  local new_dispatcher = {
    name = name,
    child_dispatchers = {},
    dispatcher_filter = filter,
    dispatcher_class_name = dispatcher_class_name,
  }

  new_dispatcher.default_handlers = utils.deep_copy(handlers)

  if handlers.error ~= nil and type(handlers.error) ~= "function" then
    log.warn_with({ hub_logs = true },
        string.format(
            "Specified error handler must be a function (received %s) and will not be called.",
            type(handlers.error)
        )
    )
  else
    new_dispatcher.error_handler = handlers.error
  end

  if handlers.fallback ~= nil and type(handlers.fallback) ~= "function" then
    log.warn_with({ hub_logs = true },
        string.format(
            "Specified fallback handler must be a function (received %s) and will not be called.",
            type(handlers.fallback)
        )
    )
  else
    new_dispatcher.fallback_handler = handlers.fallback
  end

  -- remove the error and fallback handlers from the defaults as they follow a different structure
  new_dispatcher.default_handlers.error = nil
  new_dispatcher.default_handlers.fallback = nil
  setmetatable(new_dispatcher, {
    __index = cls,
    __call = new_dispatcher.handle,
    __tostring = cls.pretty_print
  })

  return new_dispatcher
end

--- Add a child to this dispatcher.
---
---@param dispatcher MessageDispatcher the child dispatcher to add
function MessageDispatcher:register_child_dispatcher(dispatcher)
  dispatcher.parent = self
  table.insert(self.child_dispatchers, dispatcher)
end

--- Return a flat list of default handlers that can handle the message.
---
--- This is virtual on this base class, and must be implemented by inheritors.
---
--- @param driver Driver the driver context
--- @param device st.Device the device the message came from/is for
--- @vararg table MessageDispatcher child implementation specific args
--- @return function[] a flat list of the default handlers that can handle this message
function MessageDispatcher:find_default_handlers(driver, device, ...)
  error("MessageDispatcher requires implementation specific find_default_handlers")
end

--- Return a flat list of all the child dispatchers whose can_handle returned true for this message.
---
--- @param driver Driver the driver context
--- @param device st.Device the device the message came from/is for
--- @vararg table MessageDispatcher child implementation specific args
--- @return MessageDispatcher[] the flat list of child dispatchers that can handle this message
function MessageDispatcher:find_child_dispatchers(driver, device, ...)
  local matching_dispatchers = {}
  for _, dispatcher in ipairs(self.child_dispatchers) do
    if dispatcher:can_handle(driver, device, ...) then
      table.insert(matching_dispatchers, dispatcher)
    end
  end
  return matching_dispatchers
end

--- Return true if this MessageDispatcher can handle the message.
---
--- A message can be handled if either
--- A) a child dispatcher reports it can handle the message or
--- B) self.dispatcher_filter returns true and a default handler will work for this message
---
--- @param driver Driver the driver context
--- @param device st.Device the device the message came from/is for
--- @vararg table MessageDispatcher child implementation specific args
--- @return boolean true if the the message can be handled by this dispatcher, false if it cannot
function MessageDispatcher:can_handle(driver, device, ...)
  local status, val = pcall(self.dispatcher_filter, {dispatcher_class = self.dispatcher_class_name}, driver, device, ...)
  if not status then
    log.warn(string.format("Encountered error calling can_handle for dispatcher defaulting to false: %s", val))
  end
  return (
      status and val and
          (
              (#self:find_child_dispatchers(driver, device, ...) > 0) or
                  (#self:find_default_handlers(driver, device, ...) > 0)
          )
  )
end

--- Return a string showing the hierarchy through which the dispatcher recursed to arrive at this level.
---
--- This provides useful trace.
---
--- @return string something of the form "root -> parent -> me" using the name of each dispatcher
function MessageDispatcher:get_dispatcher_path()
  if self.parent == nil then
    return self.name
  end

  return self.parent:get_dispatcher_path() .. " -> " .. self.name
end

local function inner_dispatch(self, driver, device, ...)
  local dispatchers = self:find_child_dispatchers(driver, device, ...)
  if #dispatchers > 0 then
    for _, dispatcher in ipairs(dispatchers) do
      dispatcher:dispatch(driver, device, ...)
    end
  else
    for _, command_handler in ipairs(self:find_default_handlers(driver, device, ...) or {}) do
      log.trace_with({ hub_logs = true }, "Found " .. self.dispatcher_class_name .. " handler in " .. self:get_dispatcher_path())
      command_handler(driver, device, ...)
    end
  end
end

--- Find a handler for this message and execute it.
---
--- This will either execute child dispatchers or default handlers, but never both.  It will,
--- however, execute any number of handlers of the given class that match.
---
--- @param driver Driver the driver context
--- @param device st.Device the device the message came from/is for
--- @vararg table MessageDispatcher child implementation specific args
function MessageDispatcher:dispatch(driver, device, ...)
  if self:can_handle(driver, device, ...) then
    local status, value = pcall(inner_dispatch, self, driver, device, ...)
    if not status then
      if self.error_handler ~= nil then
        self.error_handler(driver, device, ...)
      else
        local args = {...}
        local error_msg = string.format(
            "Error encountered while processing event for %s:\n",
            tostring(device)
        )
        for i, arg in ipairs(args) do
          local arg_str = string.format("    arg%d: %s\n", i, tostring(arg))
          error_msg = error_msg .. arg_str
        end
        error_msg  = error_msg .. value
        error(error_msg)
      end
    end
  elseif self.fallback_handler ~= nil then
    self.fallback_handler(driver, device, ...)
  end
end


--- Return a multiline string representation of the dispatcher structure.
---
--- @param indent number the indent for visually distinguishable representation of the dispatcher hierarchy
--- @return string the string representation
function MessageDispatcher:pretty_print(indent)
  indent = indent or 0
  local indent_str = string.rep(" ", indent)
  local out = string.format("%s%s: %s\n", indent_str, self.dispatcher_class_name, self:get_dispatcher_path())
  out = out .. self:pretty_print_default_handlers(indent + 2)
  out = out .. string.format("%s  child_dispatchers:\n", indent_str)
  for i, disp in ipairs(self.child_dispatchers) do
    out = out .. disp:pretty_print(indent + 4)
  end
  return out
end

--- Return a multiline string representation of the dispatcher's default handlers.
---
--- This is virtual on this base class, and must be implemented by inheritors.
---
--- @param indent number the indent for visually distinguishable representation of the dispatcher hierarchy
--- @return string the string representation
function MessageDispatcher:pretty_print_default_handlers(indent)
  error("MessageDispatcher requires implementation specific pretty_print_default_handlers")
end


setmetatable(MessageDispatcher, {
  __call = MessageDispatcher.init
})

return MessageDispatcher
