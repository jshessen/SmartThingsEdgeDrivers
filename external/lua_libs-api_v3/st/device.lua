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
local thread = require "st.thread"
local capabilities = require "st.capabilities"
local base64 = require "st.base64"
local json = require "st.json"
local devices_api = _envlibrequire("devices")
local utils = require "st.utils"

--- @module device
local device_module = {}

local STATE_CACHE_KEY = "__state_cache"
local PARENT_KEY = "__parent_device"

device_module.NETWORK_TYPE_ZIGBEE = "DEVICE_ZIGBEE"
device_module.NETWORK_TYPE_ZWAVE = "DEVICE_ZWAVE"
device_module.NETWORK_TYPE_MATTER = "DEVICE_MATTER"
device_module.NETWORK_TYPE_CHILD = "DEVICE_EDGE_CHILD"
device_module.FIND_CHILD_KEY = "__find_child_fn"

local function convert_st_store_to_readonly(value)
    if type(value) ~= "table" then
        return value
    end
    local mt = {}
    mt.__values = {}
    mt.__newindex = function(self, key, value)
        error("st_store is for readonly SmartThings info only. Use set_field to add a value to the device.")
    end
    mt.__index = function(self, key)
        return mt.__values[key]
    end
    mt.__pairs = function(self)
        return pairs(mt.__values)
    end

    for k,v in pairs(value) do
        mt.__values[k] = convert_st_store_to_readonly(v)
    end
    local out = {}
    setmetatable(out, mt)
    return out
end

local function convert_and_set_st_store(device, raw_st_store)
    if raw_st_store.zigbee_eui then
        raw_st_store.zigbee_eui = base64.decode(raw_st_store.zigbee_eui)
    end

    -- Build a more natural component structure
    for comp_id, component in pairs(raw_st_store.profile.components) do
        component.emit_event = function(self, capability_event)
            device:emit_component_event(component, capability_event)
        end
    end

    local device_mt = getmetatable(device)

    if raw_st_store.profile.components.main ~= nil then
        device_mt.__values["emit_event"] = raw_st_store.profile.components.main.emit_event
    else
        device_mt.__values["emit_event"] = function(...)
            local err_msg = string.format("Device %s does not have \"main\" component, use component specific event generation", device.id)
            log.warn_with({ hub_logs = true }, err_msg)
            return false, err_msg
        end
    end

    local new_st_store = convert_st_store_to_readonly(raw_st_store)
    device_mt.__values["st_store"] = new_st_store
end

-- Device definition
--- @class st.Device
---
--- A device object contains all of the information we have about a given device that is set to be managed by this
--- driver.  It also provides a number of utility functions that make normal operations for dealing with devices
--- simpler.
---
--- @field public transient_store table Used to store driver specific data about a device that will not persist through driver restart.
--- @field public persistent_store table Used to store driver specific data about a device that will be persisted through restart.  The actual flash writes are on a schedule so some data loss is possible if the hub experiences a power loss
--- @field public st_store table Contains the SmartThings device model.  Read only and can be updated as a result of changes made elsewhere in the system.
--- @field public state_cache table Caches the most recent event state generated for each component/capability/attribute this is per run session, and is persisted through restart.
--- @field public thread st.thread.Thread The handle to the cosock thread that executes events for this device. This can also be used directly to schedule your own events or use its `register_socket` function to handle a device-specific socket.
local Device = {}
Device.CLASS_NAME = "Device"

--- @function Device:emit_event
--- Emit a capability event for this devices main component.  Will log a warning and do nothing if there is no "main" component on the device
---
--- @param capability_event table the capability event to emit
local function emit_event(self, capability_event) end

--- @function component:emit_event
--- Emit a capability event for the corresponding component
---
--- @param capability_event table the capability event to emit
local function comp_emit_event(self, capability_event) end

--- Generate a capability event for this device and component
---
--- Usage: ``device:emit_component_event(device.profile.components.main, capabilities.switch.switch.on())``
---
--- @param component table The component to generate this event for
--- @param capability_event table The event table generated from a capability
--- @return table The converted SmartThings event generated by this device
function Device:emit_component_event(component, capability_event)
    if not self:supports_capability(capability_event.capability, component.id) then
        local err_msg = string.format("Attempted to generate event for %s.%s but it does not support capability %s", self.id, component.id, capability_event.capability.NAME)
        log.warn_with({ hub_logs = true }, err_msg)
        return false, err_msg
    end
    local event, err = capabilities.emit_event(self, component.id, self.capability_channel, capability_event)
    if event ~= nil then
        self.state_cache[component.id] = self.state_cache[component.id] or {}
        self.state_cache[component.id][capability_event.capability.ID] = self.state_cache[component.id][capability_event.capability.ID] or {}
        self.state_cache[component.id][capability_event.capability.ID][capability_event.attribute.NAME] = event.state
    end
    if err ~= nil then
        log.warn_with({ hub_logs = true }, err)
    end
    return event, err
