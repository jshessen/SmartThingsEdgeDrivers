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

--- @class st.matter.clusters.PowerSource.WiredCurrentType
--- @alias WiredCurrentType
---
--- @field public ID number 0x0005 the ID of this attribute
--- @field public NAME string "WiredCurrentType" the name of this attribute
--- @field public data_type st.matter.data_types.Uint8 the data type of this attribute
--- @field public AC number 0
--- @field public DC number 1

local WiredCurrentType = {
  ID = 0x0005,
  NAME = "WiredCurrentType",
  base_type = data_types.Uint8,
}
WiredCurrentType.AC = 0x00
WiredCurrentType.DC = 0x01

WiredCurrentType.enum_fields = {
  [WiredCurrentType.AC] = "AC",
  [WiredCurrentType.DC] = "DC",
}

--- Add additional functionality to the base type object
---
--- @param base_type_obj st.matter.data_types.Uint8 the base data type object to add functionality to
function WiredCurrentType:augment_type(base_type_obj)
  base_type_obj.field_name = self.NAME
  base_type_obj.pretty_print = self.pretty_print
end

function WiredCurrentType.pretty_print(value_obj)
  return string.format("%s.%s", value_obj.field_name or value_obj.NAME, WiredCurrentType.enum_fields[value_obj.value])
end
--- Create a Uint8 object of this attribute with any additional features provided for the attribute
--- This is also usable with the WiredCurrentType(...) syntax
---
--- @vararg vararg the values needed to construct a Uint8
--- @return st.matter.data_types.Uint8
function WiredCurrentType:new_value(...)
  local o = self.base_type(table.unpack({...}))
  self:augment_type(o)
  return o
end

--- Constructs an st.matter.interaction_model.InteractionRequest to read
--- this attribute from a device
--- @param device st.matter.Device
--- @param endpoint_id number|nil
--- @return st.matter.interaction_model.InteractionRequest containing an Interaction Request
function WiredCurrentType:read(device, endpoint_id)
  return cluster_base.read(
    device,
    endpoint_id,
    self._cluster.ID,
    self.ID,
    nil --event_id
  )
end


--- Reporting policy: WiredCurrentType => true => mandatory

--- Sets up a Subscribe Interaction
---
--- @param device any
--- @param endpoint_id number|nil
--- @return any
function WiredCurrentType:subscribe(device, endpoint_id)
  return cluster_base.subscribe(
    device,
    endpoint_id,
    self._cluster.ID,
    self.ID,
    nil --event_id
  )
end

function WiredCurrentType:set_parent_cluster(cluster)
  self._cluster = cluster
  return self
end

--- Builds an WiredCurrentType test attribute reponse for the driver integration testing framework
---
--- @param device st.matter.Device the device to build this message for
--- @param endpoint_id number|nil
--- @param value any
--- @param status string Interaction status associated with the path
--- @return st.matter.interaction_model.InteractionResponse of type REPORT_DATA
function WiredCurrentType:build_test_report_data(
  device,
  endpoint_id,
  value,
  status
)
  local data = data_types.validate_or_build_type(value, self.base_type)
  self:augment_type(data)
  return cluster_base.build_test_report_data(
    device,
    endpoint_id,
    self._cluster.ID,
    self.ID,
    data,
    status
  )
end

function WiredCurrentType:deserialize(tlv_buf)
  local data = TLVParser.decode_tlv(tlv_buf)
  self:augment_type(data)
  return data
end

setmetatable(WiredCurrentType, {__call = WiredCurrentType.new_value})
return WiredCurrentType

