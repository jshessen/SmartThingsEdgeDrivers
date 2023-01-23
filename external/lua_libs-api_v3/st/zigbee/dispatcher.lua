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
local log = require "log"
local zcl_commands = require "st.zigbee.zcl.global_commands"
local Status = require "st.zigbee.generated.types.ZclStatus"
local constants = require "st.zigbee.constants"
local utils = require "st.utils"
local MessageDispatcher = require "st.dispatcher"
local clusters = require "st.zigbee.zcl.clusters"
local global_commands = require "st.zigbee.zcl.global_commands"

local add_handlers_to_list = function(handler, list)
  if handler ~= nil then
    table.insert(list, handler)
  end
end

local ZigbeeMessageHandler = {}
ZigbeeMessageHandler.__index = ZigbeeMessageHandler

function ZigbeeMessageHandler.init(cls, handler_class, handlers)
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
  setmetatable(out, {
    __index = cls,
    __call = cls.__call,
    __tostring = cls.__tostring
  })
  return out
end

ZigbeeMessageHandler.__call = function(self, driver, device, zb_rx)
  log.info_with({ hub_logs = true }, string.format("Executing %s", self))
  for _, handler in ipairs(self.handlers) do
    handler(driver, device, zb_rx)
  end
end

ZigbeeMessageHandler.__tostring = function(self)
  return string.format("%s", self.class)
end

setmetatable(ZigbeeMessageHandler, {
  __call = ZigbeeMessageHandler.init
})

