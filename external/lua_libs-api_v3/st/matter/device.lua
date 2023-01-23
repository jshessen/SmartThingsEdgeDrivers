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
local log = require "log"
local utils = require "st.utils"
local base_device = require "st.device"
local im = require "st.matter.interaction_model"
local RequestType = im.InteractionRequest.RequestType
local zap_clusters = require "st.matter.generated.zap_clusters"
--- @module matter_device
local matter_device = {}
matter_device.MATTER_DEFAULT_ENDPOINT = 1
matter_device.COMPONENT_TO_ENDPOINT_FUNC = "__comp_to_ep_fn"
matter_device.ENDPOINT_TO_COMPONENT_FUNC = "__ep_to_comp_fn"

--- @class st.matter.Device : st.Device
local MatterDevice = {}
MatterDevice.CLASS_NAME = "MatterDevice"

local SUBSCRIBED_ATTRIBUTES_KEY = "__subscribed_attributes"
local SUBSCRIBED_EVENTS_KEY = "__subscribed_events"
-- TODO this constant should only be on the module, not the class
MatterDevice.MATTER_DEFAULT_ENDPOINT = 1

--- Get the endpoints on a device that support a particular cluster, atttribute, or command
---
--- @param cluster_id number the cluster ID to check for
--- @param opts table|nil valid options include feature_bitmap to check cluster feature support.
--- @return number[] list of endpoint ids that support the given server cluster
function MatterDevice:get_endpoints(cluster_id, opts)
  local opts = opts or {}
  if utils.table_size(opts) > 1 then error("Invalid options for MatterDevice:get_endpoints") end
  if opts.server_command_id or opts.client_command_id or opts.attribute_id then
    log.warn("Checking endpoints for individual cluster element support is no longer " ..
             "supported, use interactions instead. Checking cluster support only")
  end
  local clus_has_features = function(clus, feature_bitmap)
    if not feature_bitmap or not clus then return false end
    local lib_cluster = zap_clusters.get_cluster_from_id(clus.cluster_id)
    if lib_cluster then
      return lib_cluster.are_features_supported(feature_bitmap, clus.feature_map)
    end
    return false
  end
  local eps = {}
  for _, ep in ipairs(self.endpoints) do
    for _, clus in ipairs(ep.clusters) do
      if clus.cluster_id == cluster_id and (opts.feature_bitmap == nil or clus_has_features(clus, opts.feature_bitmap)) then
        table.insert(eps, ep.endpoint_id)
      end
    end
  end
  return eps
end

--- Check if this device endpoint supports a specific cluster
---
--- @param cluster_id number the cluster ID to check for
--- @param endpoint_id number|nil the endpoint to check cluster support (default to search all endpoints)
--- @return bool
function MatterDevice:supports_server_cluster(cluster_id, endpoint_id)
  -- helper to check a single endpoint for cluster support
  local ep_supports_server_cluster = function(ep)
    if not ep then return false end
    for _, clus in ipairs(ep.clusters) do
      if clus.cluster_id == cluster_id
        and (clus.cluster_type == "SERVER" or clus.cluster_type == "BOTH") then return true end
    end
    return false
  end

  local ep_idx
  if endpoint_id then
    for key, ep in ipairs(self.endpoints) do
      if ep.endpoint_id == endpoint_id then
        ep_idx = key
        break
      end
    end
    return ep_supports_server_cluster(self.endpoints[ep_idx])
  end

  for _, ep in pairs(self.endpoints) do if ep_supports_server_cluster(ep) then return true end end
  return false
end

---@alias CompToEp fun(type: st.matter.Device, type: string):number

--- Set a function to map this devices SmartThings components to Matter endpoints
---
--- @param comp_ep_fn CompToEp function to do the mapping for this device
function MatterDevice:set_component_to_endpoint_fn(comp_ep_fn)
  self:set_field(matter_device.COMPONENT_TO_ENDPOINT_FUNC, comp_ep_fn)
end

---@alias EpToComp fun(type: st.matter.Device, type: number):string

--- Set a function to map this devices Matter endpoints to SmartThings components
---
--- @param ep_comp_fn EpToComp function to do the mapping for this device
function MatterDevice:set_endpoint_to_component_fn(ep_comp_fn)
  self:set_field(matter_device.ENDPOINT_TO_COMPONENT_FUNC, ep_comp_fn)
