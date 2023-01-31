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

--- @class st.zigbee.defaults.powerSource
--- @field public zigbee_handlers table
--- @field public attribute_configurations table
--- @field public capability_handlers table
local powerSource_defaults = {}

--- Default handler for power source attribute on the basic cluster
---
--- This converts the power source value to the appropriate value
---
--- @param driver ZigbeeDriver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param value st.zigbee.zcl.clusters.Basic.PowerSource  the value of the Basic cluster Power Source attribute
--- @param zb_rx st.zigbee.ZigbeeMessageRx the full message this report came in
function powerSource_defaults.power_source_attr_handler(driver, device, value, zb_rx)
  local PowerSource = require "st.zigbee.generated.zcl_clusters.Basic.server.attributes.PowerSource"
  local POWER_SOURCE_MAP = {
    [PowerSource.UNKNOWN]                                                 = capabilities.powerSource.powerSource.unknown,
    [PowerSource.UNKNOWN_WITH_BATTERY_BACKUP]                             = capabilities.powerSource.powerSource.unknown,
    [PowerSource.SINGLE_PHASE_MAINS]                                      = capabilities.powerSource.powerSource.mains,
    [PowerSource.THREE_PHASE_MAINS]                                       = capabilities.powerSource.powerSource.mains,
    [PowerSource.SINGLE_PHASE_MAINS_WITH_BATTERY_BACKUP]                  = capabilities.powerSource.powerSource.mains,
    [PowerSource.THREE_PHASE_MAINS_WITH_BATTERY_BACKUP]                   = capabilities.powerSource.powerSource.mains,
    [PowerSource.EMERGENCY_MAINS_CONSTANTLY_POWERED]                      = capabilities.powerSource.powerSource.mains,
    [PowerSource.EMERGENCY_MAINS_AND_TRANSFER_SWITCH]                     = capabilities.powerSource.powerSource.mains,
    [PowerSource.EMERGENCY_MAINS_CONSTANTLY_POWERED_WITH_BATTERY_BACKUP]  = capabilities.powerSource.powerSource.mains,
    [PowerSource.EMERGENCY_MAINS_AND_TRANSFER_SWITCH_WITH_BATTERY_BACKUP] = capabilities.powerSource.powerSource.mains,
    [PowerSource.BATTERY]                                                 = capabilities.powerSource.powerSource.battery,
    [PowerSource.BATTERY_WITH_BATTERY_BACKUP]                             = capabilities.powerSource.powerSource.battery,
    [PowerSource.DC_SOURCE]                                               = capabilities.powerSource.powerSource.dc,
    [PowerSource.DC_SOURCE_WITH_BATTERY_BACKUP]                           = capabilities.powerSource.powerSource.dc
  }

  if POWER_SOURCE_MAP[value.value] then
    device:emit_event_for_endpoint(zb_rx.address_header.src_endpoint.value, POWER_SOURCE_MAP[value.value]())
  end
end

powerSource_defaults.zigbee_handlers = {
  global = {},
  cluster = {},
  attr = {
    [zcl_clusters.Basic.ID] = {
      [zcl_clusters.Basic.attributes.PowerSource.ID] = powerSource_defaults.power_source_attr_handler
    }
  }
}

return powerSource_defaults
