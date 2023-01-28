-- Copyright 2022 SmartThings
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
---@module st.data_types
local data_types = {}

--- @class st.matter.data_types.DataType
--- :abstract:
---
--- A generic class defining the interface shared across all Matter data types
--- @field public NAME string pretty print class name
--- @field public ID number the Matter data type ID for this data type
local DataType = {}

--- Pack this DataType
--- @return string the byte representation of this DataType length of byte_length
function DataType:serialize() error("Not Implemented", 2) end

--- Parse this DataType from a string of bytes
--- @param bytes string the bytes containing the st.matter.data_types.DataType only byte_length bytes will be consumed extra will be ignored
--- @param field_name string optional name of this field (used when pretty_printing)
--- @return st.matter.data_types.DataType the parsed version of DataType
function DataType.deserialize(bytes, field_name) error("Not Implemented", 2) end

--- Get the length in bytes of this DataType
--- @return number the byte length of this DataType
function DataType:get_length() error("Not Implemented", 2) end

--- Format this DataType in a human readable way
--- @return string A human readable string of this DataType
function DataType:pretty_print() error("Not Implemented", 2) end

local dt_mt = {}
dt_mt.__data_type_cache = {}
dt_mt.__index = function(self, key)
  if dt_mt.__data_type_cache[key] == nil then
    if data_types.name_to_id_map[key] ~= nil then
      local req_loc = string.format("st.matter.data_types.%s", key)
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

  [0x00] = "Int8",
  [0x01] = "Int16",
  [0x02] = "Int32",
  [0x03] = "Int64",

  [0x04] = "Uint8",
  [0x05] = "Uint16",
  [0x06] = "Uint32",
  [0x07] = "Uint64",

  [0x08] = "Boolean",

  [0x0A] = "SinglePrecisionFloat",
  [0x0B] = "DoublePrecisionFloat",

  [0x0C] = "UTF8String1",
  [0x0D] = "UTF8String2",
  [0x0E] = "UTF8String4",
  [0x0F] = "UTF8String8",

  [0x10] = "OctetString1",
  [0x11] = "OctetString2",
  [0x12] = "OctetString4",
  [0x13] = "OctetString8",

  [0x14] = "Null",

  [0x15] = "Structure",
  [0x16] = "Array",
  [0x17] = "List",
  [0x18] = "EndOfContainer",
}

data_types.id_to_name_map = id_to_name_map

--- @type table<string, number> This is a set of key value pairs mapping a data type name to its ID
data_types.name_to_id_map = {}
for id, name in pairs(data_types.id_to_name_map) do data_types.name_to_id_map[name] = id end

--- This will take the data type ID and return the corresponding class that can be used for parsing/construction
--- @param id number the data type id
--- @return st.matter.data_types.DataType the data type class for the corresponding ID
function data_types.get_data_type_by_id(id)
  if data_types.id_to_name_map[id] ~= nil then return data_types[data_types.id_to_name_map[id]] end
  return nil
end

--- This will take the data type ID and then byte string and parse the data type into a class instance
--- @param data_type_id number the data type id
--- @param buf Reader the bytes representing the data, only the necesary bytes will be consumed additional bytes ignored
--- @param field_name string the field name of the data type
--- @return st.matter.data_types.DataType the parsed data type represented in the string arg
function data_types.parse_data_type(data_type_id, buf, field_name)
  local dt = data_types.get_data_type_by_id(data_type_id)
  if dt ~= nil then
    return dt.deserialize(buf, field_name)
  else
    error(string.format("Unknown Matter data type: 0x%02X", data_type_id))
  end
  return nil
end

--- Build and/or verify that a value is of appropriate type
--- This is primarily useful in the from_values methods used in constructing messages.  The reason this
--- is useful is it allows us to take a "value" that could be either, the raw value of the desired data
--- type (e.g. a lua number type) or the already built Matter data type class instance (e.g. a Uint8 <0x05>).
--- This method will then verify that it either is already a constructed type of the correct value OR use
--- the raw value to construct it.  This allows us to easily accept arguments of either type in the
--- constructor functions
---
--- Note that it is valid in matter for an object of type Uint16 that can fit into a Uint8 to be encoded
--- as a Uint8 instead of a Uint16.
---
---@param value any the value for the data type, either the raw type to construct with, or the data type table
---@param data_type st.matter.data_types.DataType The data type class that the value should be, or be constructed into
---@param name string the constructed data type will have its "field_name" field set to this for proper pretty printing
---@return st.matter.data_types.DataType the constructed data type of the correct value
function data_types.validate_or_build_type(value, data_type, name)
  name = name or data_type.NAME
  local is_subtype = function(intented_type, value)
    for _, sub_type in ipairs(intented_type.SUBTYPES or {}) do
      if sub_type == value.NAME then
        return true
      end
    end
    return false
  end

  if type(value) == "table" and value.ID ~= nil and value.ID ~= data_type.ID and not is_subtype(data_type, value)  then
    error(
      string.format(
        "Expecting %s (0x%02X) for \"%s\" received %s", data_type.NAME, data_type.ID, name,
          tostring(value)
      ), 2
    )
  elseif type(value) == "table" and value.ID ~= nil then
    value.field_name = name
    if data_type.augment_type and getmetatable(value) ~= getmetatable(data_type) then
      data_type:augment_type(value, data_type)
    end
    return value
  else
    local status, out_val = pcall(data_type, value)
    if not status then error("Error creating " .. name .. ": " .. tostring(out_val)) end
    out_val.field_name = name
    out_val.ID = data_type.ID
    return out_val
  end
end

--- It returns the properties of an element type, if it exists in a subtypes table.
--- @param subtypes Table containing st.matter.data_types.NAME elements
--- @param element_type integer the Element Type
--- @return properties of the Element Type, if found
function data_types.get_subtype_length(subtypes, element_type)
  local type_length = nil
  local mantissa_bit_length = nil
  local exponent_bit_length = nil
  if type(subtypes) == "table" then
    for _, v in pairs(subtypes) do
      if data_types[v].ID == element_type then
        type_length, mantissa_bit_length, exponent_bit_length = data_types[v].byte_length,
          data_types[v].mantissa_bit_length, data_types[v].exponent_bit_length
        break
      end
    end
  end
  return type_length, mantissa_bit_length, exponent_bit_length
end

return data_types
