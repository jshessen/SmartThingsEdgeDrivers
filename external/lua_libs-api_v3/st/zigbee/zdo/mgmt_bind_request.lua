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

--- @module st.zigbee.zdo.mgmt_bind_request
local binding_table_request = {}

binding_table_request.BINDING_TABLE_REQUEST_CLUSTER_ID = 0x0033
binding_table_request.ADDRESS_MODE_16_BIT = 0x01
binding_table_request.ADDRESS_MODE_64_BIT = 0x03

--- @class st.zigbee.zdo.MgmtBindRequest
---
--- @field public NAME string "MgmtBindRequest"
--- @field public ID number 0x0033 The cluster ID of ZDO Mgmt Bind Request command
--- @field public start_index st.zigbee.data_types.Uint8 the start index of the table to retrieve
local MgmtBindRequest = {
  ID = binding_table_request.BINDING_TABLE_REQUEST_CLUSTER_ID,
  NAME = "MgmtBindRequest",
}
MgmtBindRequest.__index = MgmtBindRequest
binding_table_request.MgmtBindRequest= MgmtBindRequest

--- Parse a BindingTableRequest from a byte string
--- @param buf Reader the buf to parse the record from
--- @return st.zigbee.zdo.MgmtBindRequest the parsed mgmt bind request
function MgmtBindRequest.deserialize(buf)
  local self = {}
  setmetatable(self, MgmtBindRequest)
  self.start_index = data_types.Uint8.deserialize(buf)
  return self
end

--- A helper function used by common code to get all the component pieces of this message frame
---@return table An array formatted table with each component field in the order their bytes should be serialized
function MgmtBindRequest:get_fields()
  local out = {}
  out[#out + 1] = self.start_index
  return out
end

--- @function MgmtBindRequest:get_length
--- @return number the length of this BindRequest in bytes
MgmtBindRequest.get_length = utils.length_from_fields

--- @function MgmtBindRequest:_serialize
--- @return string this BindRequest serialized
MgmtBindRequest._serialize = utils.serialize_from_fields

--- @function MgmtBindRequest:pretty_print
--- @return string this BindRequest as a human readable string
MgmtBindRequest.pretty_print = utils.print_from_fields
MgmtBindRequest.__tostring = MgmtBindRequest.pretty_print

--- Build a MgmtBindRequest from its individual components
--- @param orig table UNUSED This is the class table when creating using class(...) syntax
--- @param start_index st.zigbee.data_types.Uint8|number the start index to request the table at
--- @return st.zigbee.zdo.MgmtBindRequest the constructed BindingTableRequest
function MgmtBindRequest.from_values(orig, start_index)
  local out = {}
  out.start_index = data_types.validate_or_build_type(start_index, data_types.Uint8, "start_index")
  setmetatable(out, MgmtBindRequest)
  return out
end

setmetatable(binding_table_request.MgmtBindRequest, { __call = binding_table_request.MgmtBindRequest.from_values })

return binding_table_request
