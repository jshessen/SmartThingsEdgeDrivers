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
local buf = require "st.buf"
local utils = require "st.utils"

--- @module st.zwave.utils.buf
--- @alias zwbuf st.zwave.utils.buf
local zwbuf = {}

--- @class st.zwave.utils.buf.Reader
--- @alias Reader st.zwave.utils.buf.Reader
local Reader = {}
Reader.__index = Reader
setmetatable(Reader, {
  __index = buf.Reader,
  __tostring = buf.Writer.pretty_print,
  __call = function(cls, ...)
    local self = setmetatable({}, cls)
    self:init(...)
    return self
  end,
})

--- @param buffer string
function Reader:init(buffer)
  buf.Reader.init(self, buffer)
end

--- @class st.zwave.utils.buf.Writer
--- @alias Writer st.zwave.utils.buf.Writer
local Writer = {}
Writer.__index = Writer
setmetatable(Writer, {
  __index = buf.Writer,
  __tostring = buf.Writer.pretty_print,
  __call = function(cls, ...)
    local self = setmetatable({}, cls)
    self:init(...)
    return self
  end,
})

--- Initialize an instance of a Z-Wave buffer writer.
function Writer:init()
  buf.Writer.init(self)
end

--- Overload buf library write_bool to provide a int-to-bool translation.
---
--- @param value boolean|number value to write; 1/0 are translated to true/false
function Writer:write_bool(value, ...)
  if type(value) == "number" then
    buf.Writer.write_bits(self, 1, value, ...)
  else
    buf.Writer.write_bool(self, value, ...)
  end
end

--- Return the math.type or type of the passed value.  Float values that can be
--- losslessly converted to an integer are declared "integer".
---
--- @param value number number for which to determine type
--- @return string math.type or type
local function _type(value)
  if     type(value) == "number"
     and value >= math.mininteger
     and value <= math.maxinteger
     and math.floor(value) == value then
    return "integer"
  elseif type(value) == "number" then
    return "float"
  else
    return type(value)
  end
end

local FLOAT_BYTES = 4

--- Return the number of bytes needed to represent the passed number or string.
---
--- @param value number|string value for which to return size in bytes
--- @return number size in bytes
function Writer.size(value)
  value = value or 0
  if _type(value) == "float" then
    -- Value must be represented as floating point.  By default, we encode all
    -- floating point numbers with a full 32-bit significand.
    return FLOAT_BYTES
  elseif _type(value) == "integer" then
    if value >= -0x80 and value <= 0x7F then
        return 1
    elseif value >= -0x8000 and value <= 0x7FFF then
      return 2
    elseif value >= -0x80000000 and value <= 0xFFFFFFFF then -- bound to INT32_MIN,UINT32_MAX
      return 4
    else
      return 8
    end
  elseif _type(value) == "string" then
    return value:len()
  else
    error("unsupported type " .. type(value))
  end
end

--- Compute the width of the passed number's non-fractional component in bits.
---
--- @param value number value for which to compute bit-width
--- @return number width in bits
local function _width(value)
  assert(type(value) == "number", "value must be number")
  value = math.floor(value)
  local width = 1
  while value ~= -1 and value ~= 0 do
    if value < 0 then
      value = value >> 1
      value = value + math.mininteger
    else
      value = value >> 1
    end
    width = width + 1
  end
  return width
end

--- Determine the maximum negated decimal exponent in the range [0,7] that may
--- be used to represent the passed value.  We encode decimal floating point
--- values with a 32-bit 2's complement significand.  The maximum negated
--- decimal exponent is therefore bound by the bit-width of the non-fractional
--- component of the passed value.
---
--- @param value number number for which to compute decimal-float-encoded precision
--- @param size number optional size override parameter for variable-width floats
--- @return number negated decimal exponent in the range [0,7], or nil if the passed value is not a number
local function _precision(value, size)
  value = value or 0
  if type(value) ~= "number" then
    return nil
  end
  size = size or FLOAT_BYTES
  local clrsb = size * 8 - _width(value)
  return math.min(7, math.floor(math.log(1 << clrsb, 10)))
end

--- If the passed value has a fractional component, determine the maximum
--- negated decimal exponent in the range [0,7] that may be used to represent
--- it.  If the value has no fractional component or is not a number, return
--- nil.
---
--- @param value number number for which to compute decimal-float-encoded precision
--- @return number negated decimal exponent in the range [0,7]
function Writer.precision(value, ...)
  return _type(value) == "float" and _precision(value, ...) or 0
