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

--- @module config_reporting
local config_reporting = {}

config_reporting.CONFIGURE_REPORTING_ID = 0x06
config_reporting.DIRECTION_TO_SERVER = 0x00
config_reporting.DIRECTION_TO_CLIENT = 0x01

--- @class st.zigbee.zcl.ConfigureReporting.AttributeConfiguration
---
--- A representation of the record of a single attribute configuration settings
---
--- Several fields of a configuration are dependent on the value of other fields.  For a full definition of the values
--- see the ZCL specification but otherwise following is a rough breakdown of the fields needed.
---
--- |    direction: Always
--- |    attr_id  : Always
--- |    AND
--- |        data_type                 : If direction == 0x00
--- |        minimum_reporting_interval: If direction == 0x00
--- |        maximum_reporting_interval: If direction == 0x00
--- |            reportable_change     : If direction == 0x00 AND data_type is not discrete
--- |    OR
--- |        timeout: If direction = 0x01
---
--- @field public NAME string "AttributeReportingConfiguration"
--- @field public direction st.zigbee.data_types.Uint8 The direction of this configuration (0x00 to tell a device to report, 0x01 to inform a device you will report)
--- @field public attr_id st.zigbee.data_types.AttributeId the attribute ID for this record
--- @field public data_type st.zigbee.data_types.ZigbeeDataType the type of this attribute
--- @field public minimum_reporting_interval st.zigbee.data_types.Uint16 the minimum time allowed between reports of this attribute
--- @field public maximum_reporting_interval st.zigbee.data_types.Uint16 the maximum time allowed between reports of this attribute
--- @field public reportable_change st.zigbee.data_types.DataType A value of the type defined by data_type which is the amount of change required to trigger a report
--- @field public timeout st.zigbee.data_types.Uint16 maximum expected time between receiving reports
local AttributeReportingConfiguration = {
  NAME = "AttributeReportingConfiguration",
}
AttributeReportingConfiguration.__index = AttributeReportingConfiguration
config_reporting.AttributeReportingConfiguration = AttributeReportingConfiguration

--- Parse a AttributeReportingConfiguration from a byte string
--- @param buf Reader the bufto parse the record from
--- @return st.zigbee.zcl.ConfigureReporting.AttributeConfiguration the parsed config reporting record
function AttributeReportingConfiguration.deserialize(buf)
  local self = {}
  setmetatable(self, AttributeReportingConfiguration)
  self.direction = data_types.Uint8.deserialize(buf, "direction")
  self.attr_id = data_types.AttributeId.deserialize(buf, "attr_id")
  if self.direction.value == config_reporting.DIRECTION_TO_SERVER then
    self.data_type = data_types.ZigbeeDataType.deserialize(buf, "data_type")
    self.minimum_reporting_interval = data_types.Uint16.deserialize(buf, "min_reporting_int")
    self.maximum_reporting_interval = data_types.Uint16.deserialize(buf, "max_reporting_int")
    if not data_types.get_data_type_by_id(self.data_type.value).is_discrete then
      self.reportable_change = data_types.parse_data_type(self.data_type.value, buf, "reportable_change")
    end
  elseif self.direction.value == config_reporting.DIRECTION_TO_CLIENT then
    self.timeout = data_types.Uint16.deserialize(buf, "timeout")
  else
    error("Unexpected value for configuration direction")
  end
  return self
end