end

--- Given the component ID find the corresponding endpoint for this device
---
--- This will use the function set by st.matter.Device:set_component_to_endpoint_fn to
--- return the appropriate endpoint given the component.  If the function is unset
--- it defaults to the MATTER_ROOT_ENDPOINT
---
--- @param comp_id string the component ID to find the endpoint for
--- @return number the endpoint this component matches to
function MatterDevice:component_to_endpoint(comp_id)
  local comp_to_ep = self:get_field(matter_device.COMPONENT_TO_ENDPOINT_FUNC)
  if comp_to_ep ~= nil then
    return comp_to_ep(self, comp_id)
  else
    return matter_device.MATTER_DEFAULT_ENDPOINT
  end
end

--- Given the endpoint ID find the corresponding component for this device
---
--- This will use the function set by st.matter.Device:set_endpoint_to_component_fn to
--- return the appropriate component given the endpoint.  If the function is unset
--- it defaults to "main"
---
--- @param ep number the endpoint ID to find the component for
--- @return string the component ID the endpoint matches to
function MatterDevice:endpoint_to_component(ep)
  local ep_to_comp = self:get_field(matter_device.ENDPOINT_TO_COMPONENT_FUNC)
  if ep_to_comp ~= nil then
    return ep_to_comp(self, ep)
  else
    return "main"
  end
end

--- Add a subscribed attribute for this device
---
--- This will not take effect until subscribe is called for the device
--- @param attr table Attribute object from the cluster library or a table containing `cluster` and `attribute` fields
function MatterDevice:add_subscribed_attribute(attr, opts)
  if type(attr) ~= "table" then
    log.error("Invalid attr argument, must be a table.")
    return
  end
  local cluster_id = attr.cluster or attr._cluster.ID
  local attr_id = attr.ID or attr.attribute
  local supporting_eps = self:get_endpoints(cluster_id, { attribute_id = nil })
  if #supporting_eps == 0 and not (opts or {}).force then
    log.warn_with({ hub_logs = true }, string.format("Device does not support cluster 0x%04X not adding subscribed attribute", cluster_id))
    return
  end
  -- Endpoint_id is always a wildcard
  local ib = im.InteractionInfoBlock(nil, cluster_id, attr_id)
  local subscribed_attrs = self:get_field(SUBSCRIBED_ATTRIBUTES_KEY) or {}
  subscribed_attrs[cluster_id] = subscribed_attrs[cluster_id] or {}
  subscribed_attrs[cluster_id][attr_id] = ib
  self:set_field(SUBSCRIBED_ATTRIBUTES_KEY, subscribed_attrs)
end

--- Add a subscribed event for this device
---
--- This will not take effect until subscribe is called for the device
--- @param attr table Event object from the cluster library or a table containing `cluster` and `event` fields
function MatterDevice:add_subscribed_event(event, opts)
  if type(event) ~= "table" then
    log.error("Invalid attr argument, must be a table.")
    return
  end
  local cluster_id = event.cluster or event._cluster.ID
  local event_id = event.ID or event.event
  local supporting_eps = self:get_endpoints(cluster_id, { event_id = nil })
  if #supporting_eps == 0 and not (opts or {}).force then
    log.warn_with({ hub_logs = true }, string.format("Device does not support cluster 0x%04X not adding subscribed event", cluster_id))
    return
  end
  -- Endpoint_id is always a wildcard
  local ib = im.InteractionInfoBlock(nil, cluster_id, nil, event_id)
  local subscribed_events = self:get_field(SUBSCRIBED_EVENTS_KEY) or {}
  subscribed_events[cluster_id] = subscribed_events[cluster_id] or {}
  subscribed_events[cluster_id][event_id] = ib
  self:set_field(SUBSCRIBED_EVENTS_KEY, subscribed_events)
end

