local data_types = require "st.zigbee.data_types"
local utils = require "st.zigbee.utils"
local log = require "log"
local ZclStatus = require "st.zigbee.generated.types.ZclStatus"

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
-- Alarms command GetAlarmResponse
-----------------------------------------------------------

--- @class st.zigbee.zcl.clusters.Alarms.GetAlarmResponse
--- @alias GetAlarmResponse
---
--- @field public ID number 0x01 the ID of this command
--- @field public NAME string "GetAlarmResponse" the name of this command
--- @field public status st.zigbee.data_types.ZclStatus
--- @field public alarm_code st.zigbee.data_types.Enum8
--- @field public cluster_identifier st.zigbee.data_types.ClusterId
--- @field public time_stamp st.zigbee.data_types.Uint32
local GetAlarmResponse = {}
GetAlarmResponse.NAME = "GetAlarmResponse"
GetAlarmResponse.ID = 0x01
GetAlarmResponse.args_def = {
  {
    name = "status",
    optional = false,
    data_type = ZclStatus,
    is_complex = false,
    is_array = false,
  },
  {
    name = "alarm_code",
    optional = false,
    data_type = data_types.Enum8,
    is_complex = false,
    is_array = false,
    default = 0x00,
  },
  {
    name = "cluster_identifier",
    optional = false,
    data_type = data_types.ClusterId,
    is_complex = false,
    is_array = false,
  },
  {
    name = "time_stamp",
    optional = false,
    data_type = data_types.Uint32,
    is_complex = false,
    is_array = false,
    default = 0x00000000,
  },
}

function GetAlarmResponse:get_fields()
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

GetAlarmResponse.get_length = utils.length_from_fields
GetAlarmResponse._serialize = utils.serialize_from_fields
GetAlarmResponse.pretty_print = utils.print_from_fields

--- Deserialize this command
---
--- @param buf buf the bytes of the command body
--- @return GetAlarmResponse
function GetAlarmResponse.deserialize(buf)
  local out = {}
  for _, v in ipairs(GetAlarmResponse.args_def) do
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
      log.debug_with({ hub_logs = true }, "Missing command arg " .. v.name .. " for deserializing GetAlarmResponse")
    end
  end
  setmetatable(out, {__index = GetAlarmResponse})
  out:set_field_names()
  return out
end

function GetAlarmResponse:set_field_names()
  for _, v in ipairs(self.args_def) do
    if self[v.name] ~= nil then
      self[v.name].field_name = v.name
    end
  end
end

--- Build a version of this message as if it came from the device
---
--- @param device st.zigbee.Device the device to build the message from
--- @param status st.zigbee.data_types.ZclStatus
--- @param alarm_code st.zigbee.data_types.Enum8
--- @param cluster_identifier st.zigbee.data_types.ClusterId
--- @param time_stamp st.zigbee.data_types.Uint32
--- @return st.zigbee.ZigbeeMessageRx The full Zigbee message containing this command body
function GetAlarmResponse.build_test_rx(device, status, alarm_code, cluster_identifier, time_stamp)
  local out = {}
  local args = {status, alarm_code, cluster_identifier, time_stamp}
  for i,v in ipairs(GetAlarmResponse.args_def) do
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
  setmetatable(out, {__index = GetAlarmResponse})
  out:set_field_names()
  return GetAlarmResponse._cluster:build_test_rx_cluster_specific_command(device, out, "client")
end

--- Initialize the GetAlarmResponse command
---
--- @param self GetAlarmResponse the template class for this command
--- @param device st.zigbee.Device the device to build this message to
--- @param status st.zigbee.data_types.ZclStatus
--- @param alarm_code st.zigbee.data_types.Enum8
--- @param cluster_identifier st.zigbee.data_types.ClusterId
--- @param time_stamp st.zigbee.data_types.Uint32
--- @return st.zigbee.ZigbeeMessageTx the full command addressed to the device
function GetAlarmResponse:init(device, status, alarm_code, cluster_identifier, time_stamp)
  local out = {}
  local args = {status, alarm_code, cluster_identifier, time_stamp}
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
    __index = GetAlarmResponse,
    __tostring = GetAlarmResponse.pretty_print
  })
  out:set_field_names()
  return self._cluster:build_cluster_specific_command(device, out, "client")
end

function GetAlarmResponse:set_parent_cluster(cluster)
  self._cluster = cluster
  return self
end

setmetatable(GetAlarmResponse, {__call = GetAlarmResponse.init})

return GetAlarmResponse
