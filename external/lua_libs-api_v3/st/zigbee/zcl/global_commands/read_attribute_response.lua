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
local Status = require "st.zigbee.generated.types.ZclStatus"

--- @module read_attr_response
local read_attr_response = {}

read_attr_response.READ_ATTRIBUTE_RESPONSE_ID = 0x01

--- @class st.zigbee.zcl.ReadAttributeResponse.AttributeRecord
---
--- A representation of the record of a single attributes read response
--- @field public NAME string "AttributeRecord"
--- @field public attr_id st.zigbee.data_types.AttributeId the attribute ID for this record
--- @field public status st.zigbee.zcl.types.ZclStatus the status of this read
--- @field public data_type st.zigbee.data_types.ZigbeeDataType The data type of this attribute (Only present if the status was success)
--- @field public data st.zigbee.data_types.DataType the parsed Zigbee data type of the ID represented by the data_type field (Only present if the status was success)
local ReadAttributeResponseAttributeRecord = {
  NAME = "AttributeRecord",
}
ReadAttributeResponseAttributeRecord.__index = ReadAttributeResponseAttributeRecord
read_attr_response.ReadAttributeResponseAttributeRecord = ReadAttributeResponseAttributeRecord

--- Parse a ReadAttributeResponseAttributeRecord from a byte string
--- @param buf Reader the buf to parse the record from
--- @return st.zigbee.zcl.ReadAttributeResponse.AttributeRecord the parsed attribute record
function ReadAttributeResponseAttributeRecord.deserialize(buf)
  local self =  {}
  setmetatable(self, ReadAttributeResponseAttributeRecord)
  self.attr_id = data_types.AttributeId.deserialize(buf)
  self.status = Status.deserialize(buf)
  if self.status.value == Status.SUCCESS then
    self.data_type = data_types.ZigbeeDataType.deserialize(buf)
    self.data = data_types.parse_data_type(self.data_type.value, buf)
  end
  return self
end

