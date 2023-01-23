local data_types = require "st.zigbee.data_types"
local utils = require "st.zigbee.utils"
local log = require "log"
local CcColorLoopDirectionType = require "st.zigbee.generated.zcl_clusters.ColorControl.types.CcColorLoopDirection"
local ActionType = require "st.zigbee.generated.zcl_clusters.ColorControl.types.Action"
local CcColorOptionsType = require "st.zigbee.generated.zcl_clusters.ColorControl.types.CcColorOptions"
local UpdateFlagsType = require "st.zigbee.generated.zcl_clusters.ColorControl.types.UpdateFlags"

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
-- ColorControl command ColorLoopSet
-----------------------------------------------------------

--- @class st.zigbee.zcl.clusters.ColorControl.ColorLoopSet
--- @alias ColorLoopSet
---
--- @field public ID number 0x44 the ID of this command
--- @field public NAME string "ColorLoopSet" the name of this command
--- @field public update_flags st.zigbee.zcl.clusters.ColorControl.types.UpdateFlags
--- @field public action st.zigbee.zcl.clusters.ColorControl.types.Action
--- @field public direction st.zigbee.zcl.clusters.ColorControl.types.CcColorLoopDirection
--- @field public time st.zigbee.data_types.Uint16
--- @field public start_hue st.zigbee.data_types.Uint16
--- @field public options_mask st.zigbee.zcl.clusters.ColorControl.types.CcColorOptions
--- @field public options_override st.zigbee.zcl.clusters.ColorControl.types.CcColorOptions
local ColorLoopSet = {}
ColorLoopSet.NAME = "ColorLoopSet"
ColorLoopSet.ID = 0x44
ColorLoopSet.args_def = {
  {
    name = "update_flags",
    optional = false,
    data_type = UpdateFlagsType,
    is_complex = false,
    is_array = false,
  },
  {
    name = "action",
    optional = false,
    data_type = ActionType,
    is_complex = false,
    is_array = false,
  },
  {
    name = "direction",
    optional = false,
    data_type = CcColorLoopDirectionType,
    is_complex = false,
    is_array = false,
    default = 0x00,
  },
  {
    name = "time",
    optional = false,
    data_type = data_types.Uint16,
    is_complex = false,
    is_array = false,
    default = 0x0000,
  },
  {
    name = "start_hue",
    optional = false,
    data_type = data_types.Uint16,
    is_complex = false,
    is_array = false,
    default = 0x0000,
  },
  {
    name = "options_mask",
    optional = false,
    data_type = CcColorOptionsType,
    is_complex = false,
    is_array = false,
    default = 0x00,
  },
  {
    name = "options_override",
    optional = false,
    data_type = CcColorOptionsType,
    is_complex = false,
    is_array = false,
    default = 0x00,
  },
}

function ColorLoopSet:get_fields()
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

ColorLoopSet.get_length = utils.length_from_fields
ColorLoopSet._serialize = utils.serialize_from_fields
ColorLoopSet.pretty_print = utils.print_from_fields

--- Deserialize this command
---
--- @param buf buf the bytes of the command body
--- @return ColorLoopSet
function ColorLoopSet.deserialize(buf)
  local out = {}
  for _, v in ipairs(ColorLoopSet.args_def) do
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
      log.debug_with({ hub_logs = true }, "Missing command arg " .. v.name .. " for deserializing ColorLoopSet")
    end
  end
  setmetatable(out, {__index = ColorLoopSet})
  out:set_field_names()
  return out
end

function ColorLoopSet:set_field_names()
  for _, v in ipairs(self.args_def) do
    if self[v.name] ~= nil then
      self[v.name].field_name = v.name
    end
  end
end

--- Build a version of this message as if it came from the device
---
--- @param device st.zigbee.Device the device to build the message from
--- @param update_flags st.zigbee.zcl.clusters.ColorControl.types.UpdateFlags
--- @param action st.zigbee.zcl.clusters.ColorControl.types.Action
--- @param direction st.zigbee.zcl.clusters.ColorControl.types.CcColorLoopDirection
--- @param time st.zigbee.data_types.Uint16
--- @param start_hue st.zigbee.data_types.Uint16
--- @param options_mask st.zigbee.zcl.clusters.ColorControl.types.CcColorOptions
--- @param options_override st.zigbee.zcl.clusters.ColorControl.types.CcColorOptions
--- @return st.zigbee.ZigbeeMessageRx The full Zigbee message containing this command body
function ColorLoopSet.build_test_rx(device, update_flags, action, direction, time, start_hue, options_mask, options_override)
  local out = {}
  local args = {update_flags, action, direction, time, start_hue, options_mask, options_override}
  for i,v in ipairs(ColorLoopSet.args_def) do
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
  setmetatable(out, {__index = ColorLoopSet})
  out:set_field_names()
  return ColorLoopSet._cluster:build_test_rx_cluster_specific_command(device, out, "server")
end

--- Initialize the ColorLoopSet command
---
--- @param self ColorLoopSet the template class for this command
--- @param device st.zigbee.Device the device to build this message to
--- @param update_flags st.zigbee.zcl.clusters.ColorControl.types.UpdateFlags
--- @param action st.zigbee.zcl.clusters.ColorControl.types.Action
--- @param direction st.zigbee.zcl.clusters.ColorControl.types.CcColorLoopDirection
--- @param time st.zigbee.data_types.Uint16
--- @param start_hue st.zigbee.data_types.Uint16
--- @param options_mask st.zigbee.zcl.clusters.ColorControl.types.CcColorOptions
--- @param options_override st.zigbee.zcl.clusters.ColorControl.types.CcColorOptions
--- @return st.zigbee.ZigbeeMessageTx the full command addressed to the device
function ColorLoopSet:init(device, update_flags, action, direction, time, start_hue, options_mask, options_override)
  local out = {}
  local args = {update_flags, action, direction, time, start_hue, options_mask, options_override}
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
    __index = ColorLoopSet,
    __tostring = ColorLoopSet.pretty_print
  })
  out:set_field_names()
  return self._cluster:build_cluster_specific_command(device, out, "server")
end

function ColorLoopSet:set_parent_cluster(cluster)
  self._cluster = cluster
  return self
end

setmetatable(ColorLoopSet, {__call = ColorLoopSet.init})

return ColorLoopSet
