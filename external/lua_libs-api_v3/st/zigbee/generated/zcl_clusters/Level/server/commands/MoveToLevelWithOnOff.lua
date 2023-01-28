local data_types = require "st.zigbee.data_types"
local utils = require "st.zigbee.utils"
local log = require "log"
local LevelOptionsType = require "st.zigbee.generated.zcl_clusters.Level.types.LevelOptions"

-- Copyright 2023 SmartThings
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

-- DO NOT EDIT: this code is automatically generated by tools/zigbee-lib_generator/generate_clusters_from_xml.py
-- Script version: b'b65edec6f2fbd53d4aeed6ab08ac6f3b5ae73520'
-- ZCL XML version: 7.2

-----------------------------------------------------------
-- Level command MoveToLevelWithOnOff
-----------------------------------------------------------

--- @class st.zigbee.zcl.clusters.Level.MoveToLevelWithOnOff
--- @alias MoveToLevelWithOnOff
---
--- @field public ID number 0x04 the ID of this command
--- @field public NAME string "MoveToLevelWithOnOff" the name of this command
--- @field public level st.zigbee.data_types.Uint8
--- @field public transition_time st.zigbee.data_types.Uint16
--- @field public options_mask st.zigbee.zcl.clusters.Level.types.LevelOptions
--- @field public options_override st.zigbee.zcl.clusters.Level.types.LevelOptions
local MoveToLevelWithOnOff = {}
MoveToLevelWithOnOff.NAME = "MoveToLevelWithOnOff"
MoveToLevelWithOnOff.ID = 0x04
MoveToLevelWithOnOff.args_def = {
  {
    name = "level",
    optional = false,
    data_type = data_types.Uint8,
    is_complex = false,
    is_array = false,
    default = 0x00,
  },
  {
    name = "transition_time",
    optional = false,
    data_type = data_types.Uint16,
    is_complex = false,
    is_array = false,
    default = 0x0000,
  },
  {
    name = "options_mask",
    optional = false,
    data_type = LevelOptionsType,
    is_complex = false,
    is_array = false,
    default = 0x00,
  },
  {
    name = "options_override",
    optional = false,
    data_type = LevelOptionsType,
    is_complex = false,
    is_array = false,
    default = 0x00,
  },
}

