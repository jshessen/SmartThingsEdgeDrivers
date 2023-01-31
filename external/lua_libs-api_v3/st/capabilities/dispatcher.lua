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
local MessageDispatcher = require "st.dispatcher"

local add_handlers_to_list = function(handler, list)
  local packed_handlers = {}
  if type(handler) == "function" then
    packed_handlers = { handler }
  elseif type(handler) == "table" then
    packed_handlers = handler
  end
  for _, h in ipairs(packed_handlers) do
    table.insert(list, h)
  end
end

--- @class CapabilityCommandDispatcher : MessageDispatcher
---
--- This inherits from the MessageDispatcher and is intended to handle capabiltiy commands
---
--- @field public name string A name of this level of dispatcher used for logging
--- @field public child_dispatchers CapabilityCommandDispatcher[] those below this handler in the hierarchy
--- @field public default_handlers table The `capability_handlers` structure from the Driver
--- @field public dispatcher_class_name string "CapabilityCommandDispatcher"
local CapabilityCommandDispatcher = {}

function CapabilityCommandDispatcher.init(cls, name, dispatcher_filter, default_handlers)
  return MessageDispatcher.init(cls, name, dispatcher_filter, default_handlers, "CapabilityCommandDispatcher")
end

--- Return a flat list of default handlers that can handle this capability command
---
--- These will be of the form of the `capability_handlers` on a driver  E.g.
--- `hander(driver, device, cap_command)`
---
--- @param driver Driver the driver context
--- @param device st.Device the device the message came from/is for
--- @param cap_command CapabilityCommand The capability command table
--- @return function[] a flat list of the default handlers that can handle this message
function CapabilityCommandDispatcher:find_default_handlers(driver, device, cap_command)
  local matching_handlers = {}
  for cap, commands in pairs(self.default_handlers) do
    if cap == cap_command.capability then
      for command, handler in pairs(commands) do
        if cap_command.command == command then
          add_handlers_to_list(handler, matching_handlers)
        end
      end
    end
  end
  return matching_handlers
end

--- Return a multiline string representation of the dispatchers default handlers
---
--- @param self CapabilityCommandDispatcher
--- @param indent number the indent level to allow for the hierarchy to be visually distinguishable
--- @return string the string representation
function CapabilityCommandDispatcher.pretty_print_default_handlers(self, indent)
  indent = indent or 0
  local indent_str = string.rep(" ", indent)
  local out = string.format("%sdefault_handlers:\n", indent_str)
  for cap, commands in pairs(self.default_handlers) do
    out = out .. string.format("%s  %s:\n", indent_str, cap)
    for command, _ in pairs(commands) do
      out = out .. string.format("%s    %s\n", indent_str, command)
    end
  end
  return out
end

setmetatable(CapabilityCommandDispatcher, {
  __index = MessageDispatcher,
  __call = CapabilityCommandDispatcher.init
})

return CapabilityCommandDispatcher
