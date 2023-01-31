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
--- @module st.zwave.CommandClass.configuration
--- @alias Configuration st.zwave.CommandClass.configuration
local zw = require "st.zwave"
local Configuration = require "st.zwave.generated.Configuration"
local buf = require "st.zwave.utils.buf"
local utils = require "st.utils"

--- Based upon Lua type and value, infer a corresponding Z-Wave
--- COMMAND_CLASS_CONFIGURATION type.
---
--- @param vtype string Lua type string
--- @param value string|number value for which to infer format
--- @return number Configuration.format enum value
local function _format(vtype, value)
  if vtype == "string" then
    return Configuration.format.BIT_FIELD
  elseif vtype == "number" then
    if value >= -0x80000000 and value <= 0x7FFFFFFF then
      -- SIGNED_INTEGER is default, so we infer this for most cases.
      return Configuration.format.SIGNED_INTEGER
    elseif value > 0x7FFFFFFF and value <= 0xFFFFFFFF then
      -- Only report UNSIGNED_INTEGER for (INT32_MAX,UINT32_MAX) corner case.
      -- Note that we are unable to directly infer type enum.  However, the
      -- library has provision for code to specify this explicitly.
      return Configuration.format.UNSIGNED_INTEGER
    else
      error("Z-Wave integer overflow: " .. value)
    end
  else
    error("unsupported Z-Wave type " .. vtype)
  end
end

do
--- Infer a Z-Wave COMMAND_CLASS_CONFIGURATION type for the passed numerical
--- or string-represented bitmask argument.
---
--- @param value string|number value for which to infer format
--- @return number Configuration.format enum value
local function format(value)
  return _format(type(value), value)
end
buf.Writer.format = format
end

do
--- Return the consensus COMMMAND_CLASS_CONFIGURATION format type of all passed
--- string-represented bitmasks or integers.
---
--- Each argument is encoded as an array of table references which must be built
--- up into table-dereference operations for recursion and interrogation.  For
--- instance, an argument may be of form: { args, "vg1", "vg2", "param1" }.
--- Presuming vg1 is a variant-group array and vg2 is a variant-group array
--- within vg2, and param1 is a parameter literal, consensus interrogation of
--- this would compose into this nested loop:
---
---   for i=1,#vg1 do
---     for j=1,#vg2 do
---       -- evaluate concencus against args["vg1"][i]["vg2"][j]["param1"]
---     end
---   end
---
--- Illegal conditions for which an error is raised:
---   - no arguments passed
---   - any arguments of unsupported types
---   - any arguments of mismatched type
---   - string arguments of differing lengths
---
--- @vararg table 1 or more table-traversal paths to string or number arguments
--- @return number consensus Configuration.format enum value
local function consensus_format(...)
  local _,vtype,_,_,vmax = buf.Writer.consensus_size(...)
  return _format(vtype, vmax)
end
buf.Writer.consensus_format = consensus_format
end

do
--- Read a dynamically-typed COMMAND_CLASS_CONFIGURATION value from the buffer.
---
--- @param format number Configuration.format enum value
--- @param size number buffer read length in bytes
--- @return any value read from the buffer
local function read_typed(self, format, size, ...)
  if format == Configuration.format.SIGNED_INTEGER then
    if size == 1 then
      return self:read_i8(...)
    elseif size == 2 then
      return self:read_be_i16(...)
    elseif size == 4 then
      return self:read_be_i32(...)
    elseif size == 0 then
      --field is expected to be missing
    else
      error("illegal Z-Wave integer size " .. size)
    end
  elseif format == Configuration.format.UNSIGNED_INTEGER or format == Configuration.format.ENUMERATED then
    if size == 1 then
      return self:read_u8(...)
    elseif size == 2 then
      return self:read_be_u16(...)
    elseif size == 4 then
      return self:read_be_u32(...)
    elseif size == 0 then
      --field is expected to be missing
    else
      error("illegal Z-Wave integer size " .. size)
    end
  elseif format == Configuration.format.BIT_FIELD then
    return self:read_bytes(size, ...)
  else
    error("illegal Z-Wave format " .. format)
  end
end
buf.Reader.read_typed = read_typed
end

