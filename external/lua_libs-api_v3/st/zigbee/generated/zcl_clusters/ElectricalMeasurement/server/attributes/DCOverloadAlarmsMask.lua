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

--- @class st.zigbee.zcl.clusters.ElectricalMeasurement.DCOverloadAlarmsMask
--- @alias DCOverloadAlarmsMask
---
--- @field public ID number 0x0700 the ID of this attribute
--- @field public NAME string "DCOverloadAlarmsMask" the name of this attribute
--- @field public data_type st.zigbee.data_types.Bitmap8 the data type of this attribute
--- @field public VOLTAGE_OVERLOAD number 1
--- @field public CURRENT_OVERLOAD number 2
local DCOverloadAlarmsMask = {
  ID = 0x0700,
  NAME = "DCOverloadAlarmsMask",
  base_type = data_types.Bitmap8,
}

DCOverloadAlarmsMask.BASE_MASK        = 0xFF
DCOverloadAlarmsMask.VOLTAGE_OVERLOAD = 0x01
DCOverloadAlarmsMask.CURRENT_OVERLOAD = 0x02


DCOverloadAlarmsMask.mask_fields = {
  BASE_MASK = 0xFF,
  VOLTAGE_OVERLOAD = 0x01,
  CURRENT_OVERLOAD = 0x02,
}


--- @function DCOverloadAlarmsMask:is_voltage_overload_set
--- @return boolean True if the value of VOLTAGE_OVERLOAD is non-zero
DCOverloadAlarmsMask.is_voltage_overload_set = function(self)
  return (self.value & self.VOLTAGE_OVERLOAD) ~= 0
end
 
--- @function DCOverloadAlarmsMask:set_voltage_overload
--- Set the value of the bit in the VOLTAGE_OVERLOAD field to 1
DCOverloadAlarmsMask.set_voltage_overload = function(self)
  self.value = self.value | self.VOLTAGE_OVERLOAD
end

--- @function DCOverloadAlarmsMask:unset_voltage_overload
--- Set the value of the bits in the VOLTAGE_OVERLOAD field to 0
DCOverloadAlarmsMask.unset_voltage_overload = function(self)
  self.value = self.value & (~self.VOLTAGE_OVERLOAD & self.BASE_MASK)
end

--- @function DCOverloadAlarmsMask:is_current_overload_set
--- @return boolean True if the value of CURRENT_OVERLOAD is non-zero
DCOverloadAlarmsMask.is_current_overload_set = function(self)
  return (self.value & self.CURRENT_OVERLOAD) ~= 0
end
 
--- @function DCOverloadAlarmsMask:set_current_overload
--- Set the value of the bit in the CURRENT_OVERLOAD field to 1
DCOverloadAlarmsMask.set_current_overload = function(self)
  self.value = self.value | self.CURRENT_OVERLOAD
end

--- @function DCOverloadAlarmsMask:unset_current_overload
--- Set the value of the bits in the CURRENT_OVERLOAD field to 0
DCOverloadAlarmsMask.unset_current_overload = function(self)
  self.value = self.value & (~self.CURRENT_OVERLOAD & self.BASE_MASK)
end


DCOverloadAlarmsMask.mask_methods = {
  is_voltage_overload_set = DCOverloadAlarmsMask.is_voltage_overload_set,
  set_voltage_overload = DCOverloadAlarmsMask.set_voltage_overload,
  unset_voltage_overload = DCOverloadAlarmsMask.unset_voltage_overload,
  is_current_overload_set = DCOverloadAlarmsMask.is_current_overload_set,
  set_current_overload = DCOverloadAlarmsMask.set_current_overload,
  unset_current_overload = DCOverloadAlarmsMask.unset_current_overload,
}

--- Add additional functionality to the base type object
---
--- @param base_type_obj st.zigbee.data_types.Bitmap8 the base data type object to add functionality to
function DCOverloadAlarmsMask:augment_type(base_type_obj)
  for k, v in pairs(self.mask_fields) do
    base_type_obj[k] = v
  end
  for k, v in pairs(self.mask_methods) do
    base_type_obj[k] = v
  end
  
  base_type_obj.field_name = self.NAME
  base_type_obj.pretty_print = self.pretty_print