end

local function new_device_mt(cls, device_proto)
    local mt = {}
    mt.__values = {}
    mt.__cls = cls

    for k,v in pairs(device_proto) do
        mt.__values[k] = v
    end

    mt.__index = function(self, key)
        local base_value = mt.__values[key]
        local st_store = mt.__values["st_store"]
        local override_fns = mt.__values["override_fns"]
        if base_value ~= nil then
            return base_value
        elseif type(st_store) == "table" and st_store[key] ~= nil then
            return st_store[key]
        elseif type(override_fns) == "table" and override_fns[key] ~= nil then
            return override_fns[key]
        end
        return mt.__cls[key]
    end
    mt.__newindex = function(self, key, value)
        error("Device table access is readonly.  Use set_field to add a new field to the device.")
    end
    mt.__tostring = cls.pretty_print
    return mt
end

--- Set a device specific value to be stored and retrieved when needed.  The key names are unique across both persistent and transient stores.
---
--- @param field string The field name for this value
--- @param value value The value to set the field to. If setting to persistent store it must be serializable
--- @param addtional_params table Optional: contains additional description of the field.  Currently only usage is the `persist` field which, if true, will store the field to the persistent store instead of transient
function Device:set_field(field, value, additional_params)
    local persisted = false
    if field == nil then
        error("Field key cannot be nil", 2)
    end

    if type(additional_params) == "table" then
        persisted = additional_params["persist"] or false
    elseif type(additional_params) ~= "nil" then
        error("additional_params must be a table")
    end
    -- Clear the old value out if it existed.
    self.transient_store[field] = nil
    self.persistent_store[field] = nil

    -- Set the new value in the corresponding persistence table
    if persisted then
        self.persistent_store[field] = value
    else
        self.transient_store[field] = value
    end
end

--- Get the `st.Device` object that is the parent of this device.  This _can_ result in a blocking request for the
--- parents device data, and can be subject to race conditions based on order of data sync.  This should _NOT_ be used
--- within an `added` or `init` lifecycle event to avoid race conditions and deadlocks.
---
--- @return st.Device the parent device object of this device
function Device:get_parent_device()
    local parent_device = self:get_field(PARENT_KEY)
    if parent_device == nil then
        parent_device = self.driver:get_device_info(self.parent_device_id)
        self:set_field(PARENT_KEY, parent_device)
    end
    return parent_device
end

--- Set a function used to find a child given an "endpoint" input specific to each protocol
---
--- @param find_child_fn function A function that takes a protocol specific endpoint identifier to find a child from
function Device:set_find_child(find_child_fn)
    self:set_field(device_module.FIND_CHILD_KEY, find_child_fn)
end

--- Get a list of all the children of this device
---
--- @return st.Device[] a list of the child devices of this device.  The type will be specific to the protocol
function Device:get_child_list()
  -- TODO: revisit once inventory child list is completed
  local dev_list = {}
  for uuid, dev in pairs(self.driver:get_devices()) do
    if dev.parent_device_id == self.id then
      table.insert(dev_list, dev)
    end
  end
  return dev_list
end

--- Find a child of this device by the parent assigned child key given at creation
---
--- @param parent_assigned_key string the key assigned by the parent to identify a child at creation
--- @return st.Device|st.zigbee.ChildDevice|st.zwave.ChildDevice|st.matter.ChildDevice|nil the child device with this key
function Device:get_child_by_parent_assigned_key(parent_assigned_key)
    -- TODO: optimize when possible from child device list in st_store
    for uuid, dev in pairs(self.driver:get_devices()) do
        if dev.parent_device_id == self.id then
            if dev.parent_assigned_child_key == parent_assigned_key then
                return dev
            end
        end
    end
end

--- Retrieve the value a previously set field.  nil if non-existent
---
--- @param field string The field name for this value
--- @return value value The value the field was set to.
function Device:get_field(field)
    if self.transient_store[field] ~= nil then
        return self.transient_store[field]
    elseif self.persistent_store[field] ~= nil then
        return self.persistent_store[field]
    end
