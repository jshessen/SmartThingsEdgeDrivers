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
local base_device = require "st.device"
local im = require "st.matter.interaction_model"
local MatterDevice = require "st.matter.device".MatterDevice
--- @module matter_child_device
local matter_child_device = {}
matter_child_device.MATTER_DEFAULT_ENDPOINT = 1

--- @class st.matter.ChildDevice : st.Device
local MatterChildDevice = {}
MatterChildDevice.CLASS_NAME = "MatterChildDevice"
MatterChildDevice.MATTER_DEFAULT_ENDPOINT = 1


function MatterChildDevice:get_endpoint()
  -- Default functionality
  return tonumber(self.parent_assigned_child_key)
end

--- Get the endpoints on a device that support a particular cluster, atttribute, or command
---
--- Because the default implementation of children is that a child represents a single endpoint, this will only ever
--- return a single endpoint representing this device if the cluster is supported
---
--- @param cluster_id number the cluster ID to check for
--- @param opts table|nil valid options include a server_command_id, client_command_id, attribute_id, or feature_bitmap to search (only one).
--- @return number[] list of endpoint ids that support the given server cluster
function MatterChildDevice:get_endpoints(cluster_id, opts)
  local eps = self:get_parent_device():get_endpoints(cluster_id, opts)
  local self_ep self:get_endpoint()
  for _, ep in ipairs(eps) do
    if ep == self_ep then
      return {ep}
    end
  end
  return {}
end

--- Check if this device endpoint supports a specific cluster
---
--- @param cluster_id number the cluster ID to check for
--- @param endpoint_id number|nil the endpoint to check cluster support (default to search all endpoints)
--- @return bool
function MatterChildDevice:supports_server_cluster(cluster_id, endpoint_id)
  return self:get_endpoint() == endpoint_id and self:get_parent_device():supports_server_cluster(cluster_id, endpoint_id)
end

MatterChildDevice.set_component_to_endpoint_fn = MatterDevice.set_component_to_endpoint_fn
MatterChildDevice.set_endpoint_to_component_fn = MatterDevice.set_endpoint_to_component_fn
MatterChildDevice.get_component_id_for_endpoint = MatterDevice.get_component_id_for_endpoint
MatterChildDevice.emit_event_for_endpoint = MatterDevice.emit_event_for_endpoint

--- Given the component ID find the corresponding endpoint for this device
---
--- This will use the function set by st.matter.Device:set_component_to_endpoint_fn to
--- return the appropriate endpoint given the component.  If the function is unset
--- it defaults to the MATTER_ROOT_ENDPOINT
---
--- @param comp_id string the component ID to find the endpoint for
--- @return number the endpoint this component matches to
function MatterChildDevice:component_to_endpoint(comp_id)
  if self:get_field(MatterDevice.COMPONENT_TO_ENDPOINT_FUNC) == nil then
    return self:get_endpoint()
  else
    return MatterDevice.component_to_endpoint(self, comp_id)
  end
end

--- Add a subscribed attribute for this device
---
--- This will not take effect until subscribe is called for the device
--- @param attr table Attribute object from the cluster library or a table containing `cluster` and `attribute` fields
function MatterChildDevice:add_subscribed_attribute(attr, opts)
  return
end

--- Send request to the hub to subscribe to the device's `subscribed_attributes` list
function MatterChildDevice:subscribe()
  self:get_parent_device():subscribe()
end

MatterChildDevice.configure = MatterDevice.configure
MatterChildDevice.refresh = MatterDevice.refresh

--- Send an InteractionRequest to this device
---
--- @param req st.matter.interaction_model.InteractionRequest the interaction request to send to this device
function MatterChildDevice:send(req)
  self:get_parent_device():send(req)
end

function MatterChildDevice.init(cls, driver, raw_device)
    local out_device = base_device.Device.init(cls, driver, raw_device)
    out_device.matter_channel = driver.matter_channel
    base_device.Device._protect(cls, out_device)
    out_device:load_updated_data(raw_device)
    return out_device
end

function MatterChildDevice:debug_pretty_print()
  outputString = "Matter Child Device: " .. self.id .. "\n"
  outputString = outputString .. string.format("    ChildKey: %s\n", self.parent_assigned_child_key)
  outputString = outputString .. string.format("    ParentDeviceId: %s\n", self.parent_device_id)
  return outputString
end

function MatterChildDevice:pretty_print()
  local label_str = ""
  if self.label ~= nil then label_str = string.format(" (%s)", self.label) end
  return string.format(
           "<%s: %s [%s]%s>", self.CLASS_NAME, self.id, self.device_network_id, label_str
         )
end

MatterChildDevice.__tostring = MatterChildDevice.pretty_print

matter_child_device.MatterChildDevice = MatterChildDevice

setmetatable(MatterChildDevice, {__index = base_device.Device, __call = MatterChildDevice.init})

return matter_child_device

