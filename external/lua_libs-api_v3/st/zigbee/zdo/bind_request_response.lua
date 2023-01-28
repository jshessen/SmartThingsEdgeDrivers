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

--- @module st.zigbee.zdo.bind_request_response
local bind_request_response = {}

bind_request_response.BIND_REQUEST_RESPONSE_CLUSTER_ID = 0x8021

--- @class st.zigbee.zdo.BindRequestResponse
---
--- @field public NAME string "BindRequestResponse"
--- @field public ID number 0x8021 The cluster ID of zdo Bind Request Response command
--- @field public status st.zigbee.zcl.types.ZclStatus the status of bind request
local BindRequestResponse = {
  ID = bind_request_response.BIND_REQUEST_RESPONSE_CLUSTER_ID,
  NAME = "BindRequestResponse",
}
BindRequestResponse.__index = BindRequestResponse
bind_request_response.BindRequestResponse = BindRequestResponse

--- Parse a BindRequestResponse from a byte string
--- @param buf Reader the buf to parse the record from
--- @return st.zigbee.zdo.BindRequestResponse the parsed attribute record
function BindRequestResponse.deserialize(buf)
  local self = {}
  setmetatable(self, BindRequestResponse)
  self.status = data_types.Uint8.deserialize(buf)
  self.status.field_name = "status"
  return self
end

--- A helper function used by common code to get all the component pieces of this message frame
---@return table An array formatted table with each component field in the order their bytes should be serialized
function BindRequestResponse:get_fields()
  return { self.status }
end

--- @function BindRequestResponse:get_length
--- @return number the length of this BindRequestResponse in bytes
BindRequestResponse.get_length = utils.length_from_fields

--- @function BindRequestResponse:_serialize
--- @return string this BindRequestResponse serialized
BindRequestResponse._serialize = utils.serialize_from_fields

--- @function BindRequestResponse:pretty_print
--- @return string this BindRequestResponse as a human readable string
BindRequestResponse.pretty_print = utils.print_from_fields
BindRequestResponse.__tostring = BindRequestResponse.pretty_print

--- Build a BindRequestResponse from its individual components
--- @param orig table UNUSED This is the class table when creating using class(...) syntax
--- @param status Status the status of the bind request response
--- @return st.zigbee.zdo.BindRequestResponse the constructed BindRequestResponse
function BindRequestResponse.from_values(orig, status)
  local out = {}
  out.status = data_types.validate_or_build_type(status, data_types.Uint8, "status")
  setmetatable(out, BindRequestResponse)
  return out
end

setmetatable(bind_request_response.BindRequestResponse, { __call = bind_request_response.BindRequestResponse.from_values })

return bind_request_response