end

function DCOverloadAlarmsMask.pretty_print(value_obj)
  local zb_utils = require "st.zigbee.utils" 
  local pattern = ">I" .. value_obj.byte_length
  return string.format("%s: %s[0x]", value_obj.field_name or value_obj.NAME, DCOverloadAlarmsMask.NAME, zb_utils.pretty_print_hex_str(string.pack(pattern, value_obj.value)))
end

--- @function DCOverloadAlarmsMask:build_test_attr_report
---
--- Build a Rx Zigbee message as if a device reported this attribute
--- @param device st.zigbee.Device
--- @param data st.zigbee.data_types.Bitmap8 the attribute value
--- @return st.zigbee.ZigbeeMessageRx containing an AttributeReport body
DCOverloadAlarmsMask.build_test_attr_report = cluster_base.build_test_attr_report

--- @function DCOverloadAlarmsMask:build_test_read_attr_response
---
--- Build a Rx Zigbee message as if a device sent a read response for this attribute
--- @param device st.zigbee.Device
--- @param data st.zigbee.data_types.Bitmap8 the attribute value
--- @return st.zigbee.ZigbeeMessageRx containing an ReadAttributeResponse body
DCOverloadAlarmsMask.build_test_read_attr_response = cluster_base.build_test_read_attr_response

--- Create a Bitmap8 object of this attribute with any additional features provided for the attribute
---
--- This is also usable with the DCOverloadAlarmsMask(...) syntax
---
--- @vararg vararg the values needed to construct a Bitmap8
--- @return st.zigbee.data_types.Bitmap8
function DCOverloadAlarmsMask:new_value(...)
    local o = self.base_type(table.unpack({...}))
    self:augment_type(o)
    return o
end

--- Construct a st.zigbee.ZigbeeMessageTx to read this attribute from a device
---
--- @param device st.zigbee.Device
--- @return st.zigbee.ZigbeeMessageTx containing a ReadAttribute body
function DCOverloadAlarmsMask:read(device)
    return cluster_base.read_attribute(device, data_types.ClusterId(self._cluster.ID), data_types.AttributeId(self.ID))
end

--- Construct a st.zigbee.ZigbeeMessageTx to configure this attribute for reporting on a device
---
--- @param device st.zigbee.Device
--- @param min_rep_int number|st.zigbee.data_types.Uint16 the minimum interval allowed between reports of this attribute
--- @param max_rep_int number|st.zigbee.data_types.Uint16 the maximum interval allowed between reports of this attribute
--- @return st.zigbee.ZigbeeMessageTx containing a ConfigureReporting body
function DCOverloadAlarmsMask:configure_reporting(device, min_rep_int, max_rep_int)
  local min = data_types.validate_or_build_type(min_rep_int, data_types.Uint16, "minimum_reporting_interval")
  local max = data_types.validate_or_build_type(max_rep_int, data_types.Uint16, "maximum_reporting_interval")
  local rep_change = nil
  return cluster_base.configure_reporting(device, data_types.ClusterId(self._cluster.ID), data_types.AttributeId(self.ID), data_types.ZigbeeDataType(self.base_type.ID), min, max, rep_change)
end

--- Write a value to this attribute on a device
---
--- @param device st.zigbee.Device
--- @param value st.zigbee.data_types.Bitmap8 the value to write
function DCOverloadAlarmsMask:write(device, value)
  local data = data_types.validate_or_build_type(value, self.base_type)
  self:augment_type(data)
  return cluster_base.write_attribute(device, data_types.ClusterId(self._cluster.ID), data_types.AttributeId(self.ID), data)
end

function DCOverloadAlarmsMask:set_parent_cluster(cluster)
  self._cluster = cluster
  return self
end

setmetatable(DCOverloadAlarmsMask, {__call = DCOverloadAlarmsMask.new_value})
return DCOverloadAlarmsMask