--- Send request to the hub to subscribe to the device's `subscribed_attributes` and `subscribed_events` list
function MatterDevice:subscribe()
  local subscribed_attributes = self:get_field(SUBSCRIBED_ATTRIBUTES_KEY) or {}
  local subscribed_events = self:get_field(SUBSCRIBED_EVENTS_KEY) or {}
  local subscribe_request = im.InteractionRequest(im.InteractionRequest.RequestType.SUBSCRIBE, {})
  for _cluster_id, attributes in pairs(subscribed_attributes) do
    for _, ib in pairs(attributes) do
      subscribe_request:with_info_block(ib)
    end
  end
  for _cluster_id, events in pairs(subscribed_events) do
    for _, ib in pairs(events) do
      subscribe_request:with_info_block(ib)
    end
  end
  if #subscribe_request.info_blocks > 0 then
    self:send(subscribe_request)
  end
end

--- Send a read attribute request with `all subscribed attributes` on this device
--- Note that this does not read the `subscribed_events`
function MatterDevice:refresh()
  local subscribed_attributes = self:get_field(SUBSCRIBED_ATTRIBUTES_KEY) or {}
  local refresh_request = im.InteractionRequest(im.InteractionRequest.RequestType.READ, {})

  for _cluster_id, attributes in pairs(subscribed_attributes) do
    for i, ib in pairs(attributes) do
      refresh_request:with_info_block(ib)
    end
  end

  if #refresh_request.info_blocks > 0 then
    self:send(refresh_request)
  end
end

--- Emit a capability event for this device coming from the given endpoint
---
--- This uses st.matter.Device:endpoint_to_component to find the appropriate component
--- and emit the event for that component
---
--- @param endpoint number the endpoint ID a message was received from
--- @param event table the capability event to generate
function MatterDevice:emit_event_for_endpoint(endpoint, event)
  local find_child_fn = self:get_field(base_device.FIND_CHILD_KEY)
  if find_child_fn ~= nil then
    local child = find_child_fn(self, endpoint)
    if child ~= nil then
      child:emit_event(event)
      return
    end
  end
  local comp_id = self:endpoint_to_component(endpoint)
  local comp = self.profile.components[comp_id]
  self:emit_component_event(comp, event)
end

--- Send an InteractionRequest to this device
---
--- @param req st.matter.interaction_model.InteractionRequest the interaction request to send to this device
function MatterDevice:send(req)
  if type(req) == "table" and getmetatable(req) == im.InteractionRequest then
    log.info_with({hub_logs = true}, string.format("sending matter InteractionRequest: %s", req))
    local serialized = req:serialize()
    local _, err = self.matter_channel:send(self.id, serialized.type, serialized.info_blocks, serialized.timed)
    if err then
      log.warn_with({hub_logs = true}, string.format("Matter channel send error: %s", err))
    end
  else
    error(
      string.format("[%s] You can only send an InteractionRequest to a MatterDevice", self.id), 2
    )
  end
end

--- Populate the devices subscribed attributes from those available in the drivers defaults
local function populate_subscribed_attributes_from_driver_defaults(device, driver_attributes, driver_events)
  for cap_id, attributes in pairs(driver_attributes or {}) do
    if device:supports_capability_by_id(cap_id) then
      for _, attr in ipairs(attributes) do
        device:add_subscribed_attribute(attr)
      end
    end
  end
  for cap_id, events in pairs(driver_events or {}) do
    if device:supports_capability_by_id(cap_id) then
      for _, evnt in ipairs(events) do
        device:add_subscribed_event(evnt)
      end
    end
  end
end

function MatterDevice.init(cls, driver, raw_device)
    local out_device = base_device.Device.init(cls, driver, raw_device)
    out_device.matter_channel = driver.matter_channel
    base_device.Device._protect(cls, out_device)
    out_device:load_updated_data(raw_device)
    populate_subscribed_attributes_from_driver_defaults(out_device, driver.subscribed_attributes, driver.subscribed_events)
    return out_device
end

--- @return string string representation of the object
function MatterDevice:pretty_print()
  local label_str = ""
  if self.label ~= nil then label_str = string.format(" (%s)", self.label) end
  return string.format(
           "<%s: %s [%s]%s>", self.CLASS_NAME, self.id, self.device_network_id, label_str
         )
end

MatterDevice.__tostring = MatterDevice.pretty_print

matter_device.MatterDevice = MatterDevice

setmetatable(MatterDevice, {__index = base_device.Device, __call = MatterDevice.init})

return matter_device

