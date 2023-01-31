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

--- @module report_attr
local report_attr = {}

report_attr.REPORT_ATTRIBUTE_ID = 0x0A

--- @class st.zigbee.zcl.ReportAttribute.AttributeRecord
---
--- A representation of the record of a single attribute value report
--- @field public NAME string "AttributeRecord"
--- @field public attr_id st.zigbee.data_types.AttributeId the attribute ID for this record
--- @field public data_type st.zigbee.data_types.ZigbeeDataType The data type of this attribute
--- @field public data st.zigbee.data_types.DataType the parsed Zigbee data type of the ID represented by the data_type field
local ReportAttributeAttributeRecord = {
  NAME = "AttributeRecord",
}
ReportAttributeAttributeRecord.__index = ReportAttributeAttributeRecord
report_attr.ReportAttributeAttributeRecord = ReportAttributeAttributeRecord

--- Parse a ReportAttributeAttributeRecord from a byte string
--- @param buf Reader the bufto parse the record from
--- @return st.zigbee.zcl.ReportAttribute.AttributeRecord the parsed attribute record
function ReportAttributeAttributeRecord.deserialize(buf)
  local self = {}
  setmetatable(self, ReportAttributeAttributeRecord)
  self.attr_id = data_types.AttributeId.deserialize(buf)
  self.data_type = data_types.ZigbeeDataType.deserialize(buf)
  self.data = data_types.parse_data_type(self.data_type.value, buf)
  return self
end

--- A helper function used by common code to get all the component pieces of this message frame
---@return table An array formatted table with each component field in the order their bytes should be serialized
function ReportAttributeAttributeRecord:get_fields()
  local out = {}
  out[#out + 1] = self.attr_id
  out[#out + 1] = self.data_type
  out[#out + 1] = self.data
  return out
end

--- @function ReportAttributeAttributeRecord:get_length
--- @return number the length of this read attribute response attribute record in bytes
ReportAttributeAttributeRecord.get_length = utils.length_from_fields

--- @function ReportAttributeAttributeRecord:_serialize
--- @return string this ReportAttributeAttributeRecord serialized
ReportAttributeAttributeRecord._serialize = utils.serialize_from_fields

--- @function ReportAttributeAttributeRecord:pretty_print
--- @return string this ReportAttributeAttributeRecord as a human readable string
ReportAttributeAttributeRecord.pretty_print = utils.print_from_fields
ReportAttributeAttributeRecord.__tostring = ReportAttributeAttributeRecord.pretty_print

--- Build a st.zigbee.zcl.ReportAttribute.AttributeRecord from its individual components
--- @param cls table UNUSED This is the class table when creating using class(...) syntax
--- @param attr_id st.zigbee.data_types.AttributeId This can be either an AttributeId already built or just a number
--- @param data_type st.zigbee.data_types.ZigbeeDataType This can be either a ZigbeeDataType already built or just a number
--- @param value st.zigbee.data_types.DataType This can be either a built st.zigbee.data_types.DataType or the value needed to build one
--- @return st.zigbee.zcl.ReportAttribute.AttributeRecord the constructed ReportAttributeAttributeRecord
function ReportAttributeAttributeRecord.init(cls, attr_id, data_type, value)
  local out = {}
  out.attr_id = data_types.validate_or_build_type(attr_id, data_types.AttributeId, "attr_id")
  out.data_type = data_types.validate_or_build_type(data_type, data_types.ZigbeeDataType, "data_type")
  out.data = data_types.validate_or_build_type(value, data_types.get_data_type_by_id(out.data_type.value), "data")
  setmetatable(out, ReportAttributeAttributeRecord)
  return out
end

setmetatable(report_attr.ReportAttributeAttributeRecord, { __call = report_attr.ReportAttributeAttributeRecord.init })

--- @class st.zigbee.zcl.ReportAttribute
---
--- @field public NAME string "ReportAttribute"
--- @field public ID number 0x0A The ID of the WriteAttribute ZCL command
--- @field public attr_records st.zigbee.zcl.ReportAttribute.AttributeRecord[] the list of attribute records in this attribute report
local ReportAttribute = {
  ID = report_attr.REPORT_ATTRIBUTE_ID,
  NAME = "ReportAttribute",
}
ReportAttribute.__index = ReportAttribute
report_attr.ReportAttribute = ReportAttribute

--- Parse a ReportAttribute from a byte string
--- @param buf Reader the bufto parse the record from
--- @return st.zigbee.zcl.ReportAttribute the parsed attribute record
function ReportAttribute.deserialize(buf)
  local self = {}
  setmetatable(self, ReportAttribute)
  self.attr_records = {}
  while buf:remain() > 0 do
    self.attr_records[#self.attr_records + 1] = report_attr.ReportAttributeAttributeRecord.deserialize(buf)
  end
  return self
end

--- A helper function used by common code to get all the component pieces of this message frame
---@return table An array formatted table with each component field in the order their bytes should be serialized
function ReportAttribute:get_fields()
  return self.attr_records
end

--- @function ReportAttribute:get_length
--- @return number the length of this read attribute response attribute record in bytes
ReportAttribute.get_length = utils.length_from_fields

--- @function ReportAttribute:_serialize
--- @return string this ReportAttribute serialized
ReportAttribute._serialize = utils.serialize_from_fields

--- @function ReportAttribute:pretty_print
--- @return string this ReportAttribute as a human readable string
ReportAttribute.pretty_print = utils.print_from_fields
ReportAttribute.__tostring = ReportAttribute.pretty_print

--- Get the data for a given attribute ID
---
--- @param attribute_id number the attribute id to look for
--- @return DataType the data value for the given attribute, nil if not present
function ReportAttribute:get_attribute_data(attribute_id)
  for _, record in ipairs(self.attr_records) do
    if record.attr_id.value == attribute_id then
      return record.data
    end
  end
  return nil
end

--- Build a st.zigbee.zcl.ReportAttribute from its individual components
--- @param cls table UNUSED This is the class table when creating using class(...) syntax
--- @param attribute_report_records st.zigbee.zcl.ReportAttribute.AttributeRecord[] The list of attribute report records
--- @return st.zigbee.zcl.ReportAttribute the constructed ReportAttribute
function ReportAttribute.init(cls, attribute_report_records)
  local out = {}
  out.attr_records = attribute_report_records
  setmetatable(out, ReportAttribute)
  return out
end

setmetatable(report_attr.ReportAttribute, { __call = report_attr.ReportAttribute.init })

return report_attr
