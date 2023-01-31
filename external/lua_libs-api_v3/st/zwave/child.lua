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
local capabilities = require "st.capabilities"
--- @type st.Device
local base_device = require "st.device"
--- @type st.zwave.Device
local ZwaveDevice = require "st.zwave.device".ZwaveDevice

--- @module zwave_child_device
local zwave_device = {}

--- @class st.zwave.ChildDevice : st.Device
--- @alias ZwaveChildDevice st.zwave.ChildDevice
local ZwaveChildDevice = {}


--- Get the dst_channels array used to address a message to this child through the parent
---
--- The default implementation here assumes that this device has a parent assigned child key of the child endpoint
---
--- @return table<number> the dst channels to address a message to this child device
function ZwaveChildDevice:get_dst_channel()
  return { tonumber(self.parent_assigned_child_key) }
end

ZwaveChildDevice.collect_default_refresh_commands = ZwaveDevice.collect_default_refresh_commands
ZwaveChildDevice.set_component_to_endpoint_fn = ZwaveDevice.set_component_to_endpoint_fn
ZwaveChildDevice.set_endpoint_to_component_fn = ZwaveDevice.set_endpoint_to_component_fn
ZwaveChildDevice.set_update_preferences_fn = ZwaveDevice.set_update_preferences_fn
ZwaveChildDevice.default_refresh = ZwaveDevice.default_refresh
ZwaveChildDevice.refresh = ZwaveDevice.refresh
ZwaveChildDevice.default_configure = ZwaveDevice.default_configure
ZwaveChildDevice.emit_event_for_endpoint = ZwaveDevice.emit_event_for_endpoint
ZwaveChildDevice.send_to_component = ZwaveDevice.send_to_component

--- Send a Z-Wave command to the associated Z-Wave device.
--- The command will be logged in the live logs when it is sent from the driver.
--- There will also be logs to trace when the command is queued in the hub,
--- and when the transmission has completed on the radio.
---
--- @param cmd st.zwave.Command
function ZwaveChildDevice:send(cmd)
  self:get_parent_device():send(cmd)
end

--- Map component to end_points(channels)
--- e.g.
--- {} - map component to un-encapsulated
--- {2} - map to specific Z-Wave endpoint(channel)
--- {1,2,3} - map to more then one Z-Wave endpoint (channels)
---
--- @param component_id string ID
--- @return table dst_channels destination channels
--- e.g. {2} for Z-Wave channel 2 or {} for unencapsulated
function ZwaveChildDevice:component_to_endpoint(component_id)
  local com_to_ep_fn = self:get_field(ZwaveDevice.COMPONENT_TO_ENDPOINT_FUNC)
  if com_to_ep_fn ~= nil then
    return ZwaveDevice.component_to_endpoint(self, component_id)
  else
    return self:get_dst_channel()
  end
end

ZwaveChildDevice.endpoint_to_component = ZwaveDevice.endpoint_to_component

--- Interrogate the device's profile to determine whether a particular command class is supported.
---
--- @param cc_value number the command class id as defined in cc.lua, e.g cc.SWITCH_BINARY = 0x25
--- @param endpoint number of the endpoint to check, if nil we check the first endpoint
--- @return boolean true if the command class is supported, false if not
function ZwaveChildDevice:is_cc_supported(cc_value, endpoint)
  return self:get_parent_device():is_cc_supported(cc_value, endpoint)
end

--- Determine whether device self is a match to the passed manufacturer ID(s),
--- product ID(s) and product type(s).  Filter arguments can be numerical
--- literals or arrays of numerical literals.
---
--- In the case that a filter argument is an array, matching uses OR logic.
--- Match against any single array item is considered a device match.
---
--- @param mfr_id number|table numerical manufacturer ID or array of IDs
--- @param product_type number|table numerical product type ( aka product in DTH namespace) or array of types.
--- @param product_id number|table numerical product ID ( aka model in DTH namespace) or array of IDs
--- @return boolean true if device self matches the passed all filter arguments
function ZwaveChildDevice:id_match(mfr_id, product_type, product_id)
  return self:get_parent_device():id_match(mfr_id, product_type, product_id)
end

--- Initialize an st.zwave.Device instance
---
--- @param cls st.zwave.Device st.zwave.Device class definition table
--- @param driver st.zwave.Driver
--- @param raw_device table cloud-published device instance data
function ZwaveChildDevice.init(cls, driver, raw_device)
  local out_device = base_device.Device.init(cls, driver, raw_device)
  base_device.Device._protect(cls, out_device)
  out_device:load_updated_data(raw_device)
  log.trace_with({ hub_logs = true }, out_device:debug_pretty_print())
  return out_device
end

--- Return a string representation of device model and supported command class information
---
--- @return string A string containing the device newtwork ID and the parent device ID of this child
function ZwaveChildDevice:debug_pretty_print()
  local outputString = "Z-Wave Child Device: " .. self.id .. "\n"
  outputString = outputString .. string.format("    ChildKey: %s\n", self.parent_assigned_child_key)
  outputString = outputString .. string.format("    ParentDeviceId: %s\n", self.parent_device_id)
  return outputString
end

ZwaveChildDevice.CLASS_NAME = "ZwaveChildDevice"

--- Get a string with the ID, DNI and label of the device.
---
--- @return string a short string representation of the device
function ZwaveChildDevice:pretty_print()
  local label_str = ""
  if self.label ~= nil then
    label_str = string.format(" (%s)", self.label)
  end
  return string.format("<%s: %s [%s][%s]%s>", self.CLASS_NAME, self.id, self.parent_device_id, self.parent_assigned_child_key, label_str)
end

ZwaveChildDevice.__tostring = ZwaveChildDevice.pretty_print

zwave_device.ZwaveChildDevice = ZwaveChildDevice

setmetatable(ZwaveChildDevice, {
  __index = base_device.Device,
  __call = ZwaveChildDevice.init
})

return zwave_device
