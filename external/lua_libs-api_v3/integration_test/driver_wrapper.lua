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
local original_driver = require "st.driver"
local cosock = require "cosock"

local wrapped_driver = {}

local original_driver_init = original_driver.init


local function wrapped_driver_select(self, recv, sendt, timeout)
  -- don't use timeout
  return cosock.socket.select(recv, sendt, nil)
end

local function wrapped_driver_init(...)
  wrapped_driver.driver_under_test = original_driver_init(...)
  if wrapped_driver.driver_test_env_init ~= nil then
    wrapped_driver.driver_test_env_init(wrapped_driver.driver_under_test)
  end
  -- Mark the driver to treat errors as fatal instead of just catching and logging
  wrapped_driver.driver_under_test._fail_on_error = true
  wrapped_driver.driver_under_test._internal_select = wrapped_driver_select
  return wrapped_driver.driver_under_test
end

original_driver.init = wrapped_driver_init

local mt = getmetatable(original_driver)
mt.__call = wrapped_driver_init

function wrapped_driver.set_test_env_init(init)
  wrapped_driver.driver_test_env_init = init
end

function wrapped_driver.reset()
  wrapped_driver.driver_under_test = nil
end

return wrapped_driver
