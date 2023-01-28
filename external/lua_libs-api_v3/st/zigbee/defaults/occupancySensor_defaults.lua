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
local zcl_clusters = require "st.zigbee.zcl.clusters"
local capabilities = require "st.capabilities"

--- @class st.zigbee.defaults.occupancySensor
--- @field public zigbee_handlers table
--- @field public attribute_configurations table
--- @field public capability_handlers table
local occupancy_sensor_defaults = {}

--- Default handler for occupancy attribute on the occupancy sensing cluster
---
--- This converts the Bitmap8 value of the occupancy attribute to OccupancySensor.occupancy occupied if bit 1 is set
--- unoccupied otherwise
---
--- @param driver ZigbeeDriver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param value st.zigbee.data_types.Bitmap8 the value of the occupancy attribute on the OccupancySensing cluster
--- @param zb_rx st.zigbee.ZigbeeMessageRx the full message this report came in
function occupancy_sensor_defaults.occupancy_attr_handler(driver, device, value, zb_rx)
  local attr = capabilities.occupancySensor.occupancy
  device:emit_event_for_endpoint(zb_rx.address_header.src_endpoint.value, ((value.value & 0x01) ~= 0) and attr.occupied() or attr.unoccupied())
end

--- @class st.zigbee.defaults.occupancySensor.OccupancyConfiguration
--- @field public cluster number OccupancySensing ID 0x0406
--- @field public attribute number Occupancy ID 0x0000
--- @field public minimum_interval number 0 seconds
--- @field public maximum_interval number 3600 seconds (1 hour)
--- @field public data_type st.zigbee.data_types.Bitmap8 the Bitmap8 class
local occupancy_configuration = {
  cluster = zcl_clusters.OccupancySensing.ID,
  attribute = zcl_clusters.OccupancySensing.attributes.Occupancy.ID,
  minimum_interval = 0,
  maximum_interval = 3600,
  data_type = zcl_clusters.OccupancySensing.attributes.Occupancy.base_type,
}

occupancy_sensor_defaults.default_occupancy_configuration = occupancy_configuration

occupancy_sensor_defaults.attribute_configurations = {
  occupancy_configuration
}

occupancy_sensor_defaults.zigbee_handlers = {
  global = {},
  cluster = {},
  attr = {
    [zcl_clusters.OccupancySensing] = {
      [zcl_clusters.OccupancySensing.attributes.Occupancy] = occupancy_sensor_defaults.occupancy_attr_handler,
    }
  }
}
occupancy_sensor_defaults.capability_handlers = {}

return occupancy_sensor_defaults
