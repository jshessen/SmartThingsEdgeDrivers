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

--- @module read_reporting_config_resp
local read_reporting_config_resp = {}

read_reporting_config_resp.READ_REPORTING_CONFIGURATION_RESPONSE_ID = 0x09
read_reporting_config_resp.DIRECTION_TO_SERVER = 0x00
read_reporting_config_resp.DIRECTION_TO_CLIENT = 0x01


--- @class st.zigbee.zcl.ReadReportingConfigurationResponse.ResponseRecord
---
--- A representation of the record of a single attribute configuration settings
---
--- Several fields of a configuration are dependent on the value of other fields.  For a full definition of the values
--- see the ZCL specification but otherwise following is a rough breakdown of the fields needed.
---
--- |    status: Always
--- |        direction: If status == SUCCESS
--- |        attr_id  : If status == SUCCESS
--- |        AND
--- |            data_type                 : If direction == 0x00
--- |            minimum_reporting_interval: If direction == 0x00
--- |            maximum_reporting_interval: If direction == 0x00
--- |                reportable_change     : If direction == 0x00 AND data_type is not discrete
--- |        OR
--- |            timeout: If direction = 0x01
---
--- @field public NAME string "ReportingConfigurationRecord"
--- @field public direction st.zigbee.data_types.Uint8 The direction of this configuration (0x00 if the device reports a value, 0x01 if the device expects to receive reports)
--- @field public attr_id st.zigbee.data_types.AttributeId the attribute ID for this record
--- @field public data_type st.zigbee.data_types.ZigbeeDataType the type of this attribute
--- @field public minimum_reporting_interval st.zigbee.data_types.Uint16 the minimum time allowed between reports of this attribute
--- @field public maximum_reporting_interval st.zigbee.data_types.Uint16 the maximum time allowed between reports of this attribute
--- @field public reportable_change st.zigbee.data_types.DataType A value of the type defined by data_type which is the amount of change required to trigger a report
--- @field public timeout st.zigbee.data_types.Uint16 maximum expected time between receiving reports
local ReadReportingConfigurationResponseRecord = {
  NAME = "ReportingConfigurationRecord",
}
ReadReportingConfigurationResponseRecord.__index = ReadReportingConfigurationResponseRecord
read_reporting_config_resp.ReportingConfigurationRecord = ReadReportingConfigurationResponseRecord

--- Parse a ReportingConfigurationRecord from a byte string
--- @param buf Reader the buf to parse the record from
--- @return st.zigbee.zcl.ReadReportingConfigurationResponse.ResponseRecord the parsed attribute record
function ReadReportingConfigurationResponseRecord.deserialize(buf)
  local self = {}
  setmetatable(self, ReadReportingConfigurationResponseRecord)
  self.status = Status.deserialize(buf)
  if self.status.value == Status.SUCCESS then
    self.direction = data_types.Uint8.deserialize(buf, "direction")
    self.attr_id = data_types.AttributeId.deserialize(buf)
    if self.direction.value == read_reporting_config_resp.DIRECTION_TO_SERVER then
      self.data_type = data_types.ZigbeeDataType.deserialize(buf)
      self.minimum_reporting_interval = data_types.Uint16.deserialize(buf, "min_reporting_int")
      self.maximum_reporting_interval = data_types.Uint16.deserialize(buf, "max_reporting_int")
      if not data_types.get_data_type_by_id(self.data_type.value).is_discrete then
        self.reportable_change = data_types.parse_data_type(self.data_type.value, buf, "reportable_change")
      end
    elseif self.direction.value == read_reporting_config_resp.DIRECTION_TO_CLIENT then
      self.timeout = data_types.Uint16.deserialize(buf, "timeout")
    else
      error("Unexpected value for configuration direction")
    end
  end
  return self
end

