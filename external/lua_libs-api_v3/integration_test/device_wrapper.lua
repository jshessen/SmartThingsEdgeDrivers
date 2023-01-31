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
local base_device = require "st.device"
local caps = require "st.capabilities"
local utils = require "st.utils"
local json = require "st.json"

local wrapped_device_mod = {}
wrapped_device_mod.devices = {}
wrapped_device_mod.mock_devices = {}
local base_init = base_device.Device.init

local function wrapped_init(cls, driver, raw_device)
  local dev = base_init(cls, driver, raw_device)
  wrapped_device_mod.devices[raw_device.id] = dev
  local mock_dev = wrapped_device_mod.mock_devices[raw_device.id]
  local p_fields = rawget(mock_dev, "mock_fields")["persistent"]
  local t_fields = rawget(mock_dev, "mock_fields")["transient"]
  for k,v in pairs(p_fields) do
    dev.persistent_store[k] = v
  end
  for k,v in pairs(t_fields) do
    dev.transient_store[k] = v
  end
  rawget(mock_dev, "mock_fields")["persistent"] = {}
  rawget(mock_dev, "mock_fields")["transient"] = {}
  rawset(mock_dev, "wrapped_device", dev)
  return dev
end

base_device.Device.init = wrapped_init

function wrapped_device_mod.reset()
  for id, dev in pairs(wrapped_device_mod.mock_devices) do
    rawset(dev, "wrapped_device", nil)
  end
  for id, dev in pairs(wrapped_device_mod.devices) do
    wrapped_device_mod.devices[id] = nil
  end
end

--- @class integration_test.MockDevice
local MockDevice = {}

--- Generate a test message representing this device emitting the given event
---
--- @param self integration_test.MockDevice
--- @param component_id string the component this event should be generated for
--- @param capability_event table the capability event
--- @return table the message objecte needed for a message test or __expect_send on the capability channel
function MockDevice:generate_test_message(component_id, capability_event)
  return {self.id, caps.raw_event_to_edge_event(component_id, capability_event)}
end

--- Set a device field value if the driver test hasn't been initialized yet
---
--- Because the MockDevice typically is a passthrough into the actual device within the driver under test
--- typically get_field will refer to the actual device object in the driver under test.  However, because
--- the MockDevice persists between tests and can be referred to when a test isn't running and thus the
--- device passthrough can't be done, it will maintain it's own fields store that will be used to populate the
--- device object when the device does start.  This mock method will only be called when the device passthrough
--- is not available and will set a field in the mock field store
---
--- @param self integration_test.MockDevice
--- @param key string the key of the field to get
--- @param value any the value to store to the field
--- @param opts table additional options (persist bool)
function MockDevice.set_field(self, key, value, opts)
  if opts.persist then
    rawget(self, "mock_fields").persistent[key] = value
  else
    rawget(self, "mock_fields").transient[key] = value
  end
end

--- Get a device field value if the driver test hasn't been initialized yet
---
--- Because the MockDevice typically is a passthrough into the actual device within the driver under test
--- typically get_field will refer to the actual device object in the driver under test.  However, because
--- the MockDevice persists between tests and can be referred to when a test isn't running and thus the
--- device passthrough can't be done, it will maintain it's own fields store that will be used to populate the
--- device object when the device does start.  This mock method will only be called when the device passthrough
--- is not available and will return from the mock field store.
---
--- @param self integration_test.MockDevice
--- @param key string the key of the field to get
function MockDevice:get_field(key)
  return rawget(self, "mock_fields").persistent[key] or rawget(self, "mock_fields").transient[key]
end

local name_map = {
  profile = "profileReference",
}

--- Set the test to expect a device metadata update to be generated
---
--- This takes args of the same form as st.Device:try_update_metadata
---
--- @param self integration_test.MockDevice
--- @param metadata table the metadata update command that is expected to be sent
function MockDevice:expect_metadata_update(metadata)
  local devices_api = rawget(self, "devices_api")
  metadata["device_id"] = self.id
  local md_copy = {}
  for k, v in pairs(metadata) do
    local key = name_map[k]
    if key == nil then
      key = utils.camel_case(k)
    end
    md_copy[key] = v
  end

  devices_api.__expect_update_device(self.id, md_copy)
end

--- Set the test to expect a device creation call to occur
---
--- This takes args of the same form as st.Driver:try_create_device
---
---@param metadata table the metadata for the device that should be created
function MockDevice:expect_device_create(metadata)
  local devices_api = rawget(self, "devices_api")

  local md_copy = {}
  for k, v in pairs(metadata) do
    local key = name_map[k]
    if key == nil then
      key = utils.camel_case(k)
    end
    md_copy[key] = v
  end

  devices_api.__expect_create_device(md_copy)
end

--- Generate a device_lifecycle infoChanged message to be queued in tests
---
--- This takes a table of key,value pairs to update info about this device. These should
--- only be keys that would be present in the st_store of a device object
---
--- @param self integration_test.MockDevice
--- @param metadata table the metadata update command that is expected to be sent
function MockDevice:generate_info_changed(changed_values)
  local devices_api = rawget(self, "devices_api")
  if changed_values.profile ~= nil and changed_values.profile.id == nil then
    changed_values.profile.id = devices_api._get_test_uuid()
  end
  local updated_data = utils.deep_copy(rawget(self, "raw_st_data"))
  utils.update(updated_data, changed_values)

  local device_info_json = json.encode(updated_data)
  devices_api._update_mock_device_info(self.id, device_info_json)
  return {self.id, "infoChanged", device_info_json}
end

MockDevice.__index = function(self, key)
  -- First delegate to the actual device if it is present
  if (rawget(self, "wrapped_device") or {})[key] ~= nil then
    return rawget(self, "wrapped_device")[key]
  elseif MockDevice[key] ~= nil then
    return MockDevice[key]
  elseif (rawget(self, "additional_mock_fields") or {})[key] ~= nil then
    return rawget(self, "additional_mock_fields")[key]
  elseif rawget(self, "raw_st_data")[key] ~= nil then
    return rawget(self, "raw_st_data")[key]
  end
  return rawget(self, key)
end

--- Create a MockDevice from st_data and additional mock fields
---
--- @param raw_st_data table the values representing this device that would be used on the ST platform
--- @param additional_mock_fields table any additional fields that this device should mock out
--- @return integration_test.MockDevice the constructed mock device
function MockDevice.init(raw_st_data, additional_mock_fields, devices_api)
  local o = {}
  o.mock_fields = {
    persistent = {},
    transient = {}
  }
  o.devices_api = devices_api
  o.raw_st_data = raw_st_data and utils.deep_copy(raw_st_data) or {}
  if o.raw_st_data.profile.id == nil then
    o.raw_st_data.profile.id = devices_api._get_test_uuid()
  end
  o.additional_mock_fields = additional_mock_fields
  setmetatable(o, MockDevice)
  wrapped_device_mod.mock_devices[raw_st_data.id] = o
  return o
end

wrapped_device_mod.MockDevice = MockDevice

return wrapped_device_mod
