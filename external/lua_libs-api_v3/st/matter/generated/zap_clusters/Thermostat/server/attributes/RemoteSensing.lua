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

local cluster_base = require "st.matter.cluster_base"
local data_types = require "st.matter.data_types"
local TLVParser = require "st.matter.TLV.TLVParser"

--- @class st.matter.clusters.Thermostat.RemoteSensing
--- @alias RemoteSensing
---
--- @field public ID number 0x001A the ID of this attribute
--- @field public NAME string "RemoteSensing" the name of this attribute
--- @field public data_type st.matter.data_types.Uint8 the data type of this attribute

local RemoteSensing = {
  ID = 0x001A,
  NAME = "RemoteSensing",
  base_type = data_types.Uint8,
}
--- Create a Uint8 object of this attribute with any additional features provided for the attribute
--- This is also usable with the RemoteSensing(...) syntax
---
--- @vararg vararg the values needed to construct a Uint8
--- @return st.matter.data_types.Uint8
function RemoteSensing:new_value(...)
  local o = self.base_type(table.unpack({...}))
  
  return o
end

--- Constructs an st.matter.interaction_model.InteractionRequest to read
--- this attribute from a device
--- @param device st.matter.Device
--- @param endpoint_id number|nil
--- @return st.matter.interaction_model.InteractionRequest containing an Interaction Request
function RemoteSensing:read(device, endpoint_id)
  return cluster_base.read(
    device,
    endpoint_id,
    self._cluster.ID,
    self.ID,
    nil --event_id
  )
end

--- Constructs an st.matter.interaction_model.InteractionRequest to write
--- this attribute to a device
---
--- @param device st.matter.Device
--- @param endpoint_id number|nil
--- @param value st.matter.data_types.Uint8
--- @return st.matter.data_types.Uint8 the value to write
function RemoteSensing:write(device, endpoint_id, value)
  local data = data_types.validate_or_build_type(value, self.base_type)
  
  return cluster_base.write(
    device,
    endpoint_id,
    self._cluster.ID,
    self.ID,
    nil, --event_id
    data
  )
end

--- Reporting policy: RemoteSensing => true => mandatory

--- Sets up a Subscribe Interaction
---
--- @param device any
--- @param endpoint_id number|nil
--- @return any
function RemoteSensing:subscribe(device, endpoint_id)
  return cluster_base.subscribe(
    device,
    endpoint_id,
    self._cluster.ID,
    self.ID,
    nil --event_id
  )
end

function RemoteSensing:set_parent_cluster(cluster)
  self._cluster = cluster
  return self
end

--- Builds an RemoteSensing test attribute reponse for the driver integration testing framework
---
--- @param device st.matter.Device the device to build this message for
--- @param endpoint_id number|nil
--- @param value any
--- @param status string Interaction status associated with the path
--- @return st.matter.interaction_model.InteractionResponse of type REPORT_DATA
function RemoteSensing:build_test_report_data(
  device,
  endpoint_id,
  value,
  status
)
  local data = data_types.validate_or_build_type(value, self.base_type)
  
  return cluster_base.build_test_report_data(
    device,
    endpoint_id,
    self._cluster.ID,
    self.ID,
    data,
    status
  )
end

function RemoteSensing:deserialize(tlv_buf)
  local data = TLVParser.decode_tlv(tlv_buf)
  
  return data
end

setmetatable(RemoteSensing, {__call = RemoteSensing.new_value})
return RemoteSensing