--local ZigbeeMessageAttributeHandler = {}
local ZigbeeMessageAttributeHandler = {}
ZigbeeMessageAttributeHandler.__index = ZigbeeMessageAttributeHandler
function ZigbeeMessageAttributeHandler.init(cls, cluster, attribute, handlers)
  local cluster_tab = clusters.get_cluster_from_id(cluster)
  local cluster_name = string.format("0x%04X", cluster)
  if cluster_tab ~= nil then
    cluster_name = cluster_tab.NAME
  end

  local attr_tab = ((cluster_tab or {}).get_attribute_by_id or function(...) end)(cluster_tab, attribute)
  local attribute_name = string.format("0x%04X", attribute)
  if attr_tab ~= nil then
    attribute_name = attr_tab.NAME
  end
  local handler_list = {}
  if type(handlers) == "function" then
    handler_list = {handlers}
  elseif type(handlers) == "table" and (#handlers == 0 or type(handlers[1]) == "function") then
    handler_list = handlers
  else
    error("Handler must be a function or list of functions", 2)
  end

  local out = ZigbeeMessageHandler.init(cls, "ZclClusterAttributeValueHandler", handler_list)
  out.cluster_name = cluster_name
  out.attribute_name = attribute_name
  return out
end

ZigbeeMessageAttributeHandler.__call = function(self, driver, device, value, zb_rx)
  log.info_with({ hub_logs = true }, string.format("Executing %s", self))
  for _, handler in ipairs(self.handlers) do
    handler(driver, device, value, zb_rx)
  end
end


ZigbeeMessageAttributeHandler.__tostring = function(self)
  return string.format("%s: cluster: %s, attribute: %s", self.class, self.cluster_name, self.attribute_name)
end

setmetatable(ZigbeeMessageAttributeHandler, {
  __index = ZigbeeMessageHandler,
  __call = ZigbeeMessageAttributeHandler.init
})

local ZigbeeMessageClusterCommandHandler = {}
ZigbeeMessageClusterCommandHandler.__index = ZigbeeMessageClusterCommandHandler
function ZigbeeMessageClusterCommandHandler.init(cls, cluster, command, handlers)
  local cluster_tab = clusters.get_cluster_from_id(cluster)
  local cluster_name = string.format("0x%04X", cluster)
  if cluster_tab ~= nil then
    cluster_name = cluster_tab.NAME
  end

  local command_tab = ((cluster_tab or {}).get_server_command_by_id or function(...) end)(cluster_tab, command)
  local command_name = string.format("0x%02X", command)
  if command_tab ~= nil then
    command_name = command_tab.NAME
  end
  local out = ZigbeeMessageHandler.init(cls, "ZclClusterCommandHandler", handlers)
  out.cluster_name = cluster_name
  out.command_name = command_name
  return out
end

ZigbeeMessageClusterCommandHandler.__tostring = function(self)
  return string.format("%s: cluster: %s, command: %s", self.class, self.cluster_name, self.command_name)
end

setmetatable(ZigbeeMessageClusterCommandHandler, {
  __index = ZigbeeMessageHandler,
  __call = ZigbeeMessageClusterCommandHandler.init
})

local ZigbeeMessageGlobalCommandHandler = {}
ZigbeeMessageGlobalCommandHandler.__index = ZigbeeMessageClusterCommandHandler
function ZigbeeMessageGlobalCommandHandler.init(cls, cluster, command, handlers)
  local cluster_tab = clusters.get_cluster_from_id(cluster)
  local cluster_name = string.format("0x%04X", cluster)
  if cluster_tab ~= nil then
    cluster_name = cluster_tab.NAME
  end

  local command_tab = global_commands.get_command_by_id(command)
  local command_name = string.format("0x%02X", command)
  if command_tab ~= nil then
    command_name = command_tab.NAME
  end
  local descriptor = string.format("cluster: %s, command: %s", cluster_name, command_name)
  local out = ZigbeeMessageHandler.init(cls, "ZclGlobalCommandHandler", handlers)
  out.cluster_name = cluster_name
  out.command_name = command_name
  return out
end

ZigbeeMessageGlobalCommandHandler.__tostring = function(self)
  return string.format("%s: cluster: %s, command: %s", self.class, self.cluster_name, self.command_name)
end

setmetatable(ZigbeeMessageGlobalCommandHandler, {
  __index = ZigbeeMessageHandler,
  __call = ZigbeeMessageGlobalCommandHandler.init
})

--- @class ZigbeeMessageDispatcher : MessageDispatcher
---
--- This inherits from the MessageDispatcher and is intended to handle ZigbeeMessageRx
--- messages
---
--- @field public name string A name of this level of dispatcher used for logging
--- @field public child_dispatchers ZigbeeMessageDispatcher[] those below this handler in the hierarchy
--- @field public default_handlers table The `handlers` structure from the ZigbeeDriver
--- @field public dispatcher_class_name string "ZigbeeMessageDispatcher"
local ZigbeeMessageDispatcher = {}

function ZigbeeMessageDispatcher.init(cls, name, dispatcher_filter, default_handlers)
  local new_dispatcher = MessageDispatcher.init(cls, name, dispatcher_filter, default_handlers, "ZigbeeMessageDispatcher")

  utils.merge(new_dispatcher.default_handlers, {
    attr = {},
    global = {},
    cluster = {},
    zdo = {}
  })

  setmetatable(new_dispatcher, {
    __index = ZigbeeMessageDispatcher,
    __call = new_dispatcher.handle,
    __tostring = new_dispatcher.pretty_print
  })

  local new_globals = {}
  for cluster, cmds in pairs(new_dispatcher.default_handlers.global) do
    new_globals[cluster] = {}
    for cmd, handlers in pairs(cmds) do
      new_globals[cluster][cmd] = ZigbeeMessageGlobalCommandHandler(cluster, cmd, handlers)
    end
  end
  new_dispatcher.default_handlers.global = new_globals

  local new_clusters = {}
  for cluster, cmds in pairs(new_dispatcher.default_handlers.cluster) do
    new_clusters[cluster] = {}
    for cmd, handlers in pairs(cmds) do
      new_clusters[cluster][cmd] = ZigbeeMessageClusterCommandHandler(cluster, cmd, handlers)
    end
  end
  new_dispatcher.default_handlers.cluster = new_clusters

  local new_zdos = {}
  for cluster, handlers in pairs(new_dispatcher.default_handlers.zdo) do
    new_zdos[cluster] = ZigbeeMessageHandler("ZdoHandler", handlers)
  end
  new_dispatcher.default_handlers.zdo = new_zdos

  local new_attr = {}
  for cluster, attrs in pairs(new_dispatcher.default_handlers.attr) do
    new_attr[cluster] = {}
    for attr_id, handlers in pairs(attrs) do
      new_attr[cluster][attr_id] = ZigbeeMessageAttributeHandler(cluster, attr_id, handlers)
    end
  end
  new_dispatcher.default_handlers.attr = new_attr

  return new_dispatcher
end

--- Return a flat list of default handlers that can handle the message
---
--- These will be one of the `attr`, `global`, `cluster`, or `zdo` message handlers defined
--- on the driver or sub drivers. However, the `attr` handlers will be wrapped to allow them
--- to be called with the same structure as the other handler types.  E.g.
--- `hander(driver, device, zb_rx)`
---
--- @param driver Driver the driver context
--- @param device st.Device the device the message came from/is for
--- @param zb_rx st.zigbee.ZigbeeMessageRx The received Zigbee message to handle
--- @return function[] a flat list of the default handlers that can handle this message
function ZigbeeMessageDispatcher:find_default_handlers(driver, device, zb_rx)
  local matching_handlers = {}
  if zb_rx ~= nil then
    if zb_rx.body.zcl_header ~= nil then
      local handler_set = zb_rx.body.zcl_header.frame_ctrl:is_cluster_specific_set() and "cluster" or "global"

      if handler_set ~= "cluster" and (zb_rx.body.zcl_header.cmd.value == zcl_commands.READ_ATTRIBUTE_RESPONSE_ID or zb_rx.body.zcl_header.cmd.value == zcl_commands.REPORT_ATTRIBUTE_ID) then
        -- Find default attr handler
        for _, v in ipairs(zb_rx.body.zcl_body.attr_records) do
          if (v.status == nil or v.status.value == Status.SUCCESS) and (self.default_handlers.attr[zb_rx.address_header.cluster.value] or {})[v.attr_id.value] ~= nil then
            local attr_handler = self.default_handlers.attr[zb_rx.address_header.cluster.value][v.attr_id.value]
            -- Bind the attribute handler to the specific attribute record.
            -- This is so that every attribute value is passed into a handler even in the case that there are multiple records of the same attribute.
            local bound_attr_handler = function(dr, de, zrx)
              return attr_handler(dr, de,  v.data, zrx)
            end
            add_handlers_to_list(bound_attr_handler, matching_handlers)
          end
        end
      end

      local handler_cluster = self.default_handlers[handler_set][zb_rx.address_header.cluster.value]
      add_handlers_to_list(handler_cluster ~= nil and handler_cluster[zb_rx.body.zcl_header.cmd.value] or nil, matching_handlers)
    elseif zb_rx.address_header.profile.value == constants.ZDO_PROFILE_ID then
      add_handlers_to_list(self.default_handlers.zdo[zb_rx.address_header.cluster.value], matching_handlers)
    end
  end
  return matching_handlers
end

--- Return a multiline string representation of the dispatchers default handlers
---
--- @param self ZigbeeMessageDispatcher
--- @param indent number the indent level to allow for the hierarchy to be visually distinguishable
--- @return string the string representation
ZigbeeMessageDispatcher.pretty_print_default_handlers = function (self, indent)
  indent = indent or 0
  local out = ""
  local indent_str = string.rep(" ", indent)
  out = out .. string.format("%sdefault_handlers:\n", indent_str)
  out = out .. string.format("%s  attr:\n", indent_str)
  for cluster, attrs in pairs(self.default_handlers.attr) do
    for attr, handler in pairs(attrs) do
      out = out .. string.format("%s    %s\n", indent_str, tostring(handler))
    end
  end
  out = out .. string.format("%s  global:\n", indent_str)
  for cluster, cmds in pairs(self.default_handlers.global) do
    for cmd, handler in pairs(cmds) do
      out = out .. string.format("%s    %s\n", indent_str, handler)
    end
  end
  out = out .. string.format("%s  cluster:\n", indent_str)
  for cluster, cmds in pairs(self.default_handlers.cluster) do
    for cmd, handler in pairs(cmds) do
      out = out .. string.format("%s    %s\n", indent_str, handler)
    end
  end
  out = out .. string.format("%s  zdo:\n", indent_str)
  for cluster, handler in pairs(self.default_handlers.zdo) do
    out = out .. string.format("%s    %s\n", indent_str, handler)
  end
  return out
end

setmetatable(ZigbeeMessageDispatcher, {
  __index = MessageDispatcher,
  __call = ZigbeeMessageDispatcher.init
})

return ZigbeeMessageDispatcher
