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
--- @type st.zigbee.data_types
local data_types = require "st.zigbee.data_types"
local utils = require "st.zigbee.utils"
local Status = require "st.zigbee.generated.types.ZclStatus"

--- @module write_attr_response
local write_attr_response = {}

write_attr_response.WRITE_ATTRIBUTE_RESPONSE_ID = 0x04

--- @class st.zigbee.zcl.WriteAttributeResponse.ResponseRecord
---
--- A representation of the record of a single attributes write record
--- @field public NAME string "WriteAttributeResponseRecord"
--- @field public status st.zigbee.zcl.types.ZclStatus The success value of the read for this attribute
--- @field public attr_id st.zigbee.data_types.AttributeId the attribute ID for this record
local WriteAttributeResponseRecord = {
  NAME = "WriteAttributeResponseRecord",
}
WriteAttributeResponseRecord.__index = WriteAttributeResponseRecord
write_attr_response.WriteAttributeResponseRecord = WriteAttributeResponseRecord

--- Parse a WriteAttributeResponseRecord from a byte string
--- @param buf Reader the buf to parse the record from
--- @return st.zigbee.zcl.WriteAttributeResponse.ResponseRecord the parsed attribute record
function WriteAttributeResponseRecord.deserialize(buf)
  local self = {}
  setmetatable(self, WriteAttributeResponseRecord)
  self.status = Status.deserialize(buf)
  self.attr_id = data_types.AttributeId.deserialize(buf)
  return self
end

--- A helper function used by common code to get all the component pieces of this message frame
---@return table An array formatted table with each component field in the order their bytes should be serialized
function WriteAttributeResponseRecord:get_fields()
  local out = {}
  out[#out + 1] = self.status
  out[#out + 1] = self.attr_id
  return out
end

--- @function WriteAttributeResponseRecord:get_length
--- @return number the length of this write attribute response record in bytes
WriteAttributeResponseRecord.get_length = utils.length_from_fields

--- @function WriteAttributeResponseRecord:_serialize
--- @return string this WriteAttributeResponseRecord serialized
WriteAttributeResponseRecord._serialize = utils.serialize_from_fields

--- @function WriteAttributeResponseRecord:pretty_print
--- @return string this WriteAttributeResponseRecord as a human readable string
WriteAttributeResponseRecord.pretty_print = utils.print_from_fields
WriteAttributeResponseRecord.__tostring = WriteAttributeResponseRecord

--- Construct a write attribute response record from parts
--- @param cls table the class being constructed
--- @param status st.zigbee.zcl.types.ZclStatus|number the status of the report
--- @param attr_id st.zigbee.data_types.AttributeId|number the attribute ID written to
--- @return st.zigbee.zcl.WriteAttributeResponse.ResponseRecord
function WriteAttributeResponseRecord.init(cls, status, attr_id)
  local out = {}
  out.status = data_types.validate_or_build_type(status, Status, "status")
  out.attr_id = data_types.validate_or_build_type(attr_id, data_types.AttributeId, "attr_id")
  setmetatable(out, WriteAttributeResponseRecord)
  return out
end
setmetatable(WriteAttributeResponseRecord, { __call = WriteAttributeResponseRecord.init })

--- @class st.zigbee.zcl.WriteAttributeResponse
---
--- A Zigbee Write Attribute Response command body.  The write attribute response can either have a global status value
--- if all attribute writes were successful.  Because of this a parsed WriteAttributeResponse will either have the
--- global_status field populated OR the attr_records field populated.  No instance should have both.
--- @field public NAME string "WriteAttributeResponse"
--- @field public ID number 0x04 The ID of the WriteAttributeResponse ZCL command
--- @field public global_status st.zigbee.zcl.types.ZclStatus the status of all the write commands
--- @field public attr_records st.zigbee.zcl.WriteAttributeResponse.ResponseRecord[] the list of attribute records in this write response
local WriteAttributeResponse = {
  ID = write_attr_response.WRITE_ATTRIBUTE_RESPONSE_ID,
  NAME = "WriteAttributeReponse",
}
WriteAttributeResponse.__index = WriteAttributeResponse
write_attr_response.WriteAttributeResponse = WriteAttributeResponse

--- Parse a st.zigbee.zcl.WriteAttributeResponse from a byte string
--- @param buf Reader the buf to parse the body from
--- @return st.zigbee.zcl.WriteAttributeResponse the parsed attribute record
function WriteAttributeResponse.deserialize(buf)
    local self = {}
    setmetatable(self, WriteAttributeResponse)
    if buf:remain() == 1 then
      self.global_status = Status.deserialize(buf)
    else
      self.attr_records = {}
      while buf:remain() > 0 do
        self.attr_records[#self.attr_records + 1] = write_attr_response.WriteAttributeResponseRecord.deserialize(buf)
      end
    end
    return self
  end

--- A helper function used by common code to get all the component pieces of this message frame
---@return table An array formatted table with each component field in the order their bytes should be serialized
function WriteAttributeResponse:get_fields()
    if self.global_status ~= nil then
      return { self.global_status }
    else
      return self.attr_records
    end
  end

--- @function WriteAttributeResponse:get_length
--- @return number the length of this write attribute response in bytes
WriteAttributeResponse.get_length = utils.length_from_fields

--- @function WriteAttributeResponse:_serialize
--- @return string this WriteAttributeResponse serialized
WriteAttributeResponse._serialize = utils.serialize_from_fields

--- @function WriteAttributeResponse:pretty_print
--- @return string this WriteAttributeResponse as a human readable string
WriteAttributeResponse.pretty_print = utils.print_from_fields
WriteAttributeResponse.__tostring = WriteAttributeResponse.pretty_print

--- Construct a write attribute response from parts
--- @param cls table the class being constructed
--- @param global_status st.zigbee.zcl.types.ZclStatus|number the global status value of all write requests, nil if setting individual records
--- @param write_attr_resp_records st.zigbee.zcl.WriteAttributeResponse.ResponseRecord[] a list of individual write attribute response records
function WriteAttributeResponse.init(cls, global_status, write_attr_resp_records)
  local out = {}
  if global_status ~= nil then
    out.global_status = data_types.validate_or_build_type(global_status, Status, "global_status")
  else
    out.attr_records = write_attr_resp_records
  end
  setmetatable(out, WriteAttributeResponse)
  return out
end
setmetatable(WriteAttributeResponse, {__call = WriteAttributeResponse.init })

return write_attr_response
