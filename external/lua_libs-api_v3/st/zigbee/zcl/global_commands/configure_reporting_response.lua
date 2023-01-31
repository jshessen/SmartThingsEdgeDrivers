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

--- @module config_rep_response
local config_rep_response = {}

config_rep_response.CONFIGURE_REPORTING_RESPONSE_ID = 0x07

--- @class st.zigbee.zcl.ConfigureReportingResponse.Record
---
--- A representation of the record of a single attribute reporting configuration response
--- @field public NAME string "ConfigureReportingResponseRecord"
--- @field public status st.zigbee.zcl.types.ZclStatus the status of this read
--- @field public direction st.zigbee.data_types.Uint8 The direction of the configuration command this is in response to
--- @field public attr_id st.zigbee.data_types.AttributeId the attribute ID for this record
local ConfigureReportingResponseRecord = {
  NAME = "ConfigureReportingResponseRecord",
}
ConfigureReportingResponseRecord.__index = ConfigureReportingResponseRecord
config_rep_response.ConfigureReportingResponseRecord = ConfigureReportingResponseRecord

--- Parse a ConfigureReportingResponseRecord from a byte string
--- @param buf Reader the bufto parse the record from
--- @return st.zigbee.zcl.ConfigureReportingResponse.Record the parsed attribute record
function ConfigureReportingResponseRecord.deserialize(buf)
  local self = {}
  setmetatable(self, ConfigureReportingResponseRecord)

  local fields = {
    { name = "status", type = Status },
    { name = "direction", type = data_types.Uint8 },
    { name = "attr_id", type = data_types.AttributeId }
  }
  utils.deserialize_field_list(self, fields, buf)
  return self
end

--- A helper function used by common code to get all the component pieces of this message frame
---@return table An array formatted table with each component field in the order their bytes should be serialized
function ConfigureReportingResponseRecord:get_fields()
  local out = {}
  out[#out + 1] = self.status
  out[#out + 1] = self.direction
  out[#out + 1] = self.attr_id
  return out
end

--- @function ConfigureReportingResponseRecord:get_length
--- @return number the length of this ConfigureReportingResponseRecord in bytes
ConfigureReportingResponseRecord.get_length = utils.length_from_fields

--- @function ConfigureReportingResponseRecord:_serialize
--- @return string this ConfigureReportingResponseRecord serialized
ConfigureReportingResponseRecord._serialize = utils.serialize_from_fields

--- @function ConfigureReportingResponseRecord:pretty_print
--- @return string this ConfigureReportingResponseRecord as a human readable string
ConfigureReportingResponseRecord.pretty_print = utils.print_from_fields
ConfigureReportingResponseRecord.__tostring = ConfigureReportingResponseRecord.pretty_print

--- Create a configure reporting response record for a single attribute configuration
---
--- @param cls st.zigbee.zcl.ConfigureReportingResponse.Record
--- @param status st.zigbee.zcl.types.ZclStatus|number the configure reporting status
--- @param direction st.zigbee.data_types.Uint8|number the direction of the configuration
--- @param attr_id st.zigbee.data_types.AttributeId|number the attribute being configured
--- @return st.zigbee.zcl.ConfigureReportingResponse.Record
function ConfigureReportingResponseRecord.init(cls, status, direction, attr_id)
  local out = {}
  out.status = data_types.validate_or_build_type(status, Status, "status")
  out.direction = data_types.validate_or_build_type(direction, data_types.Uint8, "direction")
  out.attr_id = data_types.validate_or_build_type(attr_id, data_types.AttributeId, "attr_id")
  setmetatable(out, ConfigureReportingResponseRecord)
  return out
end

setmetatable(ConfigureReportingResponseRecord, {__call = ConfigureReportingResponseRecord.init })

--- @class st.zigbee.zcl.ConfigureReportingResponse
---
--- A Zigbee Configure Reporting Response command body.  The configure reporting response can either have a global status
--- value if all attribute writes were successful.  Because of this a parsed ConfigureReportingResponse will either have
--- the global_status field populated OR the attr_records field populated.  No instance should have both.
--- @field public NAME string "ConfigureReportingResponse"
--- @field public ID number 0x07 The ID of the ConfigureReportingResponse ZCL command
--- @field public global_status st.zigbee.zcl.types.ZclStatus the status of all the write commands
--- @field public attr_records st.zigbee.zcl.ConfigureReportingResponse.Record[] the list of attribute records in this configure response
local ConfigureReportingResponse = {
  ID = config_rep_response.CONFIGURE_REPORTING_RESPONSE_ID,
  NAME = "ConfigureReportingResponse",
}
ConfigureReportingResponse.__index = ConfigureReportingResponse

config_rep_response.ConfigureReportingResponse = ConfigureReportingResponse

--- Parse a ConfigureReportingResponse from a byte string
--- @param buf Reader the bufto parse the record from
--- @return st.zigbee.zcl.ConfigureReportingResponse the parsed command body
function ConfigureReportingResponse.deserialize(buf)
  local self = {}
  setmetatable(self, ConfigureReportingResponse)
  if buf:remain() == 1 then
    self.global_status = Status.deserialize(buf)
  else
    self.config_records = {}
    while buf:remain() > 0 do
      self.config_records[#self.config_records + 1] = config_rep_response.ConfigureReportingResponseRecord.deserialize(buf)
    end
  end
  return self
end

--- A helper function used by common code to get all the component pieces of this message frame
---@return table An array formatted table with each component field in the order their bytes should be serialized
function ConfigureReportingResponse:get_fields()
  if self.global_status ~= nil then
    return { self.global_status }
  else
    return self.config_records
  end

end

--- @function ConfigureReportingResponse:get_length
--- @return number the length of this ConfigureReportingResponse in bytes
ConfigureReportingResponse.get_length = utils.length_from_fields

--- @function ConfigureReportingResponse:_serialize
--- @return string this ConfigureReportingResponse serialized
ConfigureReportingResponse._serialize = utils.serialize_from_fields

--- @function ConfigureReportingResponse:pretty_print
--- @return string this ConfigureReportingResponse as a human readable string
ConfigureReportingResponse.pretty_print = utils.print_from_fields
ConfigureReportingResponse.__tostring = ConfigureReportingResponse.pretty_print


--- Create a configure reporting response ZCL body
---
--- @param cls st.zigbee.zcl.ConfigureReportingResponse the class being instantiated
--- @param config_record_list st.zigbee.zcl.ConfigureReportingResponse.Record[] the list of response records if empty, global status must be supplied
--- @param global_status st.zigbee.zcl.types.ZclStatus|number Only used if config_record_list is empty
--- @return st.zigbee.zcl.ConfigureReportingResponse
function ConfigureReportingResponse.init(cls, config_record_list, global_status)
  local out = {}
  if #config_record_list > 0 then
    for i, record in ipairs(config_record_list) do
      if getmetatable(record) ~= ConfigureReportingResponseRecord then
        error("The list of response records should be ConfigureReportingResponseRecords", 2)
      end
    end
    out.config_records = config_record_list
  else
    out.global_status = data_types.validate_or_build_type(global_status, Status, "global_status")
  end
  setmetatable(out, ConfigureReportingResponse)
  return out
end

setmetatable(ConfigureReportingResponse, {__call = ConfigureReportingResponse.init })

return config_rep_response
