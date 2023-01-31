-- Copyright 2022 SmartThings
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

-- DO NOT EDIT: this code is automatically generated by ZCL Advanced Platform generator.

--- @field public OnOff st.matter.generated.zap_clusters.OnOff
--- @field public LevelControl st.matter.generated.zap_clusters.LevelControl
--- @field public Basic st.matter.generated.zap_clusters.Basic
--- @field public PowerSource st.matter.generated.zap_clusters.PowerSource
--- @field public Switch st.matter.generated.zap_clusters.Switch
--- @field public BooleanState st.matter.generated.zap_clusters.BooleanState
--- @field public ModeSelect st.matter.generated.zap_clusters.ModeSelect
--- @field public DoorLock st.matter.generated.zap_clusters.DoorLock
--- @field public WindowCovering st.matter.generated.zap_clusters.WindowCovering
--- @field public Thermostat st.matter.generated.zap_clusters.Thermostat
--- @field public FanControl st.matter.generated.zap_clusters.FanControl
--- @field public ColorControl st.matter.generated.zap_clusters.ColorControl
--- @field public IlluminanceMeasurement st.matter.generated.zap_clusters.IlluminanceMeasurement
--- @field public TemperatureMeasurement st.matter.generated.zap_clusters.TemperatureMeasurement
--- @field public FlowMeasurement st.matter.generated.zap_clusters.FlowMeasurement
--- @field public RelativeHumidityMeasurement st.matter.generated.zap_clusters.RelativeHumidityMeasurement
--- @field public OccupancySensing st.matter.generated.zap_clusters.OccupancySensing
--- @field public MediaPlayback st.matter.generated.zap_clusters.MediaPlayback
--- @field public KeypadInput st.matter.generated.zap_clusters.KeypadInput
local zap_clusters = {}

zap_clusters.on_off_id = 0x0006
zap_clusters.level_control_id = 0x0008
zap_clusters.basic_id = 0x0028
zap_clusters.power_source_id = 0x002F
zap_clusters.switch_id = 0x003B
zap_clusters.boolean_state_id = 0x0045
zap_clusters.mode_select_id = 0x0050
zap_clusters.door_lock_id = 0x0101
zap_clusters.window_covering_id = 0x0102
zap_clusters.thermostat_id = 0x0201
zap_clusters.fan_control_id = 0x0202
zap_clusters.color_control_id = 0x0300
zap_clusters.illuminance_measurement_id = 0x0400
zap_clusters.temperature_measurement_id = 0x0402
zap_clusters.flow_measurement_id = 0x0404
zap_clusters.relative_humidity_measurement_id = 0x0405
zap_clusters.occupancy_sensing_id = 0x0406
zap_clusters.media_playback_id = 0x0506
zap_clusters.keypad_input_id = 0x0509

zap_clusters.cluster_cache = {}

zap_clusters.id_to_name_map = {
  [zap_clusters.on_off_id] = "OnOff",
  [zap_clusters.level_control_id] = "LevelControl",
  [zap_clusters.basic_id] = "Basic",
  [zap_clusters.power_source_id] = "PowerSource",
  [zap_clusters.switch_id] = "Switch",
  [zap_clusters.boolean_state_id] = "BooleanState",
  [zap_clusters.mode_select_id] = "ModeSelect",
  [zap_clusters.door_lock_id] = "DoorLock",
  [zap_clusters.window_covering_id] = "WindowCovering",
  [zap_clusters.thermostat_id] = "Thermostat",
  [zap_clusters.fan_control_id] = "FanControl",
  [zap_clusters.color_control_id] = "ColorControl",
  [zap_clusters.illuminance_measurement_id] = "IlluminanceMeasurement",
  [zap_clusters.temperature_measurement_id] = "TemperatureMeasurement",
  [zap_clusters.flow_measurement_id] = "FlowMeasurement",
  [zap_clusters.relative_humidity_measurement_id] = "RelativeHumidityMeasurement",
  [zap_clusters.occupancy_sensing_id] = "OccupancySensing",
  [zap_clusters.media_playback_id] = "MediaPlayback",
  [zap_clusters.keypad_input_id] = "KeypadInput",
}

local zap_clusters_mt = {}
zap_clusters_mt.__cluster_cache = {}
zap_clusters_mt.__index = function(self, key)
  if zap_clusters_mt.__cluster_cache[key] == nil then
    local req_loq = string.format("st.matter.generated.zap_clusters.%s.init", key)
    zap_clusters_mt.__cluster_cache[key] = require(req_loq)
  end
  return zap_clusters_mt.__cluster_cache[key]
end
setmetatable(zap_clusters, zap_clusters_mt)

zap_clusters.get_cluster_from_id = function(id)
  local cluster_name = zap_clusters.id_to_name_map[id]
  if cluster_name ~= nil then
    return zap_clusters[cluster_name]
  end
  return nil
end

return zap_clusters