--- A helper function used by common code to get all the component pieces of this message frame
---@return table An array formatted table with each component field in the order their bytes should be serialized
function ReadReportingConfigurationResponseRecord:get_fields()
  local fields = {}
  fields[#fields + 1] = self.status
  if self.status.value == Status.SUCCESS then
    fields[#fields + 1] = self.direction
    fields[#fields + 1] = self.attr_id
    if self.direction.value == 0x00 then
      fields[#fields + 1] = self.data_type
      fields[#fields + 1] = self.minimum_reporting_interval
      fields[#fields + 1] = self.maximum_reporting_interval
      if not data_types.get_data_type_by_id(self.data_type.value).is_discrete then
        fields[#fields + 1] = self.reportable_change
      end
    else
      fields[#fields + 1] = self.timeout
    end
  end
  return fields
end

--- @function ReadReportingConfigurationResponseRecord:get_length
--- @return number the length of this write attribute response record in bytes
ReadReportingConfigurationResponseRecord.get_length = utils.length_from_fields

--- @function ReadReportingConfigurationResponseRecord:_serialize
--- @return string this ReportingConfigurationRecord serialized
ReadReportingConfigurationResponseRecord._serialize = utils.serialize_from_fields

--- @function ReadReportingConfigurationResponseRecord:pretty_print
--- @return string this ReportingConfigurationRecord as a human readable string
ReadReportingConfigurationResponseRecord.pretty_print = utils.print_from_fields
ReadReportingConfigurationResponseRecord.__tostring = ReadReportingConfigurationResponseRecord.pretty_print

--- Build a ReadReportingConfigurationResponseRecord from its individual components
--- @param cls table UNUSED This is the class table when creating using class(...) syntax
--- @param status ZclStatus The status of the response if non-success no further args are required
--- @param direction st.zigbee.data_types.Uint8 The direction of the reporting config, determines if reporting intervals or timeout are required args
--- @param attr_id st.zigbee.data_types.AttributeId The attribute ID of the reporting config
--- @param data_type st.zigbee.data_types.ZigbeeDataType The data type of the attribute
--- @param min_rep_int st.zigbee.data_types.Uint16 The minimum reporting interval
--- @param max_rep_int st.zigbee.data_types.Uint16 The maximum reporting interval
--- @param rep_change st.zigbee.data_types.DataType The constructed data type for the reportable change (only required if non-discrete type)
--- @param timeout st.zigbee.data_types.Uint16 The timeout only required if direction is 0x01
--- @return st.zigbee.zcl.ReadReportingConfigurationResponse.ResponseRecord the constructed
function ReadReportingConfigurationResponseRecord.init(cls, status, direction, attr_id, data_type, min_rep_int, max_rep_int, rep_change, timeout)
  local out = {}
  out.status = data_types.validate_or_build_type(status, Status, "status")
  if status == Status.SUCCESS then
    out.direction = data_types.validate_or_build_type(direction, data_types.Uint8, "direction")
    out.attr_id = data_types.validate_or_build_type(attr_id, data_types.AttributeId, "attr_id")
    if out.direction.value == 0x00 then
      out.data_type = data_types.validate_or_build_type(data_type, data_types.ZigbeeDataType, "data_type")
      out.minimum_reporting_interval = data_types.validate_or_build_type(min_rep_int, data_types.Uint16, "min_reporting_int")
      out.maximum_reporting_interval = data_types.validate_or_build_type(max_rep_int, data_types.Uint16, "max_reporting_int")
      if not data_types.get_data_type_by_id(out.data_type.value).is_discrete then
        out.reportable_change = data_types.validate_or_build_type(rep_change, data_types.get_data_type_by_id(out.data_type.value), "reportable_change")
      end
    else
      out.timeout = data_types.validate_or_build_type(timeout, data_types.Uint16, "timeout")
    end
  end
  setmetatable(out, ReadReportingConfigurationResponseRecord)
  return out
end

setmetatable(ReadReportingConfigurationResponseRecord, { __call = ReadReportingConfigurationResponseRecord.init })

--- @class st.zigbee.zcl.ReadReportingConfigurationResponse
---
--- @field public NAME string "ReadReportingConfigurationResponse"
--- @field public ID number 0x09 The ID of the ReadReportingConfigurationResponse ZCL command
--- @field public read_reporting_records st.zigbee.zcl.ReadReportingConfigurationResponse.ResponseRecord[] the list of attr configs reported
local ReadReportingConfigurationResponse = {
  ID = read_reporting_config_resp.READ_REPORTING_CONFIGURATION_RESPONSE_ID,
  NAME = "ReadReportingConfigurationResponse",
  ReportingConfigurationRecord = ReadReportingConfigurationResponseRecord
}
ReadReportingConfigurationResponse.__index = ReadReportingConfigurationResponse
read_reporting_config_resp.ReadReportingConfigurationResponse = ReadReportingConfigurationResponse

--- Parse a ReadReportingConfigurationResponse from a byte string
--- @param buf Reader the buf to parse the record from
--- @return st.zigbee.zcl.ReadReportingConfigurationResponse the parsed attribute record
function ReadReportingConfigurationResponse.deserialize(buf)
  local self = {}
  setmetatable(self, ReadReportingConfigurationResponse)
  self.read_reporting_records = {}
  while buf:remain() > 0 do
    self.read_reporting_records[#self.read_reporting_records + 1] = read_reporting_config_resp.ReportingConfigurationRecord.deserialize(buf)
  end
  return self
end

--- A helper function used by common code to get all the component pieces of this message frame
---@return table An array formatted table with each component field in the order their bytes should be serialized
function ReadReportingConfigurationResponse:get_fields()
  return self.read_reporting_records
end

--- @function ReadReportingConfigurationResponse:get_length
--- @return number the length of this ReadReportingConfigurationResponse in bytes
ReadReportingConfigurationResponse.get_length = utils.length_from_fields

--- @function ReadReportingConfigurationResponse:_serialize
--- @return string this ReadReportingConfigurationResponse serialized
ReadReportingConfigurationResponse._serialize = utils.serialize_from_fields

--- @function ReadReportingConfigurationResponse:pretty_print
--- @return string this ReadReportingConfigurationResponse as a human readable string
ReadReportingConfigurationResponse.pretty_print = utils.print_from_fields
ReadReportingConfigurationResponse.__tostring = ReadReportingConfigurationResponse.pretty_print

--- Build a ReadReportingConfigurationResponse from its individual components
--- @param cls table UNUSED This is the class table when creating using class(...) syntax
--- @param reporting_config_records st.zigbee.zcl.ReadReportingConfigurationResponse.ResponseRecord[] the records of the response
--- @return st.zigbee.zcl.ReadReportingConfigurationResponse
function ReadReportingConfigurationResponse.init(cls, reporting_config_records)
  local out = {}
  out.read_reporting_records = reporting_config_records
  setmetatable(out, ReadReportingConfigurationResponse)
  return out
end
setmetatable(ReadReportingConfigurationResponse, { __call = ReadReportingConfigurationResponse.init })

return read_reporting_config_resp
