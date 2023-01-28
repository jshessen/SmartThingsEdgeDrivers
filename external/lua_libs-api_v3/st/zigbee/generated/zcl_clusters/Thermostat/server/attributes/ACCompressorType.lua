local cluster_base = require "st.zigbee.cluster_base"
local data_types = require "st.zigbee.data_types"

-- Copyright 2023 SmartThings
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

-- DO NOT EDIT: this code is automatically generated by tools/zigbee-lib_generator/generate_clusters_from_xml.py
-- Script version: b'b65edec6f2fbd53d4aeed6ab08ac6f3b5ae73520'
-- ZCL XML version: 7.2

--- @class st.zigbee.zcl.clusters.Thermostat.ACCompressorType
--- @alias ACCompressorType
---
--- @field public ID number 0x0043 the ID of this attribute
--- @field public NAME string "ACCompressorType" the name of this attribute
--- @field public data_type st.zigbee.data_types.Enum8 the data type of this attribute
--- @field public T1 number 1
--- @field public T2 number 2
--- @field public T3 number 3
local ACCompressorType = {
  ID = 0x0043,
  NAME = "ACCompressorType",
  base_type = data_types.Enum8,
}

ACCompressorType.T1 = 0x01
ACCompressorType.T2 = 0x02
ACCompressorType.T3 = 0x03


ACCompressorType.enum_fields = {
    [ACCompressorType.T1] = "T1",
    [ACCompressorType.T2] = "T2",
    [ACCompressorType.T3] = "T3",
}

--- Add additional functionality to the base type object
---
--- @param base_type_obj st.zigbee.data_types.Enum8 the base data type object to add functionality to
function ACCompressorType:augment_type(base_type_obj)
  for value, key in pairs(self.enum_fields) do
    base_type_obj[key] = value
  end
  base_type_obj.field_name = self.NAME
  base_type_obj.pretty_print = self.pretty_print
end

function ACCompressorType.pretty_print(value_obj)
  return string.format("%s: %s[%s]", value_obj.field_name or value_obj.NAME, ACCompressorType.NAME, ACCompressorType.enum_fields[value_obj.value])
end

--- @function ACCompressorType:build_test_attr_report
---
--- Build a Rx Zigbee message as if a device reported this attribute
--- @param device st.zigbee.Device
--- @param data st.zigbee.data_types.Enum8 the attribute value
--- @return st.zigbee.ZigbeeMessageRx containing an AttributeReport body
ACCompressorType.build_test_attr_report = cluster_base.build_test_attr_report

--- @function ACCompressorType:build_test_read_attr_response
---
--- Build a Rx Zigbee message as if a device sent a read response for this attribute
--- @param device st.zigbee.Device
--- @param data st.zigbee.data_types.Enum8 the attribute value
--- @return st.zigbee.ZigbeeMessageRx containing an ReadAttributeResponse body
ACCompressorType.build_test_read_attr_response = cluster_base.build_test_read_attr_response

--- Create a Enum8 object of this attribute with any additional features provided for the attribute
---
--- This is also usable with the ACCompressorType(...) syntax
---
--- @vararg vararg the values needed to construct a Enum8
--- @return st.zigbee.data_types.Enum8
function ACCompressorType:new_value(...)
    local o = self.base_type(table.unpack({...}))
    self:augment_type(o)
    return o
end

--- Construct a st.zigbee.ZigbeeMessageTx to read this attribute from a device
---
--- @param device st.zigbee.Device
--- @return st.zigbee.ZigbeeMessageTx containing a ReadAttribute body
function ACCompressorType:read(device)
    return cluster_base.read_attribute(device, data_types.ClusterId(self._cluster.ID), data_types.AttributeId(self.ID))
end

--- Construct a st.zigbee.ZigbeeMessageTx to configure this attribute for reporting on a device
---
--- @param device st.zigbee.Device
--- @param min_rep_int number|st.zigbee.data_types.Uint16 the minimum interval allowed between reports of this attribute
--- @param max_rep_int number|st.zigbee.data_types.Uint16 the maximum interval allowed between reports of this attribute
--- @return st.zigbee.ZigbeeMessageTx containing a ConfigureReporting body
function ACCompressorType:configure_reporting(device, min_rep_int, max_rep_int)
  local min = data_types.validate_or_build_type(min_rep_int, data_types.Uint16, "minimum_reporting_interval")
  local max = data_types.validate_or_build_type(max_rep_int, data_types.Uint16, "maximum_reporting_interval")
  local rep_change = nil
  return cluster_base.configure_reporting(device, data_types.ClusterId(self._cluster.ID), data_types.AttributeId(self.ID), data_types.ZigbeeDataType(self.base_type.ID), min, max, rep_change)
end

--- Write a value to this attribute on a device
---
--- @param device st.zigbee.Device
--- @param value st.zigbee.data_types.Enum8 the value to write
function ACCompressorType:write(device, value)
  local data = data_types.validate_or_build_type(value, self.base_type)
  self:augment_type(data)
  return cluster_base.write_attribute(device, data_types.ClusterId(self._cluster.ID), data_types.AttributeId(self.ID), data)
end

function ACCompressorType:set_parent_cluster(cluster)
  self._cluster = cluster
  return self
end

setmetatable(ACCompressorType, {__call = ACCompressorType.new_value})
return ACCompressorType