end

--- Determine whether the passed argument is an array-like table.  array-like
--- tables are those for which length can be measured with #, which means an
--- index [1] is present.
---
--- @param value any argument to evaluate
--- @return boolean true if the passed argument is an array-like table, false if it is not
local function _array_like(value)
  if type(value) == "table" and #value > 0 then
    return true
  else
    return false
  end
end

--- Recurse through a nested table dereference path and compute a consensus
--- size, type, precision, min and max for all leaves.  Leaves must be fixed or
--- floating point Z-Wave numbers or string-represented bitmasks.  At each step,
--- the base table may be an array-like table.  If so, iterate across all
--- indices for recursion.
---
--- @param base table base table into which to recurse
--- @param key string base table key to dereference
--- @vararg string one or more additional strings for recursion
--- @return number conensus size
--- @return string type
--- @return number precision
--- @return number min
--- @return number max
local function rconsensus_size(base, key, ...)
  base = base or 0
  if key == nil then
    return Writer.size(base),_type(base),_precision(base),base,base
  elseif _array_like(base) then
    local asize,atype,aprecision,amin,amax
    for i=1,#base do
      local vsize,vtype,vprecision,vmin,vmax = rconsensus_size(base[i][key], ...)
      -- Promote mixed integers and floats to float.
      atype = atype == "integer" and vtype == "float" and "float" or atype
      vtype = vtype == "integer" and atype == "float" and "float" or vtype
      assert(atype == nil or atype == vtype, "consensus broken: type mismatch")
      atype = vtype
      if atype == "integer" or atype == "float" then
        if asize == nil then
          asize = vsize
          amin = vmin
          amax = vmax
          aprecision = vprecision
        end
        amin = math.min(amin, vmin)
        amax = math.max(amax, vmax)
        -- We must choose a length that's wide enough for all passed numbers.
        asize = math.max(asize, vsize)
        -- We must choose a precision that's small enough for all passed numbers.
        aprecision = math.min(aprecision, vprecision)
      elseif atype == "string" then
        assert(asize == nil or asize == vsize, "consensus broken: size mismatch")
        asize = vsize
      else
        error("unsupported type " .. atype)
      end
    end
    return asize,atype,aprecision,amin,amax
  else
    return rconsensus_size(base[key], ...)
  end
end

--- Return the consensus size and precision of all passed Z-Wave number or
--- string-represented bitmask arguments.  Supported Z-Wave numbers are 1, 2,
--- or 4-byte 2's complement integers or decimal floating point numbers with 1,
--- 2 or 4-byte significand and 3-bit negated decimal exponent.
---
--- Each argument is encoded as an array of table references which must be built
--- up into table-dereference operations for recursion and interrogation.  for
--- instance, an argument may be of form: { args, "vg1", "vg2", "param1" }.
--- presuming vg1 is a variant-group array and vg2 is a variant-group array
--- within vg2, and param1 is a parameter literal, consensus interrogation of
--- this would compose into this nested loop:
---
---   for i=1,#vg1 do
---     for j=1,#vg2 do
---       -- evaluate consensus against args["vg1"][i]["vg2"][j]["param1"]
---     end
---   end
---
--- illegal conditions for which an error is raised:
---   - no arguments passed
---   - any arguments of unsupported types
---
--- @vararg table 1 or more table-traversal paths to string, table or number arguments
--- @return number consensus size
--- @return string type
--- @retrn number precision
--- @return number min
--- @return number max
function Writer.consensus_size(...)
  local asize,atype,aprecision,amin,amax
  for i=1,select('#', ...) do
    local v = select(i, ...)
    local vsize,vtype,vprecision,vmin,vmax = rconsensus_size(table.unpack(v))
    -- Promote mixed integers and floats to float.
    atype = atype == "integer" and vtype == "float" and "float" or atype
    vtype = vtype == "integer" and atype == "float" and "float" or vtype
    assert(atype == nil or atype == vtype, "consensus broken: type mismatch")
    atype = vtype
    if atype == "integer" or atype == "float" then
      if asize == nil then
        asize = vsize
        amin = vmin
        amax = vmax
        aprecision = vprecision
      end
      amin = math.min(amin, vmin)
      amax = math.max(amax, vmax)
      -- We must choose a length that's wide enough for all passed numbers
      asize = math.max(asize, vsize)
      -- We must choose a precision that's small enough for all passed numbers
      aprecision = math.min(aprecision, vprecision)
    elseif atype == "string" then
      assert(asize == nil or asize == vsize, "consensus broken: size mismatch")
      asize = vsize
    else
      error("unsupported type " .. atype)
    end
  end
  if asize == nil then
    error("no arguments passed")
  end
  aprecision = atype == "float" and aprecision or nil
  atype = (atype == "float" or atype == "integer") and "number" or atype
  return asize,atype,aprecision,amin,amax