--- A helper function used by common code to get all the component pieces of this message frame
---@return table An array formatted table with each component field in the order their bytes should be serialized
function AttributeReportingConfiguration:get_fields()
  local fields = {}
  fields[#fields + 1] = self.direction
  fields[#fields + 1] = self.attr_id
  if self.direction.value == config_reporting.DIRECTION_TO_SERVER then
    fields[#fields + 1] = self.data_type
    fields[#fields + 1] = self.minimum_reporting_interval
    fields[#fields + 1] = self.maximum_reporting_interval
    if not data_types.get_data_type_by_id(self.data_type.value).is_discrete then
      fields[#fields + 1] = self.reportable_change
    end
  else
    fields[#fields + 1] = self.timeout
  end
  return fields
end

--- @function AttributeReportingConfiguration:get_length
--- @return number the length of AttributeReportingConfiguration record in bytes
AttributeReportingConfiguration.get_length = utils.length_from_fields

--- @function AttributeReportingConfiguration:_serialize
--- @return string this AttributeReportingConfiguration serialized
AttributeReportingConfiguration._serialize = utils.serialize_from_fields

--- @function AttributeReportingConfiguration:pretty_print
--- @return string this AttributeReportingConfiguration as a human readable string
AttributeReportingConfiguration.pretty_print = utils.print_from_fields
AttributeReportingConfiguration.__tostring = AttributeReportingConfiguration.pretty_print

--- Construct a AttributeReportingConfiguration from values
--- @param orig table UNUSED this is the template class when called with class(...) syntax
--- @param data_table table A table containing the necessary fields.  See class description for necessary combination of fields
--- @return st.zigbee.zcl.ConfigureReporting.AttributeConfiguration the constructed instance
function AttributeReportingConfiguration.init(orig, data_table)
  local out = {}
  out.direction = data_types.validate_or_build_type(data_table.direction, data_types.Uint8, "direction")
  out.attr_id = data_types.validate_or_build_type(data_table.attr_id, data_types.AttributeId, "attr_id")

  if out.direction.value == config_reporting.DIRECTION_TO_SERVER then
    out.data_type = data_types.validate_or_build_type(data_table.data_type, data_types.ZigbeeDataType, "data_type")
    out.minimum_reporting_interval = data_types.validate_or_build_type(data_table.minimum_reporting_interval, data_types.Uint16, "minimum_reporting_interval")
    out.maximum_reporting_interval = data_types.validate_or_build_type(data_table.maximum_reporting_interval, data_types.Uint16, "maximum_reporting_interval")
    local dt = data_types.get_data_type_by_id(out.data_type.value)
    if not dt.is_discrete then
      out.reportable_change = data_types.validate_or_build_type(data_table.reportable_change, dt, "reportable_change")
    end
  elseif out.direction.value == config_reporting.DIRECTION_TO_CLIENT then
    out.timeout = data_types.validate_or_build_type(data_table.timeout, data_types.Uint16, "timeout")
  else
    error("Attribute reporting configuration must include a valid direction", 2)
  end
  setmetatable(out, AttributeReportingConfiguration)
  return out
end

setmetatable(AttributeReportingConfiguration, {__call = AttributeReportingConfiguration.init})

--- @class st.zigbee.zcl.ConfigureReporting
---
--- A representation of a configure reporting command body
---
--- @field public NAME string "ConfigureReporting"
--- @field public ID number 0x06
--- @field public attr_config_records st.zigbee.zcl.ConfigureReporting.AttributeConfiguration[] The list of attribute configurations
local ConfigureReporting = {
  ID = config_reporting.CONFIGURE_REPORTING_ID,
  NAME = "ConfigureReporting",
  AttributeReportingConfiguration = AttributeReportingConfiguration,
}
ConfigureReporting.__index = ConfigureReporting
config_reporting.ConfigureReporting = ConfigureReporting

--- Parse a ConfigureReporting command body from a byte string
--- @param buf Reader the bufto parse the record from
--- @return st.zigbee.zcl.ConfigureReporting the parsed config reporting record
function ConfigureReporting.deserialize(buf)
  local self = {}
  setmetatable(self, ConfigureReporting)
  self.attr_config_records = {}
  while buf:remain() > 0 do
    self.attr_config_records[#self.attr_config_records + 1] = config_reporting.AttributeReportingConfiguration.deserialize(buf)
  end
  return self
end

--- A helper function used by common code to get all the component pieces of this message frame
---@return table An array formatted table with each component field in the order their bytes should be serialized
function ConfigureReporting:get_fields()
  return self.attr_config_records
end

--- @function ConfigureReporting:get_length
--- @return number the length of ConfigureReporting record in bytes
ConfigureReporting.get_length = utils.length_from_fields

--- @function ConfigureReporting:_serialize
--- @return string this ConfigureReporting serialized
ConfigureReporting._serialize = utils.serialize_from_fields

--- @function ConfigureReporting:pretty_print
--- @return string this ConfigureReporting as a human readable string
ConfigureReporting.pretty_print = utils.print_from_fields
ConfigureReporting.__tostring = ConfigureReporting.pretty_print

--- Construct a ConfigureReporting from values
--- @param orig table UNUSED this is the template class when called with class(...) syntax
--- @param attr_config_records st.zigbee.zcl.ConfigureReporting.AttributeConfiguration[] The list of attribute configurations
--- @return st.zigbee.zcl.ConfigureReporting the constructed instance
function ConfigureReporting.init(orig, attr_config_records)
  local out = {}
  for _, v in ipairs(attr_config_records) do
    if v.direction == nil or v.attr_id == nil then
      error(string.format("%s requires list of %s", orig.NAME, config_reporting.AttributeReportingConfiguration.NAME), 2)
    end
  end
  setmetatable(out, ConfigureReporting)
  out.attr_config_records = attr_config_records
  return out
end

setmetatable(ConfigureReporting, {__call = ConfigureReporting.init })

return config_reporting
