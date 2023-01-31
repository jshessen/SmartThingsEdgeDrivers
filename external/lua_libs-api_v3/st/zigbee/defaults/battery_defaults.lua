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
local log = require "log"
local zcl_clusters = require "st.zigbee.zcl.clusters"
local capabilities = require "st.capabilities"
local utils = require "st.utils"

local ZIGBEE_BATTERY_VOLTAGE_MULTIPLIER = 10

--- @class st.zigbee.defaults.battery
--- @field public zigbee_handlers table
--- @field public attribute_configurations table
--- @field public capability_handlers table
--- @field public default_voltage_configuration st.zigbee.defaults.battery.BatteryVoltageConfiguration
--- @field public default_percentage_configuration st.zigbee.defaults.battery.BatteryPercentageConfiguration
--- @field public DEVICE_MIN_VOLTAGE_KEY string a device field name to set the minimum voltage for default battery
--- @field public DEVICE_MAX_VOLTAGE_KEY string a device field name to set the maximum voltage for default battery
--- @field public DEVICE_VOLTAGE_TABLE_KEY string a device field name to set a table for voltage entries in default handling
local battery_defaults = {}

battery_defaults.DEVICE_MIN_VOLTAGE_KEY = "_min_battery_voltage"
battery_defaults.DEVICE_MAX_VOLTAGE_KEY = "_max_battery_voltage"
battery_defaults.DEVICE_VOLTAGE_TABLE_KEY = "_battery_voltage_table"

--- @class st.zigbee.defaults.battery.BatteryVoltageConfiguration
--- @field public cluster number PowerConfiguration ID 0x0001
--- @field public attribute number BatteryVoltage ID 0x0020
--- @field public minimum_interval number 30 seconds
--- @field public maximum_interval number 21600 seconds (6 hours)
--- @field public data_type st.zigbee.data_types.Uint8 the Uint8 class
--- @field public reportable_change number 1 (.1 volts)
local default_voltage_configuration = {
  cluster = zcl_clusters.PowerConfiguration.ID,
  attribute = zcl_clusters.PowerConfiguration.attributes.BatteryVoltage.ID,
  minimum_interval = 30,
  maximum_interval = 21600,
  data_type = zcl_clusters.PowerConfiguration.attributes.BatteryVoltage.base_type,
  reportable_change = 1
}

--- @class st.zigbee.defaults.battery.BatteryPercentageConfiguration
--- @field public cluster number PowerConfiguration ID 0x0001
--- @field public attribute number BatteryPercentageRemaining ID 0x0021
--- @field public minimum_interval number 30 seconds
--- @field public maximum_interval number 21600 seconds (6 hours)
--- @field public data_type st.zigbee.data_types.Uint8 the Uint8 class
--- @field public reportable_change number 1 (.5 percent)
local default_percentage_configuration = {
  cluster = zcl_clusters.PowerConfiguration.ID,
  attribute = zcl_clusters.PowerConfiguration.attributes.BatteryPercentageRemaining.ID,
  minimum_interval = 30,
  maximum_interval = 21600,
  data_type = zcl_clusters.PowerConfiguration.attributes.BatteryPercentageRemaining.base_type,
  reportable_change = 1
}

--- Remove the configuration and monitoring of battery percentage remaining attribute and add configuration and monitoring
--- for battery voltage attribute
function battery_defaults.use_battery_voltage_handling(device)
  device:add_configured_attribute(default_voltage_configuration)
  device:add_monitored_attribute(default_voltage_configuration)
  device:remove_monitored_attribute(zcl_clusters.PowerConfiguration.ID, zcl_clusters.PowerConfiguration.attributes.BatteryPercentageRemaining.ID)
  device:remove_configured_attribute(zcl_clusters.PowerConfiguration.ID, zcl_clusters.PowerConfiguration.attributes.BatteryPercentageRemaining.ID)
end

--- Build a function to set the devices battery_defaults.DEVICE_MIN_VOLTAGE_KEY and
--- battery_defaults.DEVICE_MAX_VOLTAGE_KEY in a devices init function to leverage the battery voltage default handler
--- for alternative min and max volts. Will also disable battery percentage remaining attribute configuration and monitoring.
---
--- @param bat_min number the minimum voltage to consider for this devices scaling
--- @param bat_max number the maximum voltage to consider for this devices scaling
--- @return fun(driver:ZigbeeDriver, device:st.zigbee.Device, event:string, args:table)
function battery_defaults.build_linear_voltage_init(bat_min, bat_max)
  return function(driver, device, event, args)
    battery_defaults.use_battery_voltage_handling(device)
    device:set_field(battery_defaults.DEVICE_MIN_VOLTAGE_KEY, bat_min)
    device:set_field(battery_defaults.DEVICE_MAX_VOLTAGE_KEY, bat_max)
  end