end

--- Return the consensus precision of all passed Z-Wave number or
--- string-represented bitmask arguments.  Precision is the maximum negated
--- decimal exponent in the range [0,7] for which the non-fractional component
--- of all numerical arguments will not overflow within the bounds of a 32-bit
--- 2's complement significand.  If no arguments require floating point
--- representation, nil is returned.
---
--- Each argument is encoded as an array of table references which must be built
--- up into table-dereference operations for recursion and interrogation.  for
--- instance, an argument may be of form: { args, "vg1", "vg2", "param1" }.
--- presuming vg1 is a variant-group array and vg2 is a variant-group array
--- within vg2, and param1 is a parameter literal, consensus interrogation of
--- this would compose into this nested loop:
---
---   for i=1,#vg1 do
---     for j=1,#vg2 do
---       -- evaluate consensus against args["vg1"][i]["vg2"][j]["param1"]
---     end
---   end
---
--- illegal conditions for which an error is raised:
---   - no arguments passed
---   - any arguments of unsupported types
---
--- @vararg table 1 or more table-traversal paths to string, table or number arguments
--- @return number consensus precision of all passed arguments
function Writer.consensus_precision(...)
  local _,_,precision = Writer.consensus_size(...)
  return precision or 0
end

--- Return the length of the passed string or array-like table.
---
--- @param arg string|table argument for which to return length
--- @return number argument length
function Writer.length(arg)
  if arg == nil then
    return 0
  elseif type(arg) == "string" then
    return arg:len()
  elseif type(arg) == "table" then
    return #arg
  else
    error("illegal argument type " .. type(arg))
  end
end

--- Recurse through a nested table dereference path and compute a consensus
--- length for all leaves.  Leaves must be strings or array-like tables.  At
--- each step, the base table may be an array-like table.  If so, iterate
--- across all indices for recursion.
---
--- @param base table base table into which to recurse
--- @param key string base table key to dereference
--- @vararg one or more additional strings for recursion
--- @return number consensus length
--- @return  number consensus type
local function rconsensus_length(base, key, ...)
  if key == nil then
    return Writer.length(base),type(base)
  elseif _array_like(base) then
    local alen = nil
    local atype = nil
    for i=1,#base do
      local vlen,vtype = rconsensus_length(base[i][key], ...)
      assert(alen == nil or alen == vlen, "consensus broken: arguments differ in length")
      assert(atype == nil or atype == vtype, "consensus broken: mismatched argument type")
      alen = vlen
      atype = vtype
    end
    return alen,atype
  else
    return rconsensus_length(base[key], ...)
  end
end

--- Return the consensus length of all passed strings or array-like tables.
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
---       -- evaluate consensus against args["vg1"][i]["vg2"][j]["param1"]
---     end
---   end
---
--- Illegal conditions for which an error is raised:
---   - no arguments passed
---   - any arguments of unsupported types
---   - any arguments of mismatched type
---   - any arguments of differing lengths
---
--- @vararg table 1 or more table-traversal paths to string or array-like table arguments
--- @return number consensus length of all passed arguments
Writer.consensus_length = function(...)
  local alen,atype = nil,nil
  for i=1,select('#', ...) do
    local v = select(i, ...)
    local vlen,vtype = rconsensus_length(table.unpack(v))
    assert(alen == nil or alen == vlen, "consensus broken: arguments differ in length")
    assert(atype == nil or atype == vtype, "consensus broken: mismatched argument type")
    alen = vlen
    atype = vtype
  end
  if alen == nil then
    error("no arguments passed")
  end
  return alen
end