end

--- Check if this device has a capability in its profile
---
--- @param capability Capability The capability to check for existence
--- @param component string Optional: The component id to check for capability support.  If nil, any component match will return true
--- @return boolean true if the capability is present in this devices profile
function Device:supports_capability(capability, component)
  return self:supports_capability_by_id(capability.ID, component)
end

--- Check if this device has a component_id in its profile
---
--- @param component_id string
--- @return boolean true if the component is present in this devices profile
function Device:component_exists(component_id)
  for comp_id, _ in pairs(self.st_store.profile.components) do
      if (component_id == comp_id) then
        return true
      end
  end
  return false
end

--- Get the latest state of this device for a given component, capability, attribute
---
--- @param component_id string the component ID to get the state for
--- @param capability_id string the capability ID to get the state for
--- @param attribute_name string the capability attribute name to get the state for
--- @param default_value any Optional value to return if the state_cache for the lookup is nil
--- @param default_state_table any Optional value to return if the state_cache for the lookup is nil
--- @return any, any The first return value is the state.value present for the attribute, the second return is the state
---                  table (e.g. it would include both the value and unit keys if both are present)
function Device:get_latest_state(component_id, capability_id, attribute_name, default_value, default_state_table)
    utils.verify_type(component_id, "string", "component_id")
    utils.verify_type(capability_id, "string", "capability_id")
    utils.verify_type(attribute_name, "string", "attribute_name")
    local state = ((self.state_cache[component_id] or {})[capability_id] or {})[attribute_name]
    local value = (state or {}).value
    if value == nil then
        value = default_value
    end
    if state == nil then
        state = default_state_table
    end
    return value, state
end

--- @return number count of components in device profile
function Device:component_count()
  local i = 0
  for _, _ in pairs(self.st_store.profile.components) do
    i = i + 1
  end
  return i
end

--- Check if this device has a capability_id in its profile
---
--- @param capability_id string The capability ID to check for existence
--- @param component string Optional: The component id to check for capability support.  If nil, any component match will return true
--- @return boolean true if the capability is present in this devices profile
function Device:supports_capability_by_id(capability_id, component)
    for comp_id, comp in pairs(self.st_store.profile.components) do
        if (component == nil) or (component == comp_id) then
            for cap_id, cap in pairs(comp.capabilities) do
                if cap.id == capability_id then
                    return true
                end
            end
        end
    end
    return false
end

Device.init = function(cls, driver, raw_device)
    local device = {}

    device.log = setmetatable(
        {},
        {
            __index = function(_, key)
                if key == "log" then
                    return function(opts, level, ...)
                        log.log(opts, level, tostring(device) .. " " .. ...)
                    end
                elseif string.find(key, "_with") ~= nil then
                    return log[key] and function(opts, ...) log[key](opts, tostring(device) .. " " .. ...) end or nil
                else
                    return log[key] and function(...) log[key](tostring(device) .. " " .. ...) end or nil
                end
            end
        }
    )

    device.capability_channel = driver.capability_channel
    device.device_api = driver.device_api

    driver.datastore.__devices_store = driver.datastore.__devices_store or {}
    driver.datastore.__devices_store[raw_device.id] = driver.datastore.__devices_store[raw_device.id] or {}
    device.persistent_store = driver.datastore.__devices_store[raw_device.id]
    device.datastore = driver.datastore

    device.override_fns = {}

    device.transient_store = {}

    device.persistent_store[STATE_CACHE_KEY] = device.persistent_store[STATE_CACHE_KEY] or {}
    device.state_cache = device.persistent_store[STATE_CACHE_KEY]

    device.thread = thread.Thread(driver, raw_device.label)

    local pers_store_mt = getmetatable(device.persistent_store) or {}
    local old_new_index = pers_store_mt.__newindex or rawset
    pers_store_mt.__newindex = function(self, key, value)
        if device.transient_store[key] ~= nil and value ~= nil then
            log.warn_with({ hub_logs = true }, "Key: " .. key .. " already exists in the transient store.  Use set_field if you want to move it.")
        else
            old_new_index(self, key, value)
        end
    end

    local trans_store_mt = {}
    trans_store_mt.__newindex = function(self, key, value)
        if device.persistent_store[key] ~= nil and value ~= nil then
            -- TODO: Error?
            log.warn_with({ hub_logs = true }, "Key: " .. key .. " already exists in the persistent store.  Use set_field if you want to move it.")
        else
            rawset(self, key, value)
        end
    end

    device.driver = driver

    return device
