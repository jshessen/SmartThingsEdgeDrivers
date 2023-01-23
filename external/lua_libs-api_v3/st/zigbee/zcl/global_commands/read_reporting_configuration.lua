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

--- @module read_reporting_config
local read_reporting_config = {}

read_reporting_config.READ_REPORTING_CONFIGURATION_ID = 0x08

--- @class st.zigbee.zcl.ReadReportingConfiguration.AttributeRecord
---
--- A representation a request for a given attributes reporting configuration
--- @field public NAME string "ReadReportingConfigurationAttributeRecord"
--- @field public direction st.zigbee.data_types.Uint8 The direction of the attribute configuration to report
--- @field public attr_id st.zigbee.data_types.AttributeId the attribute ID to get the configuration for
local ReadReportingConfigurationAttributeRecord = {
  NAME = "ReadReportingConfigurationAttribtueRecord"
}
ReadReportingConfigurationAttributeRecord.__index = ReadReportingConfigurationAttributeRecord
read_reporting_config.ReadReportingConfigurationAttributeRecord = ReadReportingConfigurationAttributeRecord

--- Parse a ReadReportingConfigurationAttributeRecord from a byte string
--- @param buf Reader the bufto parse the record from
--- @return st.zigbee.zcl.ReadReportingConfiguration.AttributeRecord the parsed attribute record
function ReadReportingConfigurationAttributeRecord.deserialize(buf)
  local self = {}
  setmetatable(self, ReadReportingConfigurationAttributeRecord)
  self.direction = data_types.Uint8.deserialize(buf, "direction")
  self.attr_id = data_types.AttributeId.deserialize(buf)
  return self
end

--- A helper function used by common code to get all the component pieces of this message frame
---@return table An array formatted table with each component field in the order their bytes should be serialized
function ReadReportingConfigurationAttributeRecord:get_fields()
  local out = {}
  out[#out + 1] = self.direction
  out[#out + 1] = self.attr_id
  return out
end

--- @function ReadReportingConfigurationAttributeRecord:get_length
--- @return number the length of this write attribute response record in bytes
ReadReportingConfigurationAttributeRecord.get_length = utils.length_from_fields

--- @function ReadReportingConfigurationAttributeRecord:_serialize
--- @return string this ReadReportingConfigurationAttributeRecord serialized
ReadReportingConfigurationAttributeRecord._serialize = utils.serialize_from_fields

--- @function ReadReportingConfigurationAttributeRecord:pretty_print
--- @return string this ReadReportingConfigurationAttributeRecord as a human readable string
ReadReportingConfigurationAttributeRecord.pretty_print = utils.print_from_fields
ReadReportingConfigurationAttributeRecord.__tostring = ReadReportingConfigurationAttributeRecord.pretty_print

--- Build a ReadReportingConfigurationAttributeRecord from its individual components
--- @param orig table UNUSED This is the class table when creating using class(...) syntax
--- @param direction st.zigbee.data_types.Uint8/number The direction of the attribute configuration to read
--- @param attr_id st.zigbee.data_types.AttributeId/number The attribute ID to get the configuration for
--- @return st.zigbee.zcl.ReadReportingConfiguration.AttributeRecord the constructed ReadReportingConfigurationAttributeRecord instance
function ReadReportingConfigurationAttributeRecord.init(orig, direction, attr_id)
  local o = {}
  setmetatable(o, ReadReportingConfigurationAttributeRecord)
  o.direction = data_types.validate_or_build_type(direction, data_types.Uint8, "direction")
  o.attr_id = data_types.validate_or_build_type(attr_id, data_types.AttributeId, "attr_id")
  return o
end

setmetatable(ReadReportingConfigurationAttributeRecord, { __call = ReadReportingConfigurationAttributeRecord.init } )

--- @class st.zigbee.zcl.ReadReportingConfiguration
---
--- @field public NAME string "ReadReportingConfiguration"
--- @field public ID number 0x08 The ID of the WriteAttribute ZCL command
--- @field public read_reporting_records st.zigbee.zcl.ReadReportingConfiguration.AttributeRecord[] the list of attr configs to read
local ReadReportingConfiguration = {
  ID = read_reporting_config.READ_REPORTING_CONFIGURATION_ID,
  NAME = "ReadReportingConfiguration",
  ReadReportingConfigurationAttributeRecord = ReadReportingConfigurationAttributeRecord
}
ReadReportingConfiguration.__index = ReadReportingConfiguration
read_reporting_config.ReadReportingConfiguration = ReadReportingConfiguration

--- Parse a ReadReportingConfiguration from a byte string
--- @param buf Reader the buf to parse the record from
--- @return st.zigbee.zcl.ReadReportingConfiguration the parsed attribute record
function ReadReportingConfiguration.deserialize(buf)
  local self = {}
  setmetatable(self, ReadReportingConfiguration)
  self.read_reporting_records = {}
  while buf:remain() > 0 do
    self.read_reporting_records[#self.read_reporting_records + 1] = read_reporting_config.ReadReportingConfigurationAttributeRecord.deserialize(buf)
  end
  return self
end

--- A helper function used by common code to get all the component pieces of this message frame
---@return table An array formatted table with each component field in the order their bytes should be serialized
function ReadReportingConfiguration:get_fields()
  return self.read_reporting_records
end

--- @function ReadReportingConfiguration:get_length
--- @return number the length of this write attribute response record in bytes
ReadReportingConfiguration.get_length = utils.length_from_fields

--- @function ReadReportingConfiguration:_serialize
--- @return string this ReadReportingConfiguration serialized
ReadReportingConfiguration._serialize = utils.serialize_from_fields

--- @function ReadReportingConfiguration:pretty_print
--- @return string this ReadReportingConfiguration as a human readable string
ReadReportingConfiguration.pretty_print = utils.print_from_fields
ReadReportingConfiguration.__tostring = ReadReportingConfiguration.pretty_print

--- Build a ReadReportingConfiguration from its individual components
--- @param orig table UNUSED This is the class table when creating using class(...) syntax
--- @param read_records st.zigbee.zcl.ReadReportingConfiguration.AttributeRecord[] the list of read records
--- @return st.zigbee.zcl.ReadReportingConfiguration the constructed ReadReportingConfiguration instance
function ReadReportingConfiguration.init(orig, read_records)
  local o = {}
  setmetatable(o, ReadReportingConfiguration)
  if #read_records == 0 then
    error(string.format("%s requires at least one read reporting config record", o.NAME), 2)
  end
  o.read_reporting_records = read_records
  return o
end

setmetatable(ReadReportingConfiguration, { __call = ReadReportingConfiguration.init } )

return read_reporting_config