--- Read a variable-width decimal Z-Wave float from the buffer.  Variable-width
--- Z-Wave floats comprise a big-endian 2's complement 8, 16 or 32-bit
--- significand and negated decimal exponent in the range [0,7].
---
--- @param size number width of the significand in bytes
--- @param precision number negated decimal exponent, or nil for none
--- @return number parsed Z-Wave float
function Reader:read_vfloat(size, precision, ...)
  local value
  if size == 1 then
    value = self:read_i8(nil, nil, ...)
  elseif size == 2 then
    value = self:read_be_i16(nil, nil, ...)
  elseif size == 4 then
    value = self:read_be_i32(nil, nil, ...)
  else
    error("illegal Z-Wave integer size " .. size)
  end
  if precision ~= nil and precision ~= 0 then
    value = value * 10^(-precision)
  end
  self:store(value, ...)
  return value
end

--- Write a variable-width decimal Z-Wave float to the buffer.  Variable-width
--- Z-Wave floats comprise a big-endian 2's complement 8, 16 or 32-bit
--- significand and negated decimal exponent in the range [0,7].
---
--- @param size number width of the significand in bytes
--- @param precision number negated decimal exponent, or nil for none
--- @param value number Z-Wave float to write
function Writer:write_vfloat(size, precision, value, ...)
  assert(type(value) == "number", "value must be a number")
  size = size or self.size(value)
  precision = precision or self.precision(value)
  if precision ~= nil and precision ~= 0 then
    value = value * 10^precision
  end
  value = math.floor(value)
  if size == 1 then
    self:write_i8(value, ...)
  elseif size == 2 then
    self:write_be_i16(value, ...)
  elseif size == 4 then
    self:write_be_i32(value, ...)
  else
    error("illegal Z-Wave integer size " .. size)
  end
end

--- Read a fixed-width decimal Z-Wave float from the buffer.  Fixed-width
--- Z-Wave floats comprise a big-endian 32-bit 2's complement significan and
--- negated decimal exponent in the range [0,7].
---
--- @param precision number negated decimal exponent, or nil for none
--- @return number parsed Z-Wave float
function Reader:read_float(precision, ...)
  return self:read_vfloat(FLOAT_BYTES, precision, ...)
end

--- Write a fixed-width decimal Z-Wave float to the buffer.  Fixed-width
--- Z-Wave floats comprise a big-endian 32-bit 2's complement significand and
--- negated decimal exponent in the range [0,7].
---
--- @param precision number negated decimal exponent, or nil for none
--- @param value number Z-Wave float to write
function Writer:write_float(precision, value, ...)
  self:write_vfloat(FLOAT_BYTES, precision, value, ...)
end

--- Read a signed Z-Wave integer from the buffer.  Serialized Z-Wave integers
--- are big endian.
---
--- @param size number width of the integer in bytes
--- @return number parsed integer
function Reader:read_signed(size, ...)
  if size == 1 then
    return self:read_i8(...)
  elseif size == 2 then
    return self:read_be_i16(...)
  elseif size == 4 then
    return self:read_be_i32(...)
  else
    error("illegal Z-Wave integer size " .. size)
  end
end

--- Write a signed Z-Wave integer to the buffer.  serialized Z-Wave integers
--- are big endian.
---
--- @param size number width of the integer in bytes
--- @param value number integer to write
function Writer:write_signed(size, value, ...)
  size = size or self.size(value)
  if size == 1 then
    self:write_i8(value, ...)
  elseif size == 2 then
    self:write_be_i16(value, ...)
  elseif size == 4 then
    self:write_be_i32(value, ...)
  else
    error("illegal Z-Wave integer size " .. size)
  end
end

local WORD_WIDTH_CLASS_BOUNDARY = 0xF1

--- Write an endcoded command class designator to the internal buffer.
---
--- @param cmd_class number 1 or 2-byte command class designator
function Writer:write_cmd_class(cmd_class, ...)
  assert(cmd_class < 0xFF or cmd_class & 0xFF >= WORD_WIDTH_CLASS_BOUNDARY,
    "illegal command class value " .. cmd_class)
  self:write_u8(cmd_class & 0xFF, ...)
  if cmd_class >= WORD_WIDTH_CLASS_BOUNDARY then
    self:write_u8(cmd_class >> 8, ...)
  end
end

--- Read an endcoded command class designator from the internal buffer.
---
--- @return number decoded 1 or 2-byte command class designator
function Reader:read_cmd_class(...)
  local cmd_class = self:read_u8()
  if cmd_class >= WORD_WIDTH_CLASS_BOUNDARY then
    cmd_class = cmd_class + (self:read_u8() << 8)
  end
  self:store(cmd_class, ...)
  return cmd_class