do
--- Write a dynamically-typed COMMAND_CLASS_CONFIGURATION value to the buffer.
---
--- @param format number Configuration.format enum value
--- @param size number buffer write length in bytes
--- @param val any value to write
local function write_typed(self, format, size, value, ...)
  value = value or not self.strict and 0 or nil
  format = format or self.format(value)
  size = size or self.size(value)
  if format == Configuration.format.SIGNED_INTEGER then
    if size == 1 then
      self:write_i8(value, ...)
    elseif size == 2 then
      self:write_be_i16(value, ...)
    elseif size == 4 then
      self:write_be_i32(value, ...)
    else
      error("illegal Z-Wave integer size " .. size)
    end
  elseif format == Configuration.format.UNSIGNED_INTEGER or format == Configuration.format.ENUMERATED then
    if size == 1 then
      self:write_u8(value, ...)
    elseif size == 2 then
      self:write_be_u16(value, ...)
    elseif size == 4 then
      self:write_be_u32(value, ...)
    else
      error("illegal Z-Wave integer size " .. size)
    end
  elseif format == Configuration.format.BIT_FIELD then
    self:write_bytes(value, ...)
  else
    error("illegal Z-Wave format " .. format)
  end
end
buf.Writer.write_typed = write_typed
end

do
--- Write a dynamically-typed COMMAND_CLASS_CONFIGURATION value to the buffer.
---
--- Allows 0 sized parameters
---
--- @param format number Configuration.format enum value
--- @param size number buffer write length in bytes
--- @param val any value to write
local function write_typed_allow_0(self, format, size, value, ...)
  value = value or not self.strict and 0 or nil
  format = format or self.format(value)
  size = size or self.size(value)
  if format == Configuration.format.SIGNED_INTEGER then
    if size == 1 then
      self:write_i8(value, ...)
    elseif size == 2 then
      self:write_be_i16(value, ...)
    elseif size == 4 then
      self:write_be_i32(value, ...)
    elseif size == 0 then
      --field is expected to be missing
    else
      error("illegal Z-Wave integer size " .. size)
    end
  elseif format == Configuration.format.UNSIGNED_INTEGER or format == Configuration.format.ENUMERATED then
    if size == 1 then
      self:write_u8(value, ...)
    elseif size == 2 then
      self:write_be_u16(value, ...)
    elseif size == 4 then
      self:write_be_u32(value, ...)
    elseif size == 0 then
      --field is expected to be missing
    else
      error("illegal Z-Wave integer size " .. size)
    end
  elseif format == Configuration.format.BIT_FIELD then
    self:write_bytes(value, ...)
  else
    error("illegal Z-Wave format " .. format)
  end
end
buf.Writer.write_typed_allow_0 = write_typed_allow_0
end

Configuration.PropertiesReportV3.serialize = function(self)
  local writer = buf.Writer()
  local args = self.args
  writer:write_be_u16(args.parameter_number)
  writer:write_bits(3, args.size or writer.consensus_size({ args.default_value }, { args.max_value }, { args.min_value }))
  writer:write_bits(3, args.format or writer.consensus_format({ args.default_value }, { args.max_value }, { args.min_value }))
  writer:write_bits(2, 0) -- reserved
  writer:write_typed_allow_0(args.format or writer.consensus_format({ args.default_value }, { args.max_value }, { args.min_value }), args.size or writer.consensus_size({ args.default_value }, { args.max_value }, { args.min_value }), args.min_value)
  writer:write_typed_allow_0(args.format or writer.consensus_format({ args.default_value }, { args.max_value }, { args.min_value }), args.size or writer.consensus_size({ args.default_value }, { args.max_value }, { args.min_value }), args.max_value)
  writer:write_typed_allow_0(args.format or writer.consensus_format({ args.default_value }, { args.max_value }, { args.min_value }), args.size or writer.consensus_size({ args.default_value }, { args.max_value }, { args.min_value }), args.default_value)
  writer:write_be_u16(args.next_parameter_number)
  return writer.buf
end

Configuration.PropertiesReportV4.serialize = function(self)
  local writer = buf.Writer()
  local args = self.args
  writer:write_be_u16(args.parameter_number)
  writer:write_bits(3, args.size or writer.consensus_size({ args.default_value }, { args.max_value }, { args.min_value }))
  writer:write_bits(3, args.format or writer.consensus_format({ args.default_value }, { args.max_value }, { args.min_value }))
  writer:write_bool(args.readonly)
  writer:write_bool(args.altering_capabilities)
  writer:write_typed_allow_0(args.format or writer.consensus_format({ args.default_value }, { args.max_value }, { args.min_value }), args.size or writer.consensus_size({ args.default_value }, { args.max_value }, { args.min_value }), args.min_value)
  writer:write_typed_allow_0(args.format or writer.consensus_format({ args.default_value }, { args.max_value }, { args.min_value }), args.size or writer.consensus_size({ args.default_value }, { args.max_value }, { args.min_value }), args.max_value)
  writer:write_typed_allow_0(args.format or writer.consensus_format({ args.default_value }, { args.max_value }, { args.min_value }), args.size or writer.consensus_size({ args.default_value }, { args.max_value }, { args.min_value }), args.default_value)
  writer:write_be_u16(args.next_parameter_number)
  writer:write_bool(args.advanced)
  writer:write_bool(args.no_bulk_support)
  writer:write_bits(6, 0) -- reserved1
  return writer.buf
