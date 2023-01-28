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
local base64 = require "st.base64"
local utils = require "st.utils"
local json = require "dkjson"
local zcl_clusters = require "st.zigbee.zcl.clusters"
local device_module = require "st.device"
local mock_devices_api = require "integration_test.mock_devices_api"
local device_wrapper = require "integration_test.device_wrapper"

--- @module mock_device
local mock_device_module = {}

local zigbee_cluster_list = {}
for id, name in pairs(zcl_clusters.id_to_name_map) do
  table.insert(zigbee_cluster_list, id)
end

--- Add this MockDevice to the manifest for this driver
---
--- By using this method, it will add this device's info to be returned by the normal
--- query methods for the driver requesting info about devices it is responsible for
---
--- @param device integration_test.MockDevice the device to add to the driver
function mock_device_module.add_test_device(device)
  if device.id == nil then
    error("Mock device requires UUID")
  end
  if device.profile == nil then
    error("No profile provided.  Device requires profile for correct behavior.")
  end

  mock_devices_api._add_mock_device(device)
end

--- Build a mock device from a template
---
--- @param device_template table the non-default st data about this device
--- @param additional_mock_fields table any additional mock fields that should be present
--- @return integration_test.MockDevice
function mock_device_module.build_test_generic_device(device_template, additional_mock_fields)
  local device_defaults = {
    id = mock_devices_api._get_test_uuid(),
    data = {},
    preferences = {},
  }
  utils.merge(device_template, device_defaults)
  if (device_template.profile.preferences ~= nil) then
    for title, pref in pairs(device_template.profile.preferences) do
      device_template.preferences[title] = pref.definition.default
    end
    device_template.profile.preferences = nil
  end
  local raw_dev = utils.deep_copy(device_template)
  local mock_device = device_wrapper.MockDevice.init(raw_dev, additional_mock_fields, mock_devices_api)
  return mock_device
end

--- Build a mock Zigbee device from a template
---
--- This will include some additional mock functions necessary for easy construction of
--- test messages.
---
--- @param device_template table the non-default st data about this device
--- @return integration_test.MockDevice
function mock_device_module.build_test_child_device(device_template)
  local device_defaults = {
    network_type = device_module.NETWORK_TYPE_CHILD,
  }
  utils.merge(device_template, device_defaults)

  local device = mock_device_module.build_test_generic_device(utils.deep_copy(device_template))
  return device
end


local zigbee_dni_counter = 1
local device_eui_counter = 1

--- Build a mock Zigbee device from a template
---
--- This will include some additional mock functions necessary for easy construction of
--- test messages.
---
--- @param device_template table the non-default st data about this device
--- @return integration_test.MockDevice
function mock_device_module.build_test_zigbee_device(device_template)

  local device_defaults = {
    device_network_id = string.format("%04X", zigbee_dni_counter),
    network_type = device_module.NETWORK_TYPE_ZIGBEE,
    zigbee_eui = base64.encode("\x24\xFD\x5B\x00\x00\x01\x95" .. string.pack("<B", device_eui_counter)),
    fingerprinted_endpoint_id=0,
  }
  utils.merge(device_template, device_defaults)
  -- Do this separately because we don't want to add this endpoint in the recursive merge if they explicitly set any
  -- endpoints
  if device_template.zigbee_endpoints == nil then
    device_template.zigbee_endpoints = {
      [0] = {id = 0, server_clusters = zigbee_cluster_list}
    }
  else
    local ep_id = 0xFF
    -- default to fingerpinting on the first endpoint provided.  This hueristic isn't
    -- perfect but can be overriden by directly specifying the fingprinted_endpoint_id
    -- on the template passed in, and in most cases there will be only one endopint
    -- specified so this would be correct.
    for k, v in pairs(device_template.zigbee_endpoints) do
      if k < ep_id then
        ep_id = k
      end
    end
    device_template.fingerprinted_endpoint_id = ep_id
  end
  local additional_mock_fields = {}
  additional_mock_fields.zigbee_eui = base64.decode(device_template.zigbee_eui)

  additional_mock_fields.get_short_address = function(self)
    return tonumber(self.device_network_id, 16)
  end

  additional_mock_fields.get_endpoint = function(self, cluster)
    for _, ep in pairs(self.zigbee_endpoints) do
      for _, clus in ipairs(ep.server_clusters) do
        if clus == cluster then
          return ep.id
        end
      end
    end
    return self.fingerprinted_endpoint_id
  end

  additional_mock_fields.get_manufacturer = function(self)
    local fingerprinted_endpoint = self.zigbee_endpoints[self.fingerprinted_endpoint_id]
    if fingerprinted_endpoint ~= nil and fingerprinted_endpoint.manufacturer ~= nil then
      return fingerprinted_endpoint.manufacturer
    end
    for _, ep in pairs(self.zigbee_endpoints) do
      if ep.manufacturer ~= nil then
        return ep.manufacturer
      end
    end
    return nil
  end

  local device = mock_device_module.build_test_generic_device(utils.deep_copy(device_template), additional_mock_fields)

  zigbee_dni_counter = zigbee_dni_counter + 1
  device_eui_counter = device_eui_counter + 1
  return device
end

local zwave_dni_counter = 1
--- Build a mock ZWave device from a template
---
--- @param device_template table the non-default st data about this device
--- @return integration_test.MockDevice
function mock_device_module.build_test_zwave_device(device_template)

  local device_defaults = {
    device_network_id = string.format("%02X", zigbee_dni_counter),
    network_type = device_module.NETWORK_TYPE_ZWAVE,
  }
  utils.merge(device_template, device_defaults)
  local device = mock_device_module.build_test_generic_device(utils.deep_copy(device_template))

  return device
end

--- Build a mock Matter device from a template
---
--- @param device_template table the non-default st data about this device
--- @return integration_test.MockDevice
function mock_device_module.build_test_matter_device(device_template)

  local device_defaults = {
    network_type = device_module.NETWORK_TYPE_MATTER,
  }
  utils.merge(device_template, device_defaults)
  local device = mock_device_module.build_test_generic_device(utils.deep_copy(device_template))

  return device
end

return mock_device_module