function MoveToLevelWithOnOff:get_fields()
  local fields = {}
  for _, v in ipairs(self.args_def) do
    if v.is_array then
      if v.array_length_size ~= 0 then
        fields[#fields + 1] = self[v.name .. "_length"]
      end
      if self[v.name .. "_list"] ~= nil then
        for _, entry in ipairs(self[v.name .. "_list"]) do
          fields[#fields + 1] = entry
        end
      end
    else
      if self[v.name] ~= nil then
        fields[#fields + 1] = self[v.name]
      end
    end
  end
  return fields
end

MoveToLevelWithOnOff.get_length = utils.length_from_fields
MoveToLevelWithOnOff._serialize = utils.serialize_from_fields
MoveToLevelWithOnOff.pretty_print = utils.print_from_fields

--- Deserialize this command
---
--- @param buf buf the bytes of the command body
--- @return MoveToLevelWithOnOff
function MoveToLevelWithOnOff.deserialize(buf)
  local out = {}
  for _, v in ipairs(MoveToLevelWithOnOff.args_def) do
    if buf:remain() > 0 then
      if v.is_array then
        if v.array_length_size ~= 0 then
          local entry_name = v.name .. "_length"
          local len = v.array_length_size or 1
          -- Start a 1 byte lenght at Uint8 and increment from there
          local len_data_type_id = 0x1F + len
          out[entry_name] = data_types.parse_data_type(len_data_type_id, buf, entry_name)
        end
        local entry_name = v.name .. "_list"
        out[entry_name] = {}
        while buf:remain() > 0 do
          out[entry_name][#out[entry_name] + 1] = v.data_type.deserialize(buf)
        end
      else
        out[v.name] = v.data_type.deserialize(buf)
      end
    elseif not v.optional then
      log.debug_with({ hub_logs = true }, "Missing command arg " .. v.name .. " for deserializing MoveToLevelWithOnOff")
    end
  end
  setmetatable(out, {__index = MoveToLevelWithOnOff})
  out:set_field_names()
  return out
end

function MoveToLevelWithOnOff:set_field_names()
  for _, v in ipairs(self.args_def) do
    if self[v.name] ~= nil then
      self[v.name].field_name = v.name
    end
  end
end

--- Build a version of this message as if it came from the device
---
--- @param device st.zigbee.Device the device to build the message from
--- @param level st.zigbee.data_types.Uint8
--- @param transition_time st.zigbee.data_types.Uint16
--- @param options_mask st.zigbee.zcl.clusters.Level.types.LevelOptions
--- @param options_override st.zigbee.zcl.clusters.Level.types.LevelOptions
--- @return st.zigbee.ZigbeeMessageRx The full Zigbee message containing this command body
function MoveToLevelWithOnOff.build_test_rx(device, level, transition_time, options_mask, options_override)
  local out = {}
  local args = {level, transition_time, options_mask, options_override}
  for i,v in ipairs(MoveToLevelWithOnOff.args_def) do
    if v.optional and args[i] == nil then
      out[v.name] = nil
    elseif not v.optional and args[i] == nil then
      out[v.name] = data_types.validate_or_build_type(v.default, v.data_type, v.name)   
    elseif v.is_array then
      local validated_list = {}
      for j, entry in ipairs(args[i]) do
        validated_list[j] = data_types.validate_or_build_type(entry, v.data_type, v.name .. tostring(j))
      end
      if v.array_length_size ~= 0 then
        local len_name =  v.name .. "_length"
        local len = v.array_length_size or 1
        -- Start a 1 byte lenght at Uint8 and increment from there
        local len_data_type = data_types.get_data_type_by_id(0x1F + len)
        out[len_name] = data_types.validate_or_build_type(#validated_list, len_data_type, len_name)
      end
      out[v.name .. "_list"] = validated_list
    else
      out[v.name] = data_types.validate_or_build_type(args[i], v.data_type, v.name)
    end
  end
  setmetatable(out, {__index = MoveToLevelWithOnOff})
  out:set_field_names()
  return MoveToLevelWithOnOff._cluster:build_test_rx_cluster_specific_command(device, out, "server")
end

--- Initialize the MoveToLevelWithOnOff command
---
--- @param self MoveToLevelWithOnOff the template class for this command
--- @param device st.zigbee.Device the device to build this message to
--- @param level st.zigbee.data_types.Uint8
--- @param transition_time st.zigbee.data_types.Uint16
--- @param options_mask st.zigbee.zcl.clusters.Level.types.LevelOptions
--- @param options_override st.zigbee.zcl.clusters.Level.types.LevelOptions
--- @return st.zigbee.ZigbeeMessageTx the full command addressed to the device
function MoveToLevelWithOnOff:init(device, level, transition_time, options_mask, options_override)
  local out = {}
  local args = {level, transition_time, options_mask, options_override}
  if #args > #self.args_def then
    error(self.NAME .. " received too many arguments")
  end
  for i,v in ipairs(self.args_def) do
    if v.optional and args[i] == nil then
      out[v.name] = nil
    elseif not v.optional and args[i] == nil then
      out[v.name] = data_types.validate_or_build_type(v.default, v.data_type, v.name)   
    elseif v.is_array then
      local validated_list = {}
      for j, entry in ipairs(args[i]) do
        validated_list[j] = data_types.validate_or_build_type(entry, v.data_type, v.name .. tostring(j))
      end
      if v.array_length_size ~= 0 then
        local len_name =  v.name .. "_length"
        local len = v.array_length_size or 1
        -- Start a 1 byte lenght at Uint8 and increment from there
        local len_data_type = data_types.get_data_type_by_id(0x1F + len)
        out[len_name] = data_types.validate_or_build_type(#validated_list, len_data_type, len_name)
      end
      out[v.name .. "_list"] = validated_list
    else
      out[v.name] = data_types.validate_or_build_type(args[i], v.data_type, v.name)
    end
  end
  setmetatable(out, {
    __index = MoveToLevelWithOnOff,
    __tostring = MoveToLevelWithOnOff.pretty_print
  })
  out:set_field_names()
  return self._cluster:build_cluster_specific_command(device, out, "server")
end

function MoveToLevelWithOnOff:set_parent_cluster(cluster)
  self._cluster = cluster
  return self
end

setmetatable(MoveToLevelWithOnOff, {__call = MoveToLevelWithOnOff.init})

return MoveToLevelWithOnOff
