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
---@module st.zigbee.data_types
local data_types = {}

--- @class st.zigbee.data_types.DataType
--- :abstract:
---
--- A generic class defining the interface shared across all Zigbee data types
--- @field public NAME string pretty print class name
--- @field public ID number the Zigbee data type ID for this data type
local DataType = {}

--- Pack this DataType
--- @return string the byte representation of this DataType length of byte_length
function DataType:_serialize()
  error("Not Implemented", 2)
end

--- Parse this DataType from a string of bytes
--- @param bytes string the bytes containing the st.zigbee.data_types.DataType only byte_length bytes will be consumed extra will be ignored
--- @param field_name string optional name of this field (used when pretty_printing)
--- @return st.zigbee.data_types.DataType the parsed version of DataType
function DataType.deserialize(bytes, field_name)
  error("Not Implemented", 2)
end

--- Get the length in bytes of this DataType
--- @return number the byte length of this DataType
function DataType:get_length()
  error("Not Implemented", 2)
end

--- Format this DataType in a human readable way
--- @return string A human readable string of this DataType
function DataType:pretty_print()
  error("Not Implemented", 2)
end

local dt_mt = {}
dt_mt.__data_type_cache = {}
dt_mt.__index = function(self, key)
  if dt_mt.__data_type_cache[key] == nil then
    if data_types.name_to_id_map[key] ~= nil or key == "ZCLCommandId" or key == "ZigbeeDataType" then
      local req_loc = string.format("st.zigbee.data_types.%s", key)
      dt_mt.__data_type_cache[key] = require(req_loc)
    else
      return nil
    end
  end
  return dt_mt.__data_type_cache[key]
end
setmetatable(data_types, dt_mt)

--- @type table<number, string> This is a set of key value pairs mapping a data type ID to its name
local id_to_name_map = {
  [0x00] = "NoData",
  [0x08] = "Data8",
  [0x09] = "Data16",
  [0x0A] = "Data24",
  [0x0B] = "Data32",
  [0x0C] = "Data40",
  [0x0D] = "Data48",
  [0x0E] = "Data56",
  [0x0F] = "Data64",
  [0x10] = "Boolean",
  [0x18] = "Bitmap8",
  [0x19] = "Bitmap16",
  [0x1A] = "Bitmap24",
  [0x1B] = "Bitmap32",
  [0x1C] = "Bitmap40",
  [0x1D] = "Bitmap48",
  [0x1E] = "Bitmap56",
  [0x1F] = "Bitmap64",
  [0x20] = "Uint8",
  [0x21] = "Uint16",
  [0x22] = "Uint24",
  [0x23] = "Uint32",
  [0x24] = "Uint40",
  [0x25] = "Uint48",
  [0x26] = "Uint56",
  [0x27] = "Uint64",
  [0x28] = "Int8",
  [0x29] = "Int16",
  [0x2A] = "Int24",
  [0x2B] = "Int32",
  [0x2C] = "Int40",
  [0x2D] = "Int48",
  [0x2E] = "Int56",
  [0x2F] = "Int64",
  [0x30] = "Enum8",
  [0x31] = "Enum16",
  [0x38] = "SemiPrecisionFloat",
  [0x39] = "SinglePrecisionFloat",
  [0x3A] = "DoublePrecisionFloat",
  [0x41] = "OctetString",
  [0x42] = "CharString",
  [0x43] = "LongOctetString",
  [0x44] = "LongCharString",
  [0x48] = "Array",
  [0x4C] = "Structure",
  [0x50] = "Set",
  [0x51] = "Bag",
  [0xE0] = "TimeOfDay",
  [0xE1] = "Date",
  [0xE2] = "UtcTime",
  [0xE8] = "ClusterId",
  [0xE9] = "AttributeId",
  [0xEA] = "BacNetOid",
  [0xF0] = "IeeeAddress",
  [0xF1] = "SecurityKey"
}

data_types.id_to_name_map = id_to_name_map

--- @type table<string, number> This is a set of key value pairs mapping a data type name to its ID
data_types.name_to_id_map = {}
for id, name in pairs(data_types.id_to_name_map) do
  data_types.name_to_id_map[name] = id
end

--- This will take the data type ID and return the corresponding class that can be used for parsing/construction
--- @param id number the data type id
--- @return st.zigbee.data_types.DataType the data type class for the corresponding ID
function data_types.get_data_type_by_id(id)
  if data_types.id_to_name_map[id] ~= nil then
    return data_types[data_types.id_to_name_map[id]]
  end
  return nil
end

--- This will take the data type ID and then byte string and parse the data type into a class instance
--- @param data_type_id number the data type id
--- @param buf Reader the bytes representing the data, only the necesary bytes will be consumed additional bytes ignored
--- @param field_name string the field name of the data type
--- @return st.zigbee.data_types.DataType the parsed data type represented in the string arg
function data_types.parse_data_type(data_type_id, buf, field_name)
  local dt = data_types.get_data_type_by_id(data_type_id)
  if dt ~= nil then
    return dt.deserialize(buf, field_name)
  else
    error(string.format("Unknown Zigbee data type: 0x%02X", data_type_id))
  end
  return nil
end

--- Build and/or verify that a value is of appropriate type
--- This is primarily useful in the from_values methods used in constructing messages.  The reason this
--- is useful is it allows us to take a "value" that could be either, the raw value of the desired data
--- type (e.g. a lua number type) or the already built zigbee data type class instance (e.g. a Uint8 <0x05>).
--- This method will then verify that it either is already a constructed type of the correct value OR use
--- the raw value to construct it.  This allows us to easily accept arguments of either type in the
--- constructor functions
--- @param value _ the value for the data type, either the raw type to construct with, or the data type table
--- @param data_type st.zigbee.data_types.DataType The data type class that the value should be, or be constructed into
--- @param name string the constructed data type will have its "field_name" field set to this for proper pretty printing
--- @return st.zigbee.data_types.DataType the constructed data type of the correct value
function data_types.validate_or_build_type(value, data_type, name)
  if value == nil or data_type == nil then
    error(string.format("value and data_type for %s must be non-nil", name or "anonymous"), 2)
  end
  if type(value) == "table" and value.ID ~= data_type.ID then
    error(string.format("Expecting %s (0x%02X) for \"%s\" received %s", data_type.NAME, data_type.ID, (name or data_type.NAME), tostring(value)), 2)
  elseif type(value) == "table" then
    value.field_name = name
    return value
  else
    local status, out_val = pcall(data_type, value)
    if not status then
      error("Error creating " .. (name or data_type.NAME) .. ": " .. tostring(out_val), 2)
    end
    out_val.field_name = name
    return out_val
  end
end

return data_types
