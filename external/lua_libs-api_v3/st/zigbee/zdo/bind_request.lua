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
local data_types = require "st.zigbee.data_types"
local utils = require "st.zigbee.utils"

--- @module st.zigbee.zdo.bind_request
local bind_request = {}

bind_request.BIND_REQUEST_CLUSTER_ID = 0x0021
bind_request.ADDRESS_MODE_16_BIT = 0x01
bind_request.ADDRESS_MODE_64_BIT = 0x03

--- @class st.zigbee.zdo.BindRequest
---
--- @field public NAME string "BindRequest"
--- @field public ID number 0x0021 The cluster ID of zdo Bind Request command
--- @field public src_address st.zigbee.data_types.Uint16 the source address to bind to
--- @field public src_endpoint st.zigbee.data_types.Uint8 the source endpoint to bind to
--- @field public cluster_id st.zigbee.data_types.ClusterId the cluster to bind
--- @field public dest_addr_mode st.zigbee.data_types.Uint8 a field describing which addressing method will be used for the destination address
--- @field public dest_address st.zigbee.data_types.Uint16 or IeeeAddress this will be Uin16 if dest_addr_mode is 0x01, or IeeeAddress if it is 0x03
--- @field public dest_endpoint st.zigbee.data_types.Uint8 This is only present if dest_addr_mode is 0x03 for long addresses
local BindRequest = {
  ID = bind_request.BIND_REQUEST_CLUSTER_ID,
  NAME = "BindRequest",
}
BindRequest.__index = BindRequest
bind_request.BindRequest = BindRequest

--- Parse a BindRequest from a byte string
--- @param buf Reader the buf to parse the record from
--- @return st.zigbee.zdo.BindRequest the parsed attribute record
function BindRequest.deserialize(buf)
  local self = {}
  setmetatable(self, BindRequest)

  local fields = {
    { name = "src_address", type = data_types.IeeeAddress },
    { name = "src_endpoint", type = data_types.Uint8 },
    { name = "cluster_id", type = data_types.ClusterId },
    { name = "dest_addr_mode", type = data_types.Uint8 },
  }
  utils.deserialize_field_list(self, fields, buf)

  if self.dest_addr_mode.value == bind_request.ADDRESS_MODE_16_BIT then
    self.dest_address = data_types.Uint16.deserialize(buf)
  else
    self.dest_address = data_types.IeeeAddress.deserialize(buf)
    self.dest_endpoint = data_types.Uint8.deserialize(buf)
  end
  return self
end

--- A helper function used by common code to get all the component pieces of this message frame
---@return table An array formatted table with each component field in the order their bytes should be serialized
function BindRequest:get_fields()
  local out = {}
  out[#out + 1] = self.src_address
  out[#out + 1] = self.src_endpoint
  out[#out + 1] = self.cluster_id
  out[#out + 1] = self.dest_addr_mode
  out[#out + 1] = self.dest_address
  if self.dest_addr_mode.value == bind_request.ADDRESS_MODE_64_BIT then
    out[#out + 1] = self.dest_endpoint
  end
  return out
end

--- @function BindRequest:get_length
--- @return number the length of this BindRequest in bytes
BindRequest.get_length = utils.length_from_fields

--- @function BindRequest:_serialize
--- @return string this BindRequest serialized
BindRequest._serialize = utils.serialize_from_fields

--- @function BindRequest:pretty_print
--- @return string this BindRequest as a human readable string
BindRequest.pretty_print = utils.print_from_fields
BindRequest.__tostring = BindRequest.pretty_print

--- Build a BindRequest from its individual components
--- @param orig table UNUSED This is the class table when creating using class(...) syntax
--- @param src_address st.zigbee.data_types.Uint16 the source address to bind to
--- @param src_endpoint st.zigbee.data_types.Uint8 the source endpoint to bind to
--- @param cluster_id st.zigbee.data_types.ClusterId the cluster to bind
--- @param dest_addr_mode st.zigbee.data_types.Uint8 number a field describing which addressing method will be used for the destination address
--- @param dest_address st.zigbee.data_types.Uint16 or IeeeAddress this will be Uin16 if dest_addr_mode is 0x01, or IeeeAddress if it is 0x03
--- @param dest_endpoint st.zigbee.data_types.Uint8 optional only necessary if dest_addr_mode is 0x03 for long addresses
--- @return st.zigbee.zdo.BindRequest the constructed BindRequest
function BindRequest.from_values(orig, src_address, src_endpoint, cluster_id, dest_addr_mode, dest_address, dest_endpoint)
  local out = {}
  if src_address == nil or src_endpoint == nil or cluster_id == nil or dest_addr_mode == nil or dest_address == nil then
    error("Missing necessary values for bind request", 2)
  end

  out.src_address = data_types.validate_or_build_type(src_address, data_types.IeeeAddress, "src_address")
  out.src_endpoint = data_types.validate_or_build_type(src_endpoint, data_types.Uint8, "src_endpoint")
  out.cluster_id = data_types.validate_or_build_type(cluster_id, data_types.ClusterId, "cluster")
  out.dest_addr_mode = data_types.validate_or_build_type(dest_addr_mode, data_types.Uint8, "dest_addr_mode")
  if (out.dest_addr_mode.value == bind_request.ADDRESS_MODE_16_BIT) then
    out.dest_address = data_types.validate_or_build_type(dest_address, data_types.Uint16, "dest_address")
  elseif out.dest_addr_mode.value == bind_request.ADDRESS_MODE_64_BIT then
    out.dest_address = data_types.validate_or_build_type(dest_address, data_types.IeeeAddress, "dest_address")
    out.dest_endpoint = data_types.validate_or_build_type(dest_endpoint, data_types.Uint8, "dest_endpoint")
  else
    error(string.format("Unrecognized destination address mode: %d", out.dest_addr_mode.value), 2)
  end

  setmetatable(out, BindRequest)
  return out
end

setmetatable(bind_request.BindRequest, { __call = bind_request.BindRequest.from_values })

return bind_request
