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
local base_datastore = require "datastore"

local datastore_wrapper = {}
datastore_wrapper.mock_device_datastore = {}

local original_init = base_datastore.init
datastore_wrapper.ds_under_test = original_init({})

local function wrapped_datastore_init(driver)
    return datastore_wrapper.ds_under_test
end

base_datastore.init = wrapped_datastore_init

function datastore_wrapper.reset()
    for k, _ in pairs(datastore_wrapper.ds_under_test) do
        datastore_wrapper.ds_under_test[k] = nil
    end
    datastore_wrapper.ds_under_test:save()
end

return datastore_wrapper