end

--- Send a request to update the metadata of a device.
---
--- Example usage: ``device:try_update_metadata({profile = "bulb.rgb.v1", vendor_provided_label = "My RGB Bulb"})``
---
--- All metadata fields are type string. Valid metadata fields are:
---
--- For all network types (LAN/ZIGBEE/ZWAVE/MATTER):
---     profile - profile name defined in the profile .yaml file.
---     provisioning_state - the provisioning state of the device (TYPED/PROVISIONED)
---
--- LAN specific:
---     manufacturer - device manufacturer
---     model - model name of the device
---     vendor_provided_label - device label provided by the manufacturer/vendor
---
--- @param metadata table A table of device metadata
function Device:try_update_metadata(metadata)
    assert(type(metadata) == "table")

    -- extract only keys we know are valid to prevent sending a bunch of garbage over the rpc
    local normalized_metadata = {
        deviceId = self.id,
        profileReference = metadata.profile,
        provisioningState = metadata.provisioning_state,
        manufacturer = metadata.manufacturer,
        model = metadata.model,
        vendorProvidedLabel = metadata.vendor_provided_label
    }

    local metadata_json = json.encode(normalized_metadata)
    if metadata_json == nil then
        error("error parsing device metadata", -1)
    end
    return devices_api.update_device(self.id, metadata_json)
end

Device._protect = function(cls, device)
    local mt = new_device_mt(cls, device)
    setmetatable(device, mt)
end


--- @function Device.build
--- Build a device object from a raw st_store of the SmartThings device model
---
--- @param cls table The Device class
--- @param driver Driver The driver context this device will run under
--- @param raw_device table The SmartThings device model representation, used to populate the st_store and generate
---                         helper event generation functions
--- @return Device The created device
function Device.build(cls, driver, raw_device)

    local device = Device.init(cls, driver, raw_device)

    Device._protect(cls, device)

    -- This is the data synced from the cloud and will be overwritten when data is updated
    device:load_updated_data(raw_device)

    return device
end


--- Update the st_store data with newly provided data from the cloud.
function Device:load_updated_data(new_device_data)
    convert_and_set_st_store(self, new_device_data)
    return self
end


--- Add a function to this device object, or override an existing function
---
--- @param func_name string the name of the function to add/overwrite
--- @param func function the function to add to the device object
function Device:extend_device(func_name, func)
    self.override_fns[func_name] = func
end

--- This will do any necessary cleanup if the device is removed.  The device object will not
--- be functional after this call.
function Device:deleted()
    if self.thread then
        self.thread:close()
        self.thread = nil
    end

    self.datastore.__devices_store[self.id] = nil
    local old_id = self.id
    local new_mt = {}
    new_mt.__index = function(s, key)
        log.warn_with({ hub_logs = true }, "This device (former ID: " .. old_id .. ") has been deleted, and is no longer usable")
        return nil
    end
    new_mt.__newindex = function(s, key, value)
        log.warn_with({ hub_logs = true }, "This device (former ID: " .. old_id .. ") has been deleted, and is no longer usable")
        return nil
    end
    setmetatable(self, new_mt)
end

--- Get a string with the ID and label of the device
---
--- @return string a short string representation of the device
function Device:pretty_print()
    local label_str = ""
    if self.label ~= nil then
        label_str = string.format(" (%s)", self.label)
    end
    return string.format("<%s: %s%s>", self.CLASS_NAME, self.id, label_str)
end

--- Mark device as being online
---
--- Only useable on LAN type devices, calls to this API for ZIGBEE, ZWAVE, or MATTER type
--- devices are ignored as their online/offline status are automatically determined at the
--- radio level.
---
--- @return status boolean Status of whether the call was successful or not
--- @return error string The error that occured if status was falsey
function Device:online()
    return self.device_api.device_online(self)
end

--- Mark device as being offline and unavailable
---
--- Only useable on LAN type devices, calls to this API for ZIGBEE, ZWAVE, or MATTER type
--- devices are ignored as their online/offline status are automatically determined at the
--- radio level.
---
--- @return status boolean Status of whether the call was successful or not
--- @return error string The error that occured if status was falsey
function Device:offline()
    return self.device_api.device_offline(self)
end

setmetatable(Device, {
    __call = Device.build,
})
device_module.Device = Device

return device_module
