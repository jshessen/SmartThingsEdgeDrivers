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
local capabilities = require "st.capabilities"

local default_handlers = {}

--- @class st.zigbee.defaults.AttributeConfiguration
--- @field public cluster ZigbeeCluster|number the cluster or cluster ID
--- @field public attribute ZigbeeClusterAttribute|number the attribute or attribute ID
--- @field public data_type st.zigbee.data_types.ZigbeeDataType the data type of the attribute
--- @field public minimum_interval number the minimum reporting interval
--- @field public maximum_interval number the maximum reporting interval
--- @field public reportable_change st.zigbee.data_types.ZigbeeDataType Only used for non-discrete data types, the change necessary to trigger a report
local AttributeConfiguration = {}

local default_handlers_file_map = {
  [capabilities.switch] = "switch_defaults",
  [capabilities.switchLevel] = "switchLevel_defaults",
  [capabilities.battery] = "battery_defaults",
  [capabilities.illuminanceMeasurement] = "illuminanceMeasurement_defaults",
  [capabilities.occupancySensor] = "occupancySensor_defaults",
  [capabilities.temperatureMeasurement] = "temperatureMeasurement_defaults",
  [capabilities.relativeHumidityMeasurement] = "relativeHumidityMeasurement_defaults",
  [capabilities.colorTemperature] = "colorTemperature_defaults",
  [capabilities.colorControl] = "colorControl_defaults",
  [capabilities.thermostatHeatingSetpoint] = "thermostatHeatingSetpoint_defaults",
  [capabilities.thermostatCoolingSetpoint] = "thermostatCoolingSetpoint_defaults",
  [capabilities.lock] = "lock_defaults",
  [capabilities.powerMeter] = "powerMeter_defaults",
  [capabilities.energyMeter] = "energyMeter_defaults",
  [capabilities.contactSensor] = "contactSensor_defaults",
  [capabilities.waterSensor] = "waterSensor_defaults",
  [capabilities.motionSensor] = "motionSensor_defaults",
  [capabilities.smokeDetector] = "smokeDetector_defaults",
  [capabilities.valve] = "valve_defaults",
  [capabilities.powerSource] = "powerSource_defaults",
  [capabilities.windowShade] = "windowShade_defaults",
  [capabilities.windowShadePreset] = "windowShadePreset_defaults",
  [capabilities.windowShadeLevel] = "windowShadeLevel_defaults",
  [capabilities.soundSensor] = "soundSensor_defaults",
  [capabilities.carbonMonoxideDetector] = "carbonMonoxideDetector_defaults"
}

function default_handlers.register_for_default_handlers(driver, capabilities)
  driver.zigbee_handlers = driver.zigbee_handlers or {}
  driver.zigbee_handlers.attr = driver.zigbee_handlers.attr or {}
  driver.zigbee_handlers.global = driver.zigbee_handlers.global or {}
  driver.zigbee_handlers.cluster = driver.zigbee_handlers.cluster or {}
  driver.cluster_configurations = driver.cluster_configurations or {}
  driver.capability_handlers = driver.capability_handlers or {}

  local existing_comps = {}
  for _, cap in pairs(driver.cluster_configurations) do
    for _, conf in ipairs(cap) do
      existing_comps[conf.cluster] = existing_comps[conf.cluster] or {}
      existing_comps[conf.cluster][conf.attribute] = true
    end
  end

  for _, cap in ipairs(capabilities) do
    local default_file = default_handlers_file_map[cap]
    if default_file ~= nil then
      local require_path = "st.zigbee.defaults." .. default_file
      local entry = require(require_path)
      if entry ~= nil then
        -- build attr handlers
        for cluster, attrs in pairs(((entry.zigbee_handlers or {})["attr"] or {})) do
          for attr, handler in pairs(attrs) do
            local cid = (type(cluster) == "table") and cluster.ID or cluster
            local aid = (type(attr) == "table") and attr.ID or attr
            driver.zigbee_handlers.attr[cid] = driver.zigbee_handlers.attr[cid] or {}
            driver.zigbee_handlers.attr[cid][aid] = driver.zigbee_handlers.attr[cid][aid] or handler
          end
        end

        -- build global handlers
        for cluster, commands in pairs(((entry.zigbee_handlers or {})["global"] or {})) do
          for cmd, handler in pairs(commands) do
            local cid = (type(cluster) == "table") and cluster.ID or cluster
            local cmdid = (type(cmd) == "table") and cmd.ID or cmd
            driver.zigbee_handlers.global[cid] = driver.zigbee_handlers.global[cid] or {}
            driver.zigbee_handlers.global[cid][cmdid] = driver.zigbee_handlers.global[cid][cmdid] or handler
          end
        end

        -- build cluster handlers
        for cluster, commands in pairs(((entry.zigbee_handlers or {})["cluster"] or {})) do
          for cmd, handler in pairs(commands) do
            local cid = (type(cluster) == "table") and cluster.ID or cluster
            local cmdid = (type(cmd) == "table") and cmd.ID or cmd
            driver.zigbee_handlers.cluster[cid] = driver.zigbee_handlers.cluster[cid] or {}
            driver.zigbee_handlers.cluster[cid][cmdid] = driver.zigbee_handlers.cluster[cid][cmdid] or handler
          end
        end

        -- build attr configs
        for _, conf in ipairs(entry.attribute_configurations or {}) do
          local cluster = (type(conf.cluster) == "table") and conf.cluster.ID or conf.cluster
          local attribute = (type(conf.attribute) == "table") and conf.attribute.ID or conf.attribute
          if conf.data_type == nil then
            print(cap.ID)
          end
          local data_type = conf.data_type or conf.attribute.base_type

          local config_conf = {
            cluster = cluster,
            attribute = attribute,
            minimum_interval = conf.minimum_interval,
            maximum_interval = conf.maximum_interval,
            data_type = data_type
          }
          if conf.reportable_change then
            config_conf.reportable_change = data_type(conf.reportable_change)
          end

          -- Only add a cluster configuration if that attribute doesn't already have a configuration
          existing_comps[cluster] = existing_comps[cluster] or {}
          if not existing_comps[cluster][attribute] then
            driver.cluster_configurations[cap.ID] = driver.cluster_configurations[cap.ID] or {}
            driver.cluster_configurations[cap.ID][#driver.cluster_configurations[cap.ID] + 1] = config_conf
            existing_comps[cluster][attribute] = true
          end
        end

        -- build command handlers
        for command, handler in pairs(entry.capability_handlers or {}) do
          driver.capability_handlers[cap.ID] = driver.capability_handlers[cap.ID] or {}
          driver.capability_handlers[cap.ID][command] = driver.capability_handlers[cap.ID][command] or handler
        end
      end
    end
  end
end

return default_handlers
