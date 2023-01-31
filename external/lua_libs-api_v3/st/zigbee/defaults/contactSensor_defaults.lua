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

--- @class st.zigbee.defaults.contactSensor
--- @field public zigbee_handlers table
--- @field public attribute_configurations table
--- @field public capability_handlers table
--- @field public default_ias_zone_configuration st.zigbee.defaults.contactSensor.IASZoneConfiguration
local contactSensor_defaults = {}

local generate_event_from_zone_status = function(driver, device, zone_status, zigbee_message)
  device:emit_event_for_endpoint(
      zigbee_message.address_header.src_endpoint.value,
      (zone_status:is_alarm1_set() or zone_status:is_alarm2_set()) and capabilities.contactSensor.contact.open() or capabilities.contactSensor.contact.closed())
end

--- Default handler for IAS zone status attribute change
---
--- This converts the IAS Zone Status attribute report or read response value to a contact sensor event.
--- If alarm1 or alarm2 bits are set, this results in a closed event, if both are unset, it is an open event
---
--- @param driver ZigbeeDriver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param zone_status st.zigbee.zcl.types.IasZoneStatus the Zone Status value
--- @param zb_rx st.zigbee.ZigbeeMessageRx the full message this report came in
function contactSensor_defaults.ias_zone_status_attr_handler(driver, device, zone_status, zb_rx)
  generate_event_from_zone_status(driver, device, zone_status, zb_rx)
end

--- Default handler for Zone Status Change Notification cluster command
---
--- This converts the IAS Zone Status value sent in the change notification command to a contact sensor event.
--- If alarm1 or alarm2 bits are set, this results in a closed event, if both are unset, it is an open event
---
--- @param driver ZigbeeDriver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param zb_rx st.zigbee.ZigbeeMessageRx the full message containing the ZoneStatusChangeNotification cluster command as the zb_rx.body.zcl_body
function contactSensor_defaults.ias_zone_status_change_handler(driver, device, zb_rx)
  generate_event_from_zone_status(driver, device, zb_rx.body.zcl_body.zone_status, zb_rx)
end

contactSensor_defaults.zigbee_handlers = {
  global = {},
  cluster = {
    [zcl_clusters.IASZone.ID] = {
      [zcl_clusters.IASZone.client.commands.ZoneStatusChangeNotification.ID] = contactSensor_defaults.ias_zone_status_change_handler
    }
  },
  attr = {
    [zcl_clusters.IASZone.ID] = {
      [zcl_clusters.IASZone.attributes.ZoneStatus.ID] = contactSensor_defaults.ias_zone_status_attr_handler
    }
  }
}

contactSensor_defaults.capability_handlers = {}

--- @class st.zigbee.defaults.contactSensor.IASZoneConfiguration
--- @field public cluster number IASZone ID 0x0500
--- @field public attribute number ZoneStatus ID 0x0002
--- @field public minimum_interval number 30 seconds
--- @field public maximum_interval number 300 seconds (5 min)
--- @field public data_type st.zigbee.zcl.types.IasZoneStatus the ZoneStatus type class
local ias_zone_configuration = {
  cluster = zcl_clusters.IASZone.ID,
  attribute = zcl_clusters.IASZone.attributes.ZoneStatus.ID,
  minimum_interval = 30,
  maximum_interval = 300,
  data_type = zcl_clusters.IASZone.attributes.ZoneStatus.base_type
}

contactSensor_defaults.default_ias_zone_configuration = ias_zone_configuration

contactSensor_defaults.attribute_configurations = {
  ias_zone_configuration
}

return contactSensor_defaults
