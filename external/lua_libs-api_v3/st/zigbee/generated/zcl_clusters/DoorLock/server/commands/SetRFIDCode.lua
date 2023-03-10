local data_types = require "st.zigbee.data_types"
local utils = require "st.zigbee.utils"
local log = require "log"
local DrlkRfidUserIdType = require "st.zigbee.generated.zcl_clusters.DoorLock.types.DrlkRfidUserId"
local DrlkUserTypeType = require "st.zigbee.generated.zcl_clusters.DoorLock.types.DrlkUserType"
local DrlkSettableUserStatusType = require "st.zigbee.generated.zcl_clusters.DoorLock.types.DrlkSettableUserStatus"

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
-- DoorLock command SetRFIDCode
-----------------------------------------------------------

--- @class st.zigbee.zcl.clusters.DoorLock.SetRFIDCode
--- @alias SetRFIDCode
---
--- @field public ID number 0x16 the ID of this command
--- @field public NAME string "SetRFIDCode" the name of this command
--- @field public user_id st.zigbee.zcl.clusters.DoorLock.types.DrlkRfidUserId
--- @field public user_status st.zigbee.zcl.clusters.DoorLock.types.DrlkSettableUserStatus
--- @field public user_type st.zigbee.zcl.clusters.DoorLock.types.DrlkUserType
--- @field public rfid_code st.zigbee.data_types.OctetString
local SetRFIDCode = {}
SetRFIDCode.NAME = "SetRFIDCode"
SetRFIDCode.ID = 0x16
SetRFIDCode.args_def = {
  {
    name = "user_id",
    optional = false,
    data_type = DrlkRfidUserIdType,
    is_complex = false,
    is_array = false,
    default = 0x0000,
  },
  {
    name = "user_status",
    optional = false,
    data_type = DrlkSettableUserStatusType,
    is_complex = false,
    is_array = false,
    default = 0x00,
  },
  {
    name = "user_type",
    optional = false,
    data_type = DrlkUserTypeType,
    is_complex = false,
    is_array = false,
    default = 0x00,
  },
  {
    name = "rfid_code",
    optional = false,
    data_type = data_types.OctetString,
    is_complex = false,
    is_array = false,
    default = "",
  },
}

function SetRFIDCode:get_fields()
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

SetRFIDCode.get_length = utils.length_from_fields
SetRFIDCode._serialize = utils.serialize_from_fields
SetRFIDCode.pretty_print = utils.print_from_fields

--- Deserialize this command
---
--- @param buf buf the bytes of the command body
--- @return SetRFIDCode
function SetRFIDCode.deserialize(buf)
  local out = {}
  for _, v in ipairs(SetRFIDCode.args_def) do
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
      log.debug_with({ hub_logs = true }, "Missing command arg " .. v.name .. " for deserializing SetRFIDCode")
    end
  end
  setmetatable(out, {__index = SetRFIDCode})
  out:set_field_names()
  return out
end

function SetRFIDCode:set_field_names()
  for _, v in ipairs(self.args_def) do
    if self[v.name] ~= nil then
      self[v.name].field_name = v.name
    end
  end
end

--- Build a version of this message as if it came from the device
---
--- @param device st.zigbee.Device the device to build the message from
--- @param user_id st.zigbee.zcl.clusters.DoorLock.types.DrlkRfidUserId
--- @param user_status st.zigbee.zcl.clusters.DoorLock.types.DrlkSettableUserStatus
--- @param user_type st.zigbee.zcl.clusters.DoorLock.types.DrlkUserType
--- @param rfid_code st.zigbee.data_types.OctetString
--- @return st.zigbee.ZigbeeMessageRx The full Zigbee message containing this command body
function SetRFIDCode.build_test_rx(device, user_id, user_status, user_type, rfid_code)
  local out = {}
  local args = {user_id, user_status, user_type, rfid_code}
  for i,v in ipairs(SetRFIDCode.args_def) do
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
  setmetatable(out, {__index = SetRFIDCode})
  out:set_field_names()
  return SetRFIDCode._cluster:build_test_rx_cluster_specific_command(device, out, "server")
end

--- Initialize the SetRFIDCode command
---
--- @param self SetRFIDCode the template class for this command
--- @param device st.zigbee.Device the device to build this message to
--- @param user_id st.zigbee.zcl.clusters.DoorLock.types.DrlkRfidUserId
--- @param user_status st.zigbee.zcl.clusters.DoorLock.types.DrlkSettableUserStatus
--- @param user_type st.zigbee.zcl.clusters.DoorLock.types.DrlkUserType
--- @param rfid_code st.zigbee.data_types.OctetString
--- @return st.zigbee.ZigbeeMessageTx the full command addressed to the device
function SetRFIDCode:init(device, user_id, user_status, user_type, rfid_code)
  local out = {}
  local args = {user_id, user_status, user_type, rfid_code}
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
    __index = SetRFIDCode,
    __tostring = SetRFIDCode.pretty_print
  })
  out:set_field_names()
  return self._cluster:build_cluster_specific_command(device, out, "server")
end

function SetRFIDCode:set_parent_cluster(cluster)
  self._cluster = cluster
  return self
end

setmetatable(SetRFIDCode, {__call = SetRFIDCode.init})

return SetRFIDCode