--- A helper function used by common code to get all the component pieces of this message frame
---@return table An array formatted table with each component field in the order their bytes should be serialized
function ReadAttributeResponseAttributeRecord:get_fields()
  local out = {}
  out[#out + 1] = self.attr_id
  out[#out + 1] = self.status
  if self.status.value ~= 0 then
    return out
  end
  out[#out + 1] = self.data_type
  out[#out + 1] = self.data
  return out
end

--- @function ReadAttributeResponseAttributeRecord:get_length
--- @return number the length of this read attribute response attribute record in bytes
ReadAttributeResponseAttributeRecord.get_length = utils.length_from_fields

--- @function ReadAttributeResponseAttributeRecord:_serialize
--- @return string this ReadAttributeResponseAttributeRecord serialized
ReadAttributeResponseAttributeRecord._serialize = utils.serialize_from_fields

--- @function ReadAttributeResponseAttributeRecord:pretty_print
--- @return string this ReadAttributeResponseAttributeRecord as a human readable string
ReadAttributeResponseAttributeRecord.pretty_print = utils.print_from_fields
ReadAttributeResponseAttributeRecord.__tostring = ReadAttributeResponseAttributeRecord

--- Build a ReadAttributeResponseAttributeRecord from its individual components
--- @param orig table UNUSED This is the class table when creating using class(...) syntax
--- @param attr_id st.zigbee.data_types.AttributeId This can be either an AttributeId already built or just a number
--- @param status st.zigbee.data_types.Uint8 The status of the read response (if non-success the next 2 args are optional)
--- @param data_type st.zigbee.data_types.ZigbeeDataType This can be either a ZigbeeDataType already built or just a number
--- @param value st.zigbee.data_types.DataType This can be either a built st.zigbee.data_types.DataType or the value needed to build one
--- @return st.zigbee.zcl.ReadAttributeResponse.AttributeRecord the constructed ReadAttributeResponseAttributeRecord
function ReadAttributeResponseAttributeRecord.init(orig, attr_id, status, data_type, value)
  local out = {}
  out.attr_id = data_types.validate_or_build_type(attr_id, data_types.AttributeId, "attr_id")
  out.status = data_types.validate_or_build_type(status, Status, "status")
  if out.status.value == Status.SUCCESS then
    out.data_type = data_types.validate_or_build_type(data_type, data_types.ZigbeeDataType, "data_type")
    out.data = data_types.validate_or_build_type(value, data_types.get_data_type_by_id(out.data_type.value), "data")
  end
  setmetatable(out, ReadAttributeResponseAttributeRecord)
  return out
end

setmetatable(ReadAttributeResponseAttributeRecord, { __call = ReadAttributeResponseAttributeRecord.init } )

--- @class st.zigbee.zcl.ReadAttributeResponse
---
--- @field public NAME string "ReadAttributeResponse"
--- @field public ID number 0x01 The ID of the ReadAttributeResponse ZCL command
--- @field public attr_records st.zigbee.zcl.ReadAttributeResponse.AttributeRecord[] the list of attribute records in this read response
local ReadAttributeResponse = {
  ID = read_attr_response.READ_ATTRIBUTE_RESPONSE_ID,
  NAME = "ReadAttributeResponse",
  ReadAttributeResponseAttributeRecord = ReadAttributeResponseAttributeRecord
}
ReadAttributeResponse.__index = ReadAttributeResponse
read_attr_response.ReadAttributeResponse = ReadAttributeResponse

--- Parse a ReadAttributeResponse from a byte string
--- @param buf Reader the bufto parse the record from
--- @return st.zigbee.zcl.ReadAttributeResponse the parsed attribute record
function ReadAttributeResponse.deserialize(buf)
  local self = {}
  setmetatable(self, ReadAttributeResponse)
  self.attr_records = {}
  while buf:remain() > 0 do
    self.attr_records[#self.attr_records + 1] = read_attr_response.ReadAttributeResponseAttributeRecord.deserialize(buf)
  end
  return self
end

--- A helper function used by common code to get all the component pieces of this message frame
---@return table An array formatted table with each component field in the order their bytes should be serialized
function ReadAttributeResponse:get_fields()
  return self.attr_records
end

--- @function ReadAttributeResponse:get_length
--- @return number the length of this read attribute response record in bytes
ReadAttributeResponse.get_length = utils.length_from_fields

--- @function ReadAttributeResponse:_serialize
--- @return string this ReadAttributeResponse serialized
ReadAttributeResponse._serialize = utils.serialize_from_fields

--- @function ReadAttributeResponse:pretty_print
--- @return string this ReadAttributeResponse as a human readable string
ReadAttributeResponse.pretty_print = utils.print_from_fields
ReadAttributeResponse.__tostring = ReadAttributeResponse.pretty_print

--- Get the data for a given attribute ID
---
--- @param attribute_id number the attribute id to look for
--- @return st.zigbee.data_types.DataType the data value for the given attribute, nil if not present
function ReadAttributeResponse:get_attribute_data(attribute_id)
  for _, record in ipairs(self.attr_records) do
    if record.attr_id.value == attribute_id then
      return record.data
    end
  end
  return nil
end

--- Build a ReadAttributeResponse from its individual components
--- @param orig table UNUSED This is the class table when creating using class(...) syntax
--- @param attribute_read_records st.zigbee.zcl.ReadAttributeResponse.AttributeRecord[] The list of attribute read records
--- @return st.zigbee.zcl.ReadAttributeResponse the constructed ReportAttribute
function ReadAttributeResponse.init(orig, attribute_read_records)
  local out = {}
  out.attr_records = attribute_read_records
  setmetatable(out, ReadAttributeResponse)
  return out
end

setmetatable(ReadAttributeResponse, { __call = ReadAttributeResponse.init })

return read_attr_response
