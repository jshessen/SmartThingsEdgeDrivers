-- Copyright 2022 Ryan Mulder
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
local Driver = require "st.driver"

local function handle_on(driver, device, command)
  log.info("Send on command to device")

  -- for real devices you should make a request to a device and wait for the
  -- response confirming the device was switched on before emitting this
  device:emit_event(capabilities.switch.switch.on())
end

local function handle_off(driver, device, command)
  log.info("Send off command to device")

  -- for real devices you should make a request to a device and wait for the
  -- response confirming the device was switched off before emitting this
  device:emit_event(capabilities.switch.switch.off())
end

-- Driver library initialization
local example_driver =
  Driver("example_driver",
    {
      capability_handlers = {
      [capabilities.switch.ID] =
      {
        [capabilities.switch.commands.on.NAME] = handle_on,
        [capabilities.switch.commands.off.NAME] = handle_off
      }
    }
  }
)

-- Put other setup code here

example_driver:run()