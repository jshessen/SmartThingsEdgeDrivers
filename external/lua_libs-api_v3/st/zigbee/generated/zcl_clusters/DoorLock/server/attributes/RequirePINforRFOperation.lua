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

--- @class st.zigbee.zcl.clusters.DoorLock.RequirePINforRFOperation
--- @alias RequirePINforRFOperation
---
--- @field public ID number 0x0033 the ID of this attribute
--- @field public NAME string "RequirePINforRFOperation" the name of this attribute
--- @field public data_type st.zigbee.data_types.Boolean the data type of this attribute
local RequirePINforRFOperation = {
  ID = 0x0033,
  NAME = "RequirePINforRFOperation",
  base_type = data_types.Boolean,
}

function RequirePINforRFOperation:augment_type(base_type_obj)
  -- Is there a better way to handle this?
  if base_type_obj.NAME ~= self.base_type.NAME then
    setmetatable(base_type_obj, getmetatable(self.base_type))
  end
  base_type_obj.field_name = self.NAME
end

function RequirePINforRFOperation.pretty_print(value_obj)
  RequirePINforRFOperation.base_type.pretty_print(value_obj)
end

--- @function RequirePINforRFOperation:build_test_attr_report
---
--- Build a Rx Zigbee message as if a device reported this attribute
--- @param device st.zigbee.Device
--- @param data st.zigbee.data_types.Boolean the attribute value
--- @return st.zigbee.ZigbeeMessageRx containing an AttributeReport body
RequirePINforRFOperation.build_test_attr_report = cluster_base.build_test_attr_report

--- @function RequirePINforRFOperation:build_test_read_attr_response
---
--- Build a Rx Zigbee message as if a device sent a read response for this attribute
--- @param device st.zigbee.Device
--- @param data st.zigbee.data_types.Boolean the attribute value
--- @return st.zigbee.ZigbeeMessageRx containing an ReadAttributeResponse body
RequirePINforRFOperation.build_test_read_attr_response = cluster_base.build_test_read_attr_response

--- Create a Boolean object of this attribute with any additional features provided for the attribute
---
--- This is also usable with the RequirePINforRFOperation(...) syntax
---
--- @vararg vararg the values needed to construct a Boolean
--- @return st.zigbee.data_types.Boolean
function RequirePINforRFOperation:new_value(...)
    local o = self.base_type(table.unpack({...}))
    self:augment_type(o)
    return o
end

--- Construct a st.zigbee.ZigbeeMessageTx to read this attribute from a device
---
--- @param device st.zigbee.Device
--- @return st.zigbee.ZigbeeMessageTx containing a ReadAttribute body
function RequirePINforRFOperation:read(device)
    return cluster_base.read_attribute(device, data_types.ClusterId(self._cluster.ID), data_types.AttributeId(self.ID))
end

--- Construct a st.zigbee.ZigbeeMessageTx to configure this attribute for reporting on a device
---
--- @param device st.zigbee.Device
--- @param min_rep_int number|st.zigbee.data_types.Uint16 the minimum interval allowed between reports of this attribute
--- @param max_rep_int number|st.zigbee.data_types.Uint16 the maximum interval allowed between reports of this attribute
--- @return st.zigbee.ZigbeeMessageTx containing a ConfigureReporting body
function RequirePINforRFOperation:configure_reporting(device, min_rep_int, max_rep_int)
  local min = data_types.validate_or_build_type(min_rep_int, data_types.Uint16, "minimum_reporting_interval")
  local max = data_types.validate_or_build_type(max_rep_int, data_types.Uint16, "maximum_reporting_interval")
  local rep_change = nil
  return cluster_base.configure_reporting(device, data_types.ClusterId(self._cluster.ID), data_types.AttributeId(self.ID), data_types.ZigbeeDataType(self.base_type.ID), min, max, rep_change)
end

--- Write a value to this attribute on a device
---
--- @param device st.zigbee.Device
--- @param value st.zigbee.data_types.Boolean the value to write
function RequirePINforRFOperation:write(device, value)
  local data = data_types.validate_or_build_type(value, self.base_type)
  self:augment_type(data)
  return cluster_base.write_attribute(device, data_types.ClusterId(self._cluster.ID), data_types.AttributeId(self.ID), data)
end

function RequirePINforRFOperation:set_parent_cluster(cluster)
  self._cluster = cluster
  return self
end

setmetatable(RequirePINforRFOperation, {__call = RequirePINforRFOperation.new_value})
return RequirePINforRFOperation
