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
-- Buffer required by all parsers
local buf_lib = require "st.buf"

local data_types = require "st.matter.data_types"

--- TLV Parser Masks
local TAG_CONTROL_MASK = 0xE0
local TAG_ELEMENT_TYPE_MASK = 0x1F

--- TLV Parser Tokens
-- Structure ends with 0x18 End of Container
local TAG_END_CONTAINER = 0x18

-- The tag control field identifies the form of tag assigned to the element (including none) as well as
-- the encoding of the tag octets.
local FORM_ANONYMOUS_TAG = {code = 0x00, type = nil}
local FORM_CONT_SPEC_TAG = {code = 0x20, type = data_types.Uint8.ID}
local FORM_COMM_PROF_TAG_2 = {code = 0x40, type = data_types.Uint16.ID}
local FORM_COMM_PROF_TAG_4 = {code = 0x60, type = data_types.Uint32.ID}
local FORM_IMPL_PROF_TAG_2 = {code = 0x80, type = data_types.Uint16.ID}
local FORM_FULL_QUAL_TAG_8 = {code = 0xA0, type = data_types.Uint32.ID}
local FORM_FULL_QUAL_TAG_6 = {code = 0xC0, type = data_types.Uint16.ID}
local FORM_FULL_QUAL_TAG_8 = {code = 0xE0, type = data_types.Uint32.ID}

-------------------------------------------------------------------------------
--- Matter TLV Lua Parser Module.
--- @class st.matter.TLV.TLVParser
-------------------------------------------------------------------------------

--- @module TLVParser module
local TLVParser = {}

--- Utility function: Convert bytes (network order) to a 32-bit two's
--- complement integer
---
--- @param ... any
--- @return integer
function TLVParser.convert_bytes_to_int(...)

  local t = table.pack(...)

  local n = 0

  for i = 1, t.n do n = n + t[i] * 2 ^ ((i * 8 - 1) - 7) end

  n = (n > 2 ^ ((t.n * 8 - 1))) and (n - 2 ^ ((t.n * 8))) or n

  return n

end

--- Utility function: Returns the length of tag encoding
---
--- @param tag_control any
--- @return any
function TLVParser.get_tag_encoding_length(tag_control)

  local tagControls = {
    -- "Anonymous Tag Form"
    [0] = 0,

    -- "Context-specific Tag Form"
    [1] = 1,

    -- "Common Profile Tag Form"
    [2] = 2,

    -- "Common Profile Tag Form"
    [3] = 4,

    -- "Implicit Profile Tag Form"
    [4] = 2,

    -- "Implicit Profile Tag Form"
    [5] = 4,

    -- "Fully-qualified Tag Form"
    [6] = 6,

    -- "Fully-qualified Tag Form"
    [7] = 8,
  }

  return tagControls[tag_control]
end

--- Returns a parser for a Matter element type
---
--- @param element_type any
--- @return any
function TLVParser.parsers_from_element_type(element_type)

  local parsers = {
    -- Signed Integer, 1-octet value
    [0] = "Int8",

    -- Signed Integer, 2-octet value
    [1] = "Int16",

    -- Signed Integer, 4-octet value
    [2] = "Int32",

    -- Signed Integer, 8-octet value
    [3] = "Int64",

    -- Unsigned Integer, 1-octet value
    [4] = "Uint8",

    -- Unsigned Integer, 2-octet value
    [5] = "Uint16",

    -- Unsigned Integer, 4-octet value
    [6] = "Uint32",

    -- Unsigned Integer, 8-octet value
    [7] = "Uint64",

    -- Boolean False
    [8] = "Boolean",

    -- Boolean True
    [9] = "Boolean",

    -- Floating Point Number, 4-octet value
    [10] = "SinglePrecisionFloat",

    -- Floating Point Number, 8-octet value
    [11] = "DoublePrecisionFloat",

    -- UTF-8 String, 1-octet length
    [12] = "UTF8String1",

    -- UTF-8 String, 2-octet length
    [13] = "UTF8String2",

    -- UTF-8 String, 4-octet length
    [14] = "UTF8String4",

    -- UTF-8 String, 8-octet length
    [15] = "UTF8String8",

    -- Octet String, 1-octet length
    [16] = "OctetString1",

    -- Octet String, 2-octet length
    [17] = "OctetString2",

    -- Octet String, 4-octet length
    [18] = "OctetString4",

    -- Octet String, 8-octet length
    [19] = "OctetString8",

    -- Null type
    [20] = "Null",

    -- Structure
    [21] = "Structure",

    -- Array
    [22] = "Array",
  }

  return parsers[element_type]
end

--- Decodes Primitive TLV data types
---
--- @param buf any
--- @param control_octet_element_type any
--- @param include_control_octet boolean
--- @return table
function TLVParser.decode_tlv_primititive(buf, control_octet_element_type, include_control_octet)

  local parser = data_types[TLVParser.parsers_from_element_type(control_octet_element_type)]
  return parser.deserialize(buf, include_control_octet)
end

--- Parses a Matter TLV (Type-Length-Value) string in hex format.
---
--- @param tlv_stream_string string the TLV input is provided as a hex string.
--- @return table|nil the decoded TLV string, or nil if the string is invalid tlv
function TLVParser.decode_tlv(tlv_stream_string)

  if #tlv_stream_string == 0 then return nil end
  local buf = buf_lib.Reader(tlv_stream_string)

  local control_octet = buf:peek_u8()
  local control_octet_tag_control = control_octet & TLVParser.TAG_CONTROL_MASK
  local control_octet_element_type = control_octet & TLVParser.TAG_ELEMENT_TYPE_MASK

  local parser = data_types[TLVParser.parsers_from_element_type(control_octet_element_type)]
  if parser == nil then
    return nil
  end
  return parser.deserialize(buf, true)
end

TLVParser.TAG_END_CONTAINER = TAG_END_CONTAINER
TLVParser.TAG_CONTROL_MASK = TAG_CONTROL_MASK
TLVParser.TAG_ELEMENT_TYPE_MASK = TAG_ELEMENT_TYPE_MASK
TLVParser.FORM_ANONYMOUS_TAG = FORM_ANONYMOUS_TAG
TLVParser.FORM_CONT_SPEC_TAG = FORM_CONT_SPEC_TAG
TLVParser.FORM_COMM_PROF_TAG_2 = FORM_COMM_PROF_TAG_2
TLVParser.FORM_COMM_PROF_TAG_4 = FORM_COMM_PROF_TAG_4
TLVParser.FORM_IMPL_PROF_TAG_2 = FORM_IMPL_PROF_TAG_2
TLVParser.FORM_FULL_QUAL_TAG_8 = FORM_FULL_QUAL_TAG_8
TLVParser.FORM_FULL_QUAL_TAG_6 = FORM_FULL_QUAL_TAG_6
TLVParser.FORM_FULL_QUAL_TAG_8 = FORM_FULL_QUAL_TAG_8

return TLVParser