end

--- Enable the usage of a voltage to battery percentage table for reporting battery.
--- Will also disable battery percentage remaining attribute configuration and monitoring.
---
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param battery_table table a map of battery voltages to battery percentages
function battery_defaults.enable_battery_voltage_table(device, battery_table)
  battery_defaults.use_battery_voltage_handling(device)
  device:set_field(battery_defaults.DEVICE_VOLTAGE_TABLE_KEY, battery_table)
end

--- Default handler for battery voltage attribute on the power config cluster
---
--- This converts the Uint8 value from 0-254 to Battery.battery(0-100).
---
--- The exact behavior of this default function can be controlled by using a few fields set on a device
---
--- Using battery_defaults.DEVICE_VOLTAGE_TABLE_KEY
--- If the device has a value set for the battery_defaults.DEVICE_VOLTAGE_TABLE_KEY this function will find the table
--- entry whose key is the lowest number that is greater than or equal to the devices reported voltage.  The value at
--- that table entry is then used as the battery percentage
---
--- Using battery_defaults.DEVICE_MIN_VOLTAGE_KEY and battery_defaults.DEVICE_MAX_VOLTAGE_KEY
--- If the device has values set for these keys, they are used for the bounds of linear scaling calculation of the
--- battery percentage between the two reported values.
---
--- If none of the above keys are set, this will default to using a linear scaling between 2.0 and 3.0 volts.
---
--- @param driver ZigbeeDriver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param value st.zigbee.data_types.Uint8 the value of the battery voltage on the power config cluster
--- @param zb_rx st.zigbee.ZigbeeMessageRx the full message this report came in
function battery_defaults.battery_volt_attr_handler(driver, device, value, zb_rx)
  local battery_table = device:get_field(battery_defaults.DEVICE_VOLTAGE_TABLE_KEY)
  local batt_perc
  if battery_table ~= nil then
    -- Find the highest voltage table entry that is less than the reported voltage
    for volt, perc in utils.rkeys(battery_table) do
      if value.value >= volt * ZIGBEE_BATTERY_VOLTAGE_MULTIPLIER then
        batt_perc = perc
        break
      end
    end
  else
    local bat_default_min = device:get_field(battery_defaults.DEVICE_MIN_VOLTAGE_KEY)
    local bat_default_max = device:get_field(battery_defaults.DEVICE_MAX_VOLTAGE_KEY)
    if bat_default_max ~= nil and bat_default_min ~= nil and bat_default_min ~= bat_default_max then
      bat_default_min = bat_default_min * ZIGBEE_BATTERY_VOLTAGE_MULTIPLIER
      bat_default_max = bat_default_max * ZIGBEE_BATTERY_VOLTAGE_MULTIPLIER
      batt_perc = math.floor(((value.value - bat_default_min) / (bat_default_max - bat_default_min) * 100) + 0.5)
    end
  end
  if batt_perc ~= nil then
    device:emit_event_for_endpoint(
        zb_rx.address_header.src_endpoint.value,
        capabilities.battery.battery(utils.clamp_value(batt_perc, 0, 100))
    )
  else
    log.warn_with({ hub_logs = true }, "The device reported a voltage, but the driver was not configured to handle it.")
  end
end

--- Default handler for battery percentage attribute on the power config cluster
---
--- This converts the Uint8 value from 0-254 to Battery.battery(0-100).
---
--- @param driver ZigbeeDriver The current driver running containing necessary context for execution
--- @param device st.zigbee.Device The device this message was received from containing identifying information
--- @param value st.zigbee.data_types.Uint8 the value of the battery percentage on the power config cluster
--- @param zb_rx st.zigbee.ZigbeeMessageRx the full message this report came in
function battery_defaults.battery_perc_attr_handler(driver, device, value, zb_rx)
  device:emit_event_for_endpoint(
      zb_rx.address_header.src_endpoint.value,
      capabilities.battery.battery(math.floor(value.value / 2.0 + 0.5))
  )
end

battery_defaults.zigbee_handlers = {
  global = {},
  cluster = {},
  attr = {
    [zcl_clusters.PowerConfiguration] = {
      [zcl_clusters.PowerConfiguration.attributes.BatteryVoltage] = battery_defaults.battery_volt_attr_handler,
      [zcl_clusters.PowerConfiguration.attributes.BatteryPercentageRemaining] = battery_defaults.battery_perc_attr_handler,
    }
  }
}

battery_defaults.default_voltage_configuration = default_voltage_configuration
battery_defaults.default_percentage_configuration = default_percentage_configuration

battery_defaults.capability_handlers = {}

battery_defaults.attribute_configurations = {
  default_percentage_configuration
}

return battery_defaults
