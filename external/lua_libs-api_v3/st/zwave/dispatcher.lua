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
--- @type MessageDispatcher
local MessageDispatcher = require "st.dispatcher"
--- @type st.zwave
local zw = require "st.zwave"

--- @param handler function|table
--- @param list table
local add_handlers_to_list = function(handler, list)
  local packed_handlers = {}
  if type(handler) == "function" then
    packed_handlers = { handler }
  elseif type(handler) == "table" then
    packed_handlers = handler
  else
    error("unsupported Z-Wave handler type " .. type(handler))
  end
  for _, h in ipairs(packed_handlers) do
    table.insert(list, h)
  end
end

--- @class st.zwave.Dispatcher:MessageDispatcher
--- @alias ZwaveDispatcher st.zwave.Dispatcher
---
--- This inherits from the MessageDispatcher and handles Z-Wave commands.
---
--- @field public name string A logging string to describe this recursion level of the dispatcher
--- @field public child_dispatchers st.zwave.Dispatcher[] those below this recursion level in the hierarchy
--- @field public default_handlers table The `zwave_handlers` structure from the Driver
--- @field public dispatcher_class_name string "ZwaveDispatcher"
local ZwaveDispatcher = {}

function ZwaveDispatcher.init(cls, name, dispatcher_filter, default_handlers)
  return MessageDispatcher.init(cls, name, dispatcher_filter, default_handlers, "ZwaveDispatcher")
end

--- Return a flat list of default handlers that can handle this Z-Wave command.
---
--- Handlers' interfaces are of the form of those enclosed in the `zwave_handlers` table of the base driver, `function(driver, device, cmd)`.
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param cmd st.zwave.Command
--- @return function[] a flat list of the default callbacks that can handle this message
function ZwaveDispatcher:find_default_handlers(driver, device, cmd)
  local matching_handlers = {}
  if self.default_handlers[cmd.cmd_class] ~= nil then
    if self.default_handlers[cmd.cmd_class][cmd.cmd_id] ~= nil then
      local handlers = self.default_handlers[cmd.cmd_class][cmd.cmd_id]
      add_handlers_to_list(handlers, matching_handlers)
    end
  end
  return matching_handlers
end

--- Return a multiline string representation of the dispatcher's default handlers.
---
--- @param self st.zwave.Dispatcher
--- @param indent number the indent for visually distinguishable representation of the dispatcher hierarchy
--- @return string the string representation
function ZwaveDispatcher.pretty_print_default_handlers(self, indent)
  indent = indent or 0
  local indent_str = string.rep(" ", indent)
  local out = string.format("%sdefault_handlers:\n", indent_str)
  for cc, cmds in pairs(self.default_handlers) do
    out = out .. string.format("%s  %s:\n", indent_str, zw.cc_to_string(cc))
    for cmd, _ in pairs(cmds) do
      out = out .. string.format("%s    %s\n", indent_str, zw.cmd_to_string(cc, cmd))
    end
  end
  return out
end

setmetatable(ZwaveDispatcher, {
  __index = MessageDispatcher,
  __call = ZwaveDispatcher.init
})

return ZwaveDispatcher
