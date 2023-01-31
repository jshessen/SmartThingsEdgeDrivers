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
local utils = require "st.utils"
local dkjson = require "dkjson"

local uuid_counter = 1

-- Global for usage from driver under test
local mock_devices_api = {}
mock_devices_api = {
  _device_info_cache = {},
  -- Keep separate cache to guarantee consistent order of returns
  _device_id_cache = {},
  _expected_device_updates = {},
  _expected_device_creates = {},
  _get_test_uuid = function()
    local uuid = string.format("00000000-1111-2222-3333-%012d", uuid_counter)
    uuid_counter = uuid_counter + 1
    return uuid
  end,
  get_device_info = function(device_uuid)
    return mock_devices_api._device_info_cache[device_uuid]
  end,
  get_device_list = function()
    return mock_devices_api._device_id_cache
  end,
  update_device = function(device_id, device_metadata)
    local expected_vals = mock_devices_api._expected_device_updates[1] or {}
    assert(expected_vals["device_id"] == device_id,
           string.format("Received device update for device %s: %s when expecting %s",
                         device_id,
                         device_metadata,
                         expected_vals["device_id"])
    )
    local tab_data = dkjson.decode(device_metadata)
    assert(utils.stringify_table((expected_vals)["metadata"]) == utils.stringify_table(tab_data),
           string.format("Received device update %s when expecting %s",
                         utils.stringify_table(tab_data),
                         utils.stringify_table(expected_vals["metadata"]))
    )
    table.remove(mock_devices_api._expected_device_updates, 1)
  end,
  create_device = function(device_metadata)
    local expected_vals = mock_devices_api._expected_device_creates[1] or {}
    local tab_data = dkjson.decode(device_metadata)
    assert(utils.stringify_table((expected_vals)["metadata"]) == utils.stringify_table(tab_data),
           string.format("Received device update %s when expecting %s",
                         utils.stringify_table(tab_data),
                         utils.stringify_table(expected_vals["metadata"]))
    )
    table.remove(mock_devices_api._expected_device_creates, 1)
  end
}

--- Expect an RPC call to update a devices metadata
---
--- @param device_id string
--- @param device_metadata table
function mock_devices_api.__expect_update_device(device_id, device_metadata)
  table.insert(mock_devices_api._expected_device_updates, {
    device_id = device_id,
    metadata = device_metadata,
  })
end

--- Expecct an RPC call to create a device
---
---@param device_metadata table
function mock_devices_api.__expect_create_device(device_metadata)
  table.insert(mock_devices_api._expected_device_creates, {
    metadata = device_metadata
  })
end

--- Used by the test framework to verify that when a test has completed there
--- are no expected metadata updates or device creations that haven't been sent
function mock_devices_api.__check_for_unsent_command()
  if #mock_devices_api._expected_device_updates > 0 then
    for _, m in ipairs(mock_devices_api._expected_device_updates) do
      print(string.format(
          "devices_api was expecting a device metadata change that was not received:\n  %s",
          utils.stringify_table(m)
      ))
    end
    return true
  elseif #mock_devices_api._expected_device_creates > 0 then
    for _, m in ipairs(mock_devices_api._expected_device_creates) do
      print(string.format(
          "devices_api was expecting a device creation call that was not received:\n  %s",
          utils.stringify_table(m)
      ))
    end
    return true
  end
  return false
end

--- Add a mock device to be associated with the driver
---
--- This sets the device ID and info to be returned to the driver when it requests
--- device data or the device list
---
--- @param mock_device integration_test.MockDevice the mock device to add
function mock_devices_api._add_mock_device(mock_device)
  mock_devices_api._device_info_cache[mock_device.id] = dkjson.encode(rawget(mock_device, "raw_st_data"))
  mock_devices_api._device_id_cache[#mock_devices_api._device_id_cache + 1] = mock_device.id
end

--- Update a devices info to be returned from device info requests
---
--- @param id string the device id
--- @param raw_st_data_json string the JSON serialized version of the st data for the device
function mock_devices_api._update_mock_device_info(id, raw_st_data_json)
  mock_devices_api._device_info_cache[id] = raw_st_data_json
end

mock_devices_api.reset = function()
  mock_devices_api._device_info_cache = {}
  mock_devices_api._device_id_cache = {}
  mock_devices_api._expected_device_updates = {}
  mock_devices_api._expected_device_creates = {}
end

return mock_devices_api
