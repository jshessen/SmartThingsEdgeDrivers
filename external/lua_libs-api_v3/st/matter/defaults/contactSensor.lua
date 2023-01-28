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
local capabilities = require "st.capabilities"
local clusters = require "st.matter.generated.zap_clusters.init"

--- @class st.matter.defaults.contactSensor
--- @field public matter_handlers table
--- @field public subscribed_attributes table
--- @field public capability_handlers table
local contact_sensor_defaults = {}

local function boolean_attr_handler(driver, device, ib, response)
  if ib.data.value then
    device:emit_event_for_endpoint(ib.endpoint_id, capabilities.contactSensor.contact.closed())
  else
    device:emit_event_for_endpoint(ib.endpoint_id, capabilities.contactSensor.contact.open())
  end
end

contact_sensor_defaults.matter_handlers = {
  attr = {
    [clusters.BooleanState.ID] = {
      [clusters.BooleanState.attributes.StateValue.ID] = boolean_attr_handler,
    },
  },
}
contact_sensor_defaults.capability_handlers = {}
contact_sensor_defaults.subscribed_attributes = {clusters.BooleanState.attributes.StateValue}

return contact_sensor_defaults
