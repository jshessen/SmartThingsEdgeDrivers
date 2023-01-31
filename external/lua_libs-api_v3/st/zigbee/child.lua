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
local base_device = require "st.device"
--- @type st.zigbee.Device
local ZigbeeDevice = (require "st.zigbee.device").ZigbeeDevice

--- @module zigbee_child_device
local zigbee_child_device = {}

--- @class st.zigbee.ChildDevice : st.Device
local ZigbeeChildDevice = {}


--- For a child device this only returns the endpoint that this child is modelling.
---
--- This assumes a specific parent assigned child key pattern of <endpoint> be used and anything other than that
--- will require this function to be overridden, or manual address to be done for messages.
---
--- @param cluster number unused on child
--- @return number the endpoint extracted from the device DNI
function ZigbeeChildDevice:get_endpoint(cluster)
  return tonumber(self.parent_assigned_child_key, 16)
end

--- Return the manufacturer of the parent device
---
--- @return string The manufacturer of this device, nil if none present
function ZigbeeChildDevice:get_manufacturer()
  return self:get_parent_device():get_manufacturer()
end

--- Return the model fo the parent device
---
--- @return string The model of this device, nil if none present
function ZigbeeChildDevice:get_model()
  return self:get_parent_device():get_model()
end

--- Return the short address of the parent device
---
--- @return number The 2 byte Zigbee short address of this device
function ZigbeeChildDevice:get_short_address()
  return self:get_parent_device():get_short_address()
end

--- This is a noop on a child device, but is included to allow the children to be treated like a standard Zigbee device
---
--- @param attr_config_list st.zigbee.AttributeConfiguration[] the list of attribute
---  configurations to add
function ZigbeeChildDevice:add_attributes_from_driver_template(attr_config_list)
  return
end

--- This is a noop on a child device, but is included to allow the children to be treated like a standard Zigbee device
---
--- @param ias_zone_config_type IAS_ZONE_CONFIGURE_TYPE The type of configuration this device needs
function ZigbeeChildDevice:set_ias_zone_config_method(ias_zone_config_type)
  return
end

--- Check if this devices supports a specific cluster as a server
---
--- This just delegates to the parent of this child, so if an endpoint other than this devices endpoint the results
--- could be misleading.
---
--- @param cluster_id number the cluster ID to check for
--- @param endpoint_id number|nil the endpoint to check cluster support
--- @return boolean
function ZigbeeChildDevice:supports_server_cluster(cluster_id, endpoint_id)
  return self:get_parent_device():supports_server_cluster(cluster_id, endpoint_id)
end

--- This is a noop on a child device, but is included to allow the children to be treated like a standard Zigbee device
---
--- @param config st.zigbee.AttributeConfiguration the attribute configuration to add
function ZigbeeChildDevice:add_configured_attribute(config, opts)
  return
end

--- This is a noop on a child device, but is included to allow the children to be treated like a standard Zigbee device
---
--- @param config st.zigbee.AttributeConfiguration the attribute configuration to add
function ZigbeeChildDevice:add_monitored_attribute(config, opts)
  return
end

--- This is a noop on a child device, but is included to allow the children to be treated like a standard Zigbee device
---
function ZigbeeChildDevice:check_monitored_attributes()
  return
end

--- This is a noop on a child device, but is included to allow the children to be treated like a standard Zigbee device
---
--- @param zb_rx st.zigbee.ZigbeeMessageRx A received Zigbee message from this device
function ZigbeeChildDevice:attribute_monitor(zb_rx)
  return
end

--- This is a noop on a child device, but is included to allow the children to be treated like a standard Zigbee device
---
--- @param cluster number The id of the cluster of the attribute to remove
--- @param attribute number The id of the attribute to remove
function ZigbeeChildDevice:remove_monitored_attribute(cluster, attribute)
  return
end

--- This is a noop on a child device, but is included to allow the children to be treated like a standard Zigbee device
---
--- @param cluster number The id of the cluster of the attribute to remove
--- @param attribute number The id of the attribute to remove
function ZigbeeChildDevice:remove_configured_attribute(cluster, attribute)
  return
end

--- This is a noop on a child device, but is included to allow the children to be treated like a standard Zigbee device
---
function ZigbeeChildDevice:configure()
  return
