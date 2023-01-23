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
--- @type MessageDispatcher
local MessageDispatcher = require "st.dispatcher"
local im = require "st.matter.interaction_model"
local clusters = require "st.matter.generated.zap_clusters"
local utils = require "st.utils"
local log = require "log"
local ResponseType = im.InteractionResponse.ResponseType
local Status = im.InteractionResponse.Status

local add_handlers_to_list = function(handler, list)
  if handler ~= nil then table.insert(list, handler) end
end

local InteractionResponseHandler = {}

function InteractionResponseHandler.init(cls, handler_class, handlers)
  local out = {}
  out.class = handler_class
  out.handlers = {}
  if type(handlers) == "function" then
    out.handlers = {handlers}
  elseif type(handlers) == "table" and (#handlers == 0 or type(handlers[1]) == "function") then
    out.handlers = handlers
  else
    error("Handler must be a function or list of functions", 2)
  end
  setmetatable(out, {__index = cls, __call = cls.__call, __tostring = cls.__tostring})
  return out
end

InteractionResponseHandler.__call = function(self, driver, device, rb, response)
  log.info(string.format("Executing %s", self))
  for _, handler in ipairs(self.handlers) do handler(driver, device, rb, response) end
end

InteractionResponseHandler.__tostring = function(self) return string.format("%s", self.class) end

setmetatable(InteractionResponseHandler, {__call = InteractionResponseHandler.init})

local AttributeReportHandler = {}

function AttributeReportHandler.init(cls, cluster_id, attribute_id, handlers)
  local cluster_tab = clusters.get_cluster_from_id(cluster_id)
  local cluster_name = string.format("0x%04X", cluster_id)
  if cluster_tab ~= nil then cluster_name = cluster_tab.NAME end

  local attr_tab = ((cluster_tab or {}).get_attribute_by_id or function(...) end)(
                     cluster_tab, attribute_id
                   )
  local attribute_name = string.format("0x%04X", attribute_id)
  if attr_tab ~= nil then attribute_name = attr_tab.NAME end
  local handler_list = {}
  if type(handlers) == "function" then
    handler_list = {handlers}
  elseif type(handlers) == "table" and (#handlers == 0 or type(handlers[1]) == "function") then
    handler_list = handlers
  else
    error("Handler must be a function or list of functions", 2)
  end

  local out = InteractionResponseHandler.init(cls, "AttributeReportHandler", handler_list)
  out.cluster_name = cluster_name
  out.attribute_name = attribute_name
  return out
end

AttributeReportHandler.__call = function(self, driver, device, ib, response)
  log.info(string.format("Executing %s", self))
  for _, handler in ipairs(self.handlers) do handler(driver, device, ib, response) end
end

AttributeReportHandler.__tostring = function(self)
  return string.format(
           "%s: cluster: %s, attribute: %s", self.class, self.cluster_name, self.attribute_name
         )
end

setmetatable(AttributeReportHandler, {__call = AttributeReportHandler.init})

local EventReportHandler = {}

function EventReportHandler.init(cls, cluster_id, event_id, handlers)
  local cluster_tab = clusters.get_cluster_from_id(cluster_id)
  local cluster_name = string.format("0x%04X", cluster_id)
  if cluster_tab ~= nil then cluster_name = cluster_tab.NAME end

  local event_tab =
    ((cluster_tab or {}).get_event_by_id or function(...) end)(cluster_tab, event_id)
  local event_name = string.format("0x%04X", event_id)
  if event_tab ~= nil then event_name = event_tab.NAME end
  local handler_list = {}
  if type(handlers) == "function" then
    handler_list = {handlers}
  elseif type(handlers) == "table" and (#handlers == 0 or type(handlers[1]) == "function") then
    handler_list = handlers
  else
    error("Handler must be a function or list of functions", 2)
  end

  local out = InteractionResponseHandler.init(cls, "EventReportHandler", handler_list)
  out.cluster_name = cluster_name
  out.event_name = event_name
  return out
end

EventReportHandler.__call = function(self, driver, device, ib, response)
  log.info(string.format("Executing %s", self))
  for _, handler in ipairs(self.handlers) do handler(driver, device, ib, response) end
end

EventReportHandler.__tostring = function(self)
  return string.format("%s: cluster: %s, event: %s", self.class, self.cluster_name, self.event_name)
end

setmetatable(EventReportHandler, {__call = EventReportHandler.init})

local CommandResponseHandler = {}

function CommandResponseHandler.init(cls, cluster_id, command_id, handlers)
  local cluster_tab = clusters.get_cluster_from_id(cluster_id)
  local cluster_name = string.format("0x%04X", cluster_id)
  if cluster_tab ~= nil then cluster_name = cluster_tab.NAME else cluster_tab = {} end

  local cmd_tab = (cluster_tab.get_client_command_by_id or function(...) end)(
                    cluster_tab, command_id
                  ) or (cluster_tab.get_server_command_by_id or function(...) end)(
                    cluster_tab, command_id
                  )
  local cmd_name = string.format("0x%04X", command_id)
  if cmd_tab ~= nil then cmd_name = cmd_tab.NAME end
  local handler_list = {}
  if type(handlers) == "function" then
    handler_list = {handlers}
  elseif type(handlers) == "table" and (#handlers == 0 or type(handlers[1]) == "function") then
    handler_list = handlers
  else
    error("Handler must be a function or list of functions", 2)
  end

  local out = InteractionResponseHandler.init(cls, "CommandResponseHandler", handler_list)
  out.cluster_name = cluster_name
  out.command_name = cmd_name
  return out
end

CommandResponseHandler.__call = function(self, driver, device, response_block, response)
  log.info(string.format("Executing %s", self))
  for _, handler in ipairs(self.handlers) do handler(driver, device, response_block, response) end
end

CommandResponseHandler.__tostring = function(self)
  return string.format(
           "%s: cluster: %s, command: %s", self.class, self.cluster_name, self.command_name
         )
end

setmetatable(
  CommandResponseHandler, {__call = CommandResponseHandler.init}
)

--- @class MatterMessageDispatcher : MessageDispatcher
---
--- This inherits from the MessageDispatcher and is intended to handle ReportData and CommandResponse
--- interaction responses
---
--- Write responses will not be dispatched into the driver. This is because they are essentially status
--- responses, and since they do not contain the original request in matter and there isn't a way to associate them with the
--- request, it would not be useful in the driver; instead the driver should issue a read after the write to confirm
--- the write took effect. This is a similar device interaction paradigm to what exists for Zigbee.
---
--- @field public name string A name of this level of dispatcher used for logging
--- @field public child_dispatchers MatterMessageDispatcher[] those below this handler in the hierarchy
--- @field public default_handlers table The `matter_handlers` structure from the MatterDriver
--- @field public dispatcher_class_name string "MatterMessageDispatcher"
local MatterMessageDispatcher = {}

function MatterMessageDispatcher.init(cls, name, dispatcher_filter, default_handlers)
  local new_dispatcher = MessageDispatcher.init(
                           cls, name, dispatcher_filter, default_handlers, "MatterMessageDispatcher"
                         )

  utils.merge(new_dispatcher.default_handlers, {attr = {}, cmd_response = {}, event = {}})

  setmetatable(
    new_dispatcher, {
      __index = MatterMessageDispatcher,
      __call = new_dispatcher.handle, -- TODO I think this is a remnant from the past
      __tostring = new_dispatcher.pretty_print,
    }
  )

  local new_attr = {}
  for cluster_id, attrs in pairs(new_dispatcher.default_handlers.attr) do
    new_attr[cluster_id] = {}
    for attr_id, handlers in pairs(attrs) do
      new_attr[cluster_id][attr_id] = AttributeReportHandler(cluster_id, attr_id, handlers)
    end
  end
  new_dispatcher.default_handlers.attr = new_attr

  local new_event = {}
  for cluster_id, evts in pairs(new_dispatcher.default_handlers.event) do
    new_event[cluster_id] = {}
    for event_id, handlers in pairs(evts) do
      new_event[cluster_id][event_id] = EventReportHandler(cluster_id, event_id, handlers)
    end
  end
  new_dispatcher.default_handlers.event = new_event

  local new_cmd_resp = {}
  for cluster_id, cmds in pairs(new_dispatcher.default_handlers.cmd_response) do
    new_cmd_resp[cluster_id] = {}
    for cmd_id, handlers in pairs(cmds) do
      new_cmd_resp[cluster_id][cmd_id] = CommandResponseHandler(cluster_id, cmd_id, handlers)
    end
  end
  new_dispatcher.default_handlers.cmd_response = new_cmd_resp

  return new_dispatcher
end

--- Return a flat list of default handlers that can handle the Info Block
---
--- These will be one of the message handlers defined on the driver or sub drivers.
--- All handlers have the same call signature: `handler(driver, device, response)`.
--- Note, the `attr` handlers will be wrapped to allow them to be called with this structure.
---
--- @param driver Driver the driver context
--- @param device st.Device the device the message came from/is for
--- @param rb st.matter.interaction_model.InteractionResponseInfoBlock the responses info block that is being dispatched.
--- @param response st.matter.interaction_model.InteractionResponse The received InteractionResponse to handle
--- @return function[] a flat list of the default handlers that can handle this message
function MatterMessageDispatcher:find_default_handlers(driver, device, rb, response)
  -- TODO maintain a cache of handlers for various paths to avoid tree traversal
  local matching_handlers = {}
  if rb ~= nil and response ~= nil then
    -- Find default attr handler
    if response.type == ResponseType.REPORT_DATA and rb.status == Status.SUCCESS
      and rb.info_block.data ~= nil
      and (self.default_handlers.attr[rb.info_block.cluster_id] or {})[rb.info_block.attribute_id]
      ~= nil then
      local attr_handler = self.default_handlers.attr[rb.info_block.cluster_id][rb.info_block
                             .attribute_id]
      local wrapped_attr_handler = function(dr, de, resp_block, resp)
        return attr_handler(dr, de, resp_block.info_block, response)
      end
      add_handlers_to_list(wrapped_attr_handler, matching_handlers)
    end

    -- Find default event handler
    if response.type == ResponseType.REPORT_DATA and rb.status == Status.SUCCESS
      and rb.info_block.data ~= nil
      and (self.default_handlers.event[rb.info_block.cluster_id] or {})[rb.info_block.event_id]
      ~= nil then
      local event_handler = self.default_handlers.event[rb.info_block.cluster_id][rb.info_block
                              .event_id]
      local wrapped_event_handler = function(dr, de, resp_block, resp)
        return event_handler(dr, de, resp_block.info_block, response)
      end
      add_handlers_to_list(wrapped_event_handler, matching_handlers)
    end

    -- Find default cmd_response handler
    if response.type == ResponseType.COMMAND_RESPONSE
      and (self.default_handlers.cmd_response[rb.info_block.cluster_id] or {})[rb.info_block
        .command_id] ~= nil then
      local cmd_handler = self.default_handlers.cmd_response[rb.info_block.cluster_id][rb.info_block
                            .command_id]
      local wrapped_cmd_handler = function(dr, de, resp_block, resp)
        return cmd_handler(dr, de, resp_block, response)
      end
      add_handlers_to_list(wrapped_cmd_handler, matching_handlers)
    end
  end
  return matching_handlers
end

--- Return a multiline string representation of the dispatchers default handlers
---
--- @param self MatterMessageDispatcher
--- @param indent number the indent level to allow for the hierarchy to be visually distinguishable
--- @return string the string representation
MatterMessageDispatcher.pretty_print_default_handlers = function(self, indent)
  indent = indent or 0
  local out = ""
  local indent_str = string.rep(" ", indent)
  out = out .. string.format("%sdefault_handlers:\n", indent_str)
  out = out .. string.format("%s  attr:\n", indent_str)
  for _cluster_id, attrs in pairs(self.default_handlers.attr) do
    for _attr_id, handler in pairs(attrs) do
      out = out .. string.format("%s    %s\n", indent_str, tostring(handler))
    end
  end
  out = out .. string.format("%s  event:\n", indent_str)
  for _cluster_id, evts in pairs(self.default_handlers.event) do
    for _event_id, handler in pairs(evts) do
      out = out .. string.format("%s    %s\n", indent_str, tostring(handler))
    end
  end
  out = out .. string.format("%s  cmd_response:\n", indent_str)
  for _cluster_id, cmds in pairs(self.default_handlers.cmd_response) do
    for _cmd_id, handler in pairs(cmds) do
      out = out .. string.format("%s    %s\n", indent_str, tostring(handler))
    end
  end
  return out
end

setmetatable(
  MatterMessageDispatcher, {__index = MessageDispatcher, __call = MatterMessageDispatcher.init}
)

return MatterMessageDispatcher