end

--- Read a Z-Wave actuator-class-encoded duration-set byte from the buffer and
--- convert to seconds or "default" string indicator.
---
--- Note special encodings for 0xFE and 0xFF:
---
---        | set per spec | report per spec |
---        ----------------------------------
---   0xFE | 127 minutes  |    unknown      |
---   0xFF |   default    |   reserved      |
---
--- @return number|string duration in seconds or "default"
function Reader:read_actuator_duration_set(...)
  local u8val = self:read_u8()
  local duration
  if u8val == 0xFF then
    duration = "default"
  elseif u8val > 127 then
    duration = (u8val - 127) * 60 -- minutes encoding
  else
    duration = u8val -- seconds encoding
  end
  self:store(duration, ...)
  return duration
end

--- Write a Z-Wave actuator-class-encoded duration-set to the internal buffer.
---
--- Note special encodings for 0xFE and 0xFF:
---
---        | set per spec | report per spec |
---        ----------------------------------
---   0xFE | 127 minutes  |    unknown      |
---   0xFF |   default    |   reserved      |
---
--- @param duration number|string duration in seconds or "default"
function Writer:write_actuator_duration_set(duration)
  if duration == "default" then
    duration = 0xFF
  elseif duration > 127 then
    duration = utils.round(duration * (1.0 / 60)) -- minutes encoding
    duration = duration + 127
  else
    duration = utils.round(duration) -- seconds encoding
  end
  self:write_u8(duration)
end

--- Read a Z-Wave actuator-class-encoded duration-report byte from the buffer
--- and convert to seconds or "unkown", "reserved" string indicators.
---
--- Note special encodings for 0xFE and 0xFF:
---
---        | set per spec | report per spec |
---        ----------------------------------
---   0xFE | 127 minutes  |    unknown      |
---   0xFF |   default    |   reserved      |
---
--- @return number|string duration in seconds or "unkown" or "reserved"
function Reader:read_actuator_duration_report(...)
  local u8val = self:read_u8()
  local duration
  if u8val == 0xFE then
    duration = "unknown"
  elseif u8val == 0xFF then
    duration = "reserved"
  elseif u8val > 127 then
    duration = (u8val - 127) * 60 -- minutes encoding
  else
    duration = u8val -- seconds encoding
  end
  self:store(duration, ...)
  return duration
end

--- Write a Z-Wave actuator-class-encoded duration-set to the internal buffer.
---
--- Note special encodings for 0xFE and 0xFF:
---
---        | set per spec | report per spec |
---        ----------------------------------
---   0xFE | 127 minutes  |    unknown      |
---   0xFF |   default    |   reserved      |
---
--- @param duration number|string duration in seconds or "unknown" or "reserved"
function Writer:write_actuator_duration_report(duration)
  if duration == "unknown" then
    duration = 0xFE
  elseif duration == "reserved" then
    duration = 0xFF
  elseif duration > 127 then
    duration = utils.round(duration * (1.0 / 60)) -- minutes encoding
    duration = duration + 127
  else
    duration = utils.round(duration) -- seconds encoding
  end
  self:write_u8(duration)
end

--- @class st.zwave.types.switchpoint
--- @alias switchpoint st.zwave.types.switchpoint
---
--- @field public hour integer
--- @field public minute integer
--- @field public schedule_state integer
local switchpoint = {}

--- Read an encoded switchpoint from a BIT_24 field of self.zwbuf.
---
--- @return st.zwave.types.switchpoint decoded switchpoint with fields "hour", "minute", "schedule_start"
function Reader:read_switchpoint(...)
  local sp = {}
  self:read_bits(5, "hour", sp)
  self:read_bits(3, 0) -- reserved
  self:read_bits(6, "minute", sp)
  self:read_bits(2, 0) -- reserved
  self:read_u8("schedule_state", sp)
  self:store(sp, ...)
  return sp
end

--- Write a switchpoint to self.zwbuf.
---
--- @param sp st.zwave.types.switchpoint switchpoint with fields "hour", "minute", "schedule_start"
function Writer:write_switchpoint(sp)
  self:write_bits(5, sp.hour)
  self:write_bits(3, 0) -- reserved
  self:write_bits(6, sp.minute)
  self:write_bits(2, 0) -- reserved
  self:write_u8(sp.schedule_state)
end

zwbuf.Reader = Reader
zwbuf.Writer = Writer
return zwbuf