end

ZigbeeChildDevice.set_component_to_endpoint_fn = ZigbeeDevice.set_component_to_endpoint_fn
ZigbeeChildDevice.set_endpoint_to_component_fn = ZigbeeDevice.set_endpoint_to_component_fn

--- Given the component ID find the corresponding endpoint for this device
---
--- This will use the function set by st.zigbee.Device:set_component_to_endpoint_fn to
--- return the appropriate endpoint given the component.  If the function is unset
--- it defaults to the value from `:get_endpoint` for the child which is derived from the DNI
--- of this device
---
--- @param comp_id string the component ID to find the endpoint for
--- @return number the endpoint this component matches to
function ZigbeeChildDevice:get_endpoint_for_component_id(comp_id)
  if self:get_field(ZigbeeDevice.COMPONENT_TO_ENDPOINT_FUNC) == nil then
    return self:get_endpoint()
  else
    return ZigbeeDevice.get_endpoint_for_component_id(self, comp_id)
  end
end

ZigbeeChildDevice.get_component_id_for_endpoint = ZigbeeDevice.get_component_id_for_endpoint
ZigbeeChildDevice.emit_event_for_endpoint = ZigbeeDevice.emit_event_for_endpoint


--- Calls refresh on the parent device
function ZigbeeChildDevice:refresh()
  self:get_parent_device():refresh(self:get_endpoint())
end

--- Send a ZigbeeMessageTx to this device (delegates to parent:send())
---
--- @param zb_tx st.zigbee.ZigbeeMessageTx the message to send to this device
function ZigbeeChildDevice:send(zb_tx)
  self:get_parent_device():send(zb_tx)
end

--- Send a ZigbeeMessageTx to this device and component
---
--- If no function is defined to handle multi component for this child, it will call send on the parent
--- with the message addressed to the endpoint returned from `:get_endpoint()` for this child
---
--- @param component_id string the component id to send this message to
--- @param zb_tx st.zigbee.ZigbeeMessageTx the message to send to this device
function ZigbeeChildDevice:send_to_component(component_id, zb_tx)
  local comp_to_ep_fn = self:get_field(COMPONENT_TO_ENDPOINT_FUNC)
  if comp_to_ep_fn ~= nil then
    self:get_parent_device():send(zb_tx:to_endpoint(comp_to_ep_fn(component_id)))
  else
    self:get_parent_device():send(zb_tx:to_endpoint(self:get_endpoint()))
  end
end

--- Initialize a child device
function ZigbeeChildDevice.init(cls, driver, raw_device)
  local out_device = base_device.Device.init(cls, driver, raw_device)
  out_device.zigbee_channel = driver.zigbee_channel
  base_device.Device._protect(cls, out_device)
  out_device:load_updated_data(raw_device)
  log.trace_with({ hub_logs = true }, out_device:debug_pretty_print())
  return out_device
end

--- Return a string representation of device model and supported cluster information
---
--- @return string A string containing the device model and supported cluster information
function ZigbeeChildDevice:debug_pretty_print()
  outputString = "Zigbee Child Device: " .. self.id .. "\n"
  outputString = outputString .. string.format("    ChildKey: %s\n", self.parent_assigned_child_key)
  outputString = outputString .. string.format("    ParentDeviceId: %s\n", self.parent_device_id)
  return outputString
end

ZigbeeChildDevice.CLASS_NAME = "ZigbeeChildDevice"

--- @function Device:pretty_print
--- Get a string with the ID and label of the device
---
--- @return string a short string representation of the device
function ZigbeeChildDevice:pretty_print()
  local label_str = ""
  if self.label ~= nil then
    label_str = string.format(" (%s)", self.label)
  end
  return string.format("<%s: %s [%s][%s]%s>", self.CLASS_NAME, self.id, self.parent_device_id, self.parent_assigned_child_key, label_str)
end

ZigbeeChildDevice.__tostring = ZigbeeChildDevice.pretty_print

zigbee_child_device.ZigbeeChildDevice = ZigbeeChildDevice

setmetatable(ZigbeeChildDevice, {
  __index = base_device.Device,
  __call = ZigbeeChildDevice.init
})

return zigbee_child_device