end

--- @class st.zwave.CommandClass.Configuration.SetV3Args
--- @alias SetV3Args st.zwave.CommandClass.Configuration.SetV3Args
--- @field public parameter_number integer [0,255]
--- @field public size integer [0,7]
--- @field public default boolean
--- @field public format integer [0,3] Configuration.format enum
--- @field public configuration_value integer [-2147483648,2147483647]
local SetV3Args = {}

--- @class st.zwave.CommandClass.Configuration.SetV3:st.zwave.Command
--- @alias SetV3 st.zwave.CommandClass.Configuration.SetV3
---
--- v3 and forward-compatible v4 CONFIGURATION_SET
---
--- @field public cmd_class number 0x70
--- @field public cmd_id number 0x04
--- @field public version number 1
--- @field public args st.zwave.CommandClass.Configuration.SetV3Args command-specific arguments
local SetV3 = {}
setmetatable(SetV3, {
  __index = zw.Command,
  __call = function(cls, self, ...)
    local mt = {
      __index = function(tbl, key)
        if key == "payload" then
          return tbl:serialize()
        else
          return cls[key]
        end
      end,
      __tostring = zw.Command.pretty_print,
      __eq = zw.Command.equals
    }
    local instance = setmetatable({}, mt)
    instance:init(self, ...)
    return instance
  end,
})

--- Initialize a v3 and forward-compatible v4 CONFIGURATION_SET object.
---
--- @param module st.zwave.CommandClass.Configuration command class module instance
--- @param args st.zwave.CommandClass.Configuration.SetV3Args command-specific arguments
function SetV3:init(module, args, ...)
  zw.Command._parse(self, module, zw.CONFIGURATION, Configuration.SET, 3, args, ...)
end

--- Serialize v3 or forward-compatible v4 CONFIGURATION_SET arguments.
---
--- @return string serialized payload
function SetV3:serialize()
  local writer = buf.Writer()
  local args = self.args
  writer:write_u8(args.parameter_number)
  writer:write_bits(3, args.size or writer.size(args.configuration_value))
  writer:write_bits(4, 0) -- reserved
  writer:write_bool(args.default)
  writer:write_typed(args.format, args.size or writer.size(args.configuration_value), args.configuration_value)
  return writer.buf
end

--- Deserialize a v3 or forward-compatible v4 CONFIGURATION_SET payload.
---
--- @return st.zwave.CommandClass.Configuration.SetV3Args deserialized arguments
function SetV3:deserialize()
  local reader = buf.Reader(self.payload)
  reader:read_u8("parameter_number")
  reader:read_bits(3, "size")
  reader:read_bits(4) -- reserved
  reader:read_bool("default")
  reader:read_typed((self.args and self.args.format) or Configuration.format.SIGNED_INTEGER, reader.parsed.size, "configuration_value")
  return reader.parsed
end

--- Return a deep copy of self.args, merging defaults for unset, but required parameters.
---
--- @param self st.zwave.CommandClass.Configuration.SetV3
--- @return st.zwave.CommandClass.Configuration.SetV3Args
function SetV3._defaults(self)
  local args = {}
  args.parameter_number = self.args.parameter_number or 0
  args.default = self.args.default or false
  args.configuration_value = self.args.configuration_value or 0
  args.format = self.args.format or Configuration.format.SIGNED_INTEGER
  return args
end

--- Return a deep copy of self.args, merging defaults for all unset parameters.
---
--- @param self st.zwave.CommandClass.Configuration.SetV3
--- @return st.zwave.CommandClass.Configuration.SetV3Args
function SetV3._template(self)
  local args = self:_defaults()
  local writer = buf.Writer()
  args.size = args.size or writer.size(args.configuration_value)
  return args
end

--- Set defaults for any required, but unset arguments.
---
--- @param self st.zwave.CommandClass.Configuration.SetV3
function SetV3._set_defaults(self)
  local defaults = self:_defaults()
  utils.merge(self.args, defaults)
end

--- Set const reflectors to allow enum stringification.
---
--- @param self st.zwave.CommandClass.Configuration.SetV3
function SetV3._set_reflectors(self)
end

Configuration.SetV3 = SetV3
-- V3 and V4 use the same serde operation
Configuration._lut[3][Configuration.SET] = Configuration.SetV3
Configuration._lut[4][Configuration.SET] = Configuration.SetV3

return Configuration
