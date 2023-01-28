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
local utils = require "st.utils"

--- @module st.buf
--- @alias buf st.buf
local buf = {}

--- @class st.buf.Buf
--- @alias Buf st.buf.Buf
local Buf = {}
Buf.__index = Buf

setmetatable(Buf, {
  __call = function(cls, ...)
    local self = setmetatable({}, cls)
    self:init(...)
    return self
  end,
})

--- Initialize a buffer instance.
---
--- @param buffer string initial buffer contents
function Buf:init(buffer)
  assert(type(buffer) == "string", "buf must be a string")
  self.buf = buffer
  self.idx = 0
end

--- Return the size of the internal buffer.
---
--- @return number size in bytes
function Buf:size()
  return string.len(self.buf)
end

--- Return the current 0-based byte position of the buffer.
---
--- @return number 0-based position in bytes
function Buf:tell()
  local idx = self.idx >> 3
  if self:bit_tell() > 0 then
    idx = idx + 1
  end
  return idx
end

--- Return the current 0-based bit position of the buffer, modulus 8.
---
--- @return number 0-based bit position in bits, modulus 8.
function Buf:bit_tell()
  if self.idx < 0 then
    -- Shift is not precisely equivalent to divide-by-power-of-2
    -- for negative 2's complement numbers.  Handle separately.
    local n = -self.idx
    n = n & 7
    return -n
  else
    return self.idx & 7
  end
end

--- Return the number of bytes remaining in the buffer.
---
--- @return number buffer's remaining bytes
function Buf:remain()
  return self:size() - self:tell()
end

--- Return the number of bits remaining in the buffer.
---
--- @return number buffer's remaining bytes
function Buf:bits_remain()
  return (self:size() << 3) - self.idx
end

--- Seek buffer by n bytes.
---
--- @param n number number bytes to seek
function Buf:seek(n)
  assert(type(n) == "number", "n must be a number")
  if n < 0 then
    -- Shift is not precisely equivalent to divide-by-power-of-2
    -- for negative 2's complement numbers.  Handle separately.
    n = -n
	self.idx = self.idx - (n << 3)
  else
    self.idx = self.idx + (n << 3)
  end
end

--- Seek buffer by n bits.
---
--- @param n number number bytes to seek
function Buf:bit_seek(n)
  assert(type(n) == "number", "n must be a number")
  self.idx = self.idx + n
end

--- @class st.buf.Writer:st.buf.Buf
--- @alias Writer st.buf.Writer
local Writer = {}
Writer.__index = Writer

setmetatable(Writer, {
  __index = Buf,
  __call = function(cls, ...)
    local self = setmetatable({}, cls)
    self:init(...)
    return self
  end,
})

--- Initialize buf writer instance.
function Writer:init()
  Buf.init(self, "")
end

--- Get a string representation of the Writer
---
--- @return string a string representation of the Writer
function Writer:pretty_print()
  return string.format("Writer < idx: %d, buf: %s >", self.idx, utils.get_print_safe_string(self.buf))
end
Writer.__tostring = Writer.pretty_print

--- Serialize and write an integer value to the internal buffer.
---
--- @param value number value to write
--- @param width number integer width in bytes
--- @param signed boolean true if signed, false if unsigned
--- @param little_endain boolean true if little endian, false if big endian
function Writer:write_int(value, width, signed, little_endian)
  if self:bit_tell() ~= 0 then
    -- Advance to byte-boundary.
    self.idx = self.idx & (-1 << 3)
    self:seek(1)
  end
  self.buf = self.buf:sub(1, self:tell() + 1) .. utils.serialize_int(value, width, signed, little_endian)
  self:seek(width)
end

--- Write a Uint8 to the internal buffer.
---
--- @param value number value to write
function Writer:write_u8(value)
  self:write_int(value, 1, false, false)
end

--- Write a little-endian Uint16 to the internal buffer.
---
--- @param value number value to write
function Writer:write_le_u16(value)
  self:write_int(value, 2, false, true)
end

--- Write a big-endian Uint16 to the internal buffer.
---
--- @param value number value to write
function Writer:write_be_u16(value)
  self:write_int(value, 2, false, false)
end

--- Write a little-endian Uint24 to the internal buffer.
---
--- @param value number value to write
function Writer:write_le_u24(value)
  self:write_int(value, 3, false, true)
end

--- Write a big-endian Uint24 to the internal buffer.
---
--- @param value number value to write
function Writer:write_be_u24(value)
  self:write_int(value, 3, false, false)
end

--- Write a little-endian Uint32 to the internal buffer.
---
--- @param value number value to write
function Writer:write_le_u32(value)
  self:write_int(value, 4, false, true)
end

--- Write a big-endian Uint32 to the internal buffer.
---
--- @param value number value to write
function Writer:write_be_u32(value)
  self:write_int(value, 4, false, false)
end

--- Write a little-endian Uint40 to the internal buffer.
---
--- @param value number value to write
function Writer:write_le_u40(value)
  self:write_int(value, 5, false, true)
end

--- Write a big-endian Uint40 to the internal buffer.
---
--- @param value number value to write
function Writer:write_be_u40(value)
  self:write_int(value, 5, false, false)
end

--- Write a little-endian Uint48 to the internal buffer.
---
--- @param value number value to write
function Writer:write_le_u48(value)
  self:write_int(value, 6, false, true)
end

--- Write a big-endian Uint48 to the internal buffer.
---
--- @param value number value to write
function Writer:write_be_u48(value)
  self:write_int(value, 6, false, false)
end

--- Write a little-endian Uint56 to the internal buffer.
---
--- @param value number value to write
function Writer:write_le_u56(value)
  self:write_int(value, 7, false, true)
end

--- Write a big-endian Uint56 to the internal buffer.
---
--- @param value number value to write
function Writer:write_be_u56(value)
  self:write_int(value, 7, false, false)
end

--- Write an Int8 to the internal buffer.
---
--- @param value number value to write
function Writer:write_i8(value)
  self:write_int(value, 1, true, false)
end

--- Write a little-endian Int16 to the internal buffer.
---
--- @param value number value to write
function Writer:write_le_i16(value)
  self:write_int(value, 2, true, true)
end

--- Write a big-endian Int16 to the internal buffer.
---
--- @param value number value to write
function Writer:write_be_i16(value)
  self:write_int(value, 2, true, false)
end

--- Write a little-endian Int24 to the internal buffer.
---
--- @param value number value to write
function Writer:write_le_i24(value)
  self:write_int(value, 3, true, true)
end

--- Write a big-endian Int24 to the internal buffer.
---
--- @param value number value to write
function Writer:write_be_i24(value)
  self:write_int(value, 3, true, false)
end

--- Write a little-endian Int32 to the internal buffer.
---
--- @param value number value to write
function Writer:write_le_i32(value)
  self:write_int(value, 4, true, true)
end

--- Write a big-endian Int32 to the internal buffer.
---
--- @param value number value to write
function Writer:write_be_i32(value)
  self:write_int(value, 4, true, false)
end

--- Write a little-endian Int40 to the internal buffer.
---
--- @param value number value to write
function Writer:write_le_i40(value)
  self:write_int(value, 5, true, true)
end

--- Write a big-endian Int40 to the internal buffer.
---
--- @param value number value to write
function Writer:write_be_i40(value)
  self:write_int(value, 5, true, false)
end

--- Write a little-endian Int48 to the internal buffer.
---
--- @param value number value to write
function Writer:write_le_i48(value)
  self:write_int(value, 6, true, true)
end

--- Write a big-endian Int48 to the internal buffer.
---
--- @param value number value to write
function Writer:write_be_i48(value)
  self:write_int(value, 6, true, false)
end

--- Write a little-endian Int56 to the internal buffer.
---
--- @param value number value to write
function Writer:write_le_i56(value)
  self:write_int(value, 7, true, true)
end

--- Write a big-endian Int56 to the internal buffer.
---
--- @param value number value to write
function Writer:write_be_i56(value)
  self:write_int(value, 7, true, false)
end

--- Write a little-endian Int64 to the internal buffer.
---
--- @param value number value to write
function Writer:write_le_i64(value)
  self:write_int(value, 8, true, true)
end

--- Write a big-endian Int64 to the internal buffer.
---
--- @param value number value to write
function Writer:write_be_i64(value)
  self:write_int(value, 8, true, false)
end

--- Write an arbitrary number of bytes to the internal buffer.
---
--- @param data string data to write
function Writer:write_bytes(data)
  assert(type(data) == "string", "data must be a string")
  if self:bit_tell() ~= 0 then
    -- Advance to byte-boundary.
    self.idx = self.idx & (-1 << 3)
    self:seek(1)
  end
  self.buf = self.buf .. data
  self:seek(string.len(data))
end

--- Write an arbitrary number of bits to self.buf.
---
--- @param self Writer buffer to write into
--- @param len number number of bits to write
--- @param number unsigned bit data
local function serialize_bits(self, len, data)
  assert(type(data) == "number" and data >= 0, "data representation must be a non-negative number")
  assert(len >= 0 and len <= 63, "Lua bit operations must be [0,63] bits wide")
  assert(data <= (1 << len) - 1, "bit-set overflow")
  if self:bit_tell() > 0 then
    local cur = string.byte(self.buf, self:tell())
    local shift = self:bit_tell()
    local width = 8 - shift
    width = width <= len and width or len
    local mask = (data & ((1 << width) - 1)) << shift
    cur = cur | mask
    if self:tell() > 0 then
      self.buf = self.buf:sub(1, -2) .. string.char(cur)
    else
      self.buf = string.char(cur)
    end
    self:bit_seek(width)
    len = len - width
    data = data >> width
  end
  while len >= 8 do
    local cur = data & 0xFF
    self.buf = self.buf .. string.char(cur)
    self:seek(1)
    len = len - 8
    data = data >> 8
  end
  if len > 0 then
    self.buf = self.buf .. string.char(data)
    self:bit_seek(len)
  end
end

--- Write a boolean bit to the internal buffer.
---
--- @param value boolean value to write
function Writer:write_bool(value)
  assert(type(value) == "boolean", "value must be a boolean")
  if value == true then
    value = 1
  else
    value = 0
  end
  serialize_bits(self, 1, value)
end

--- Write a bit field to the internal buffer.
---
--- Bits are extracted from the passed value in little-endian order.
---
--- @param width number bit field width
--- @param data number bit field
function Writer:write_bits(width, data)
  serialize_bits(self, width, data)
end

--- @class st.buf.Reader:st.buf.Buf
--- @alias Reader st.buf.Reader
local Reader = {}
Reader.__index = Reader

setmetatable(Reader, {
  __index = Buf,
  __call = function(cls, ...)
    local self = setmetatable({}, cls)
    self:init(...)
    return self
  end,
})

--- Initialize buf reader instance.
---
--- @param buffer string buffer contents
function Reader:init(buffer)
  Buf.init(self, buffer)
  self.parsed = {}
end

--- Get a string representation of the Reader
---
--- @return string a string representation of the Reader
function Reader:pretty_print()
  return string.format("Reader < idx: %d, buf: %s >", self.idx, utils.get_print_safe_string(self.buf))
end
Reader.__tostring = Reader.pretty_print

--- Store a value at the specified key either in the internal parsed table or,
--- if passed, the specified 'out' table.
---
--- @param value any value to store
--- @param key any key at which to store value, or nil if storage is not desired
--- @param out table table in which to store value, or nil if storage in the internal 'parsed' table is desired.
function Reader:store(value, key, out)
  if key ~= nil and out ~= nil then
    out[key] = value
  elseif key ~= nil then
    self.parsed[key] = value
  end
end

--- Read and deserialize an integer value from the internal buffer.
---
--- @param width number integer width in bytes
--- @param signed boolean true if signed, false if unsigned
--- @param little_endian boolean true if little endian, false if big endian
--- @return number integer parsed from the internal buffer
function Reader:read_int(width, signed, little_endian, ...)
  if self:bit_tell() ~= 0 then
    -- Advance to byte-boundary.
    self.idx = self.idx & (-1 << 3)
    self:seek(1)
  end
  assert(self:remain() >= width, "buffer too short")
  local val = utils.deserialize_int(self.buf:sub(self:tell() + 1, -1), width, signed, little_endian)
  self:seek(width)
  self:store(val, ...)
  return val
end

--- Read a Uint8 from the internal buffer.
---
--- @return number value read from the buffer
function Reader:read_u8(...)
  return self:read_int(1, false, false, ...)
end

--- Read a litle-endian Uint16 from the internal buffer.
---
--- @return number value read from the buffer
function Reader:read_le_u16(...)
  return self:read_int(2, false, true, ...)
end

--- Read a big-endian Uint16 from the internal buffer.
---
--- @return number value read from the buffer
function Reader:read_be_u16(...)
  return self:read_int(2, false, false, ...)
end

--- Read a little-endian Uint24 from the internal buffer.
---
--- @return number value read from the buffer
function Reader:read_le_u24(...)
  return self:read_int(3, false, true, ...)
end

--- Read a big-endian Uint24 from the internal buffer.
---
--- @return number value read from the buffer
function Reader:read_be_u24(...)
  return self:read_int(3, false, false, ...)
end

--- Read a little-endian Uint32 from the internal buffer.
---
--- @return number value read from the buffer
function Reader:read_le_u32(...)
  return self:read_int(4, false, true, ...)
end

--- Read a big-endian Uint32 from the internal buffer.
---
--- @return number value read from the buffer
function Reader:read_be_u32(...)
  return self:read_int(4, false, false, ...)
end

--- Read a little-endian Uint40 from the internal buffer.
---
--- @return number value read from the buffer
function Reader:read_le_u40(...)
  return self:read_int(5, false, true, ...)
end

--- Read a big-endian Uint40 from the internal buffer.
---
--- @return number value read from the buffer
function Reader:read_be_u40(...)
  return self:read_int(5, false, false, ...)
end

--- Read a little-endian Uint48 from the internal buffer.
---
--- @return number value read from the buffer
function Reader:read_le_u48(...)
  return self:read_int(6, false, true, ...)
end

--- Read a big-endian Uint48 from the internal buffer.
---
--- @return number value read from the buffer
function Reader:read_be_u48(...)
  return self:read_int(6, false, false, ...)
end

--- Read a little-endian Uint56 from the internal buffer.
---
--- @return number value read from the buffer
function Reader:read_le_u56(...)
  return self:read_int(7, false, true, ...)
end

--- Read a big-endian Uint56 from the internal buffer.
---
--- @return number value read from the buffer
function Reader:read_be_u56(...)
  return self:read_int(7, false, false, ...)
end

--- Read an Int8 from the internal buffer.
---
--- @return number value read from the buffer
function Reader:read_i8(...)
  return self:read_int(1, true, false, ...)
end

--- Read a litle-endian Int16 from the internal buffer.
---
--- @return number value read from the buffer
function Reader:read_le_i16(...)
  return self:read_int(2, true, true, ...)
end

--- Read a big-endian Int16 from the internal buffer.
---
--- @return number value read from the buffer
function Reader:read_be_i16(...)
  return self:read_int(2, true, false, ...)
end

--- Read a little-endian Int24 from the internal buffer.
---
--- @return number value read from the buffer
function Reader:read_le_i24(...)
  return self:read_int(3, true, true, ...)
end

--- Read a big-endian Int24 from the internal buffer.
---
--- @return number value read from the buffer
function Reader:read_be_i24(...)
  return self:read_int(3, true, false, ...)
end

--- Read a little-endian Int32 from the internal buffer.
---
--- @return number value read from the buffer
function Reader:read_le_i32(...)
  return self:read_int(4, true, true, ...)
end

--- Read a big-endian Int32 from the internal buffer.
---
--- @return number value read from the buffer
function Reader:read_be_i32(...)
  return self:read_int(4, true, false, ...)
end

--- Read a little-endian Int40 from the internal buffer.
---
--- @return number value read from the buffer
function Reader:read_le_i40(...)
  return self:read_int(5, true, true, ...)
end

--- Read a big-endian Int40 from the internal buffer.
---
--- @return number value read from the buffer
function Reader:read_be_i40(...)
  return self:read_int(5, true, false, ...)
end

--- Read a little-endian Int48 from the internal buffer.
---
--- @return number value read from the buffer
function Reader:read_le_i48(...)
  return self:read_int(6, true, true, ...)
end

--- Read a big-endian Int40 from the internal buffer.
---
--- @return number value read from the buffer
function Reader:read_be_i48(...)
  return self:read_int(6, true, false, ...)
end

--- Read a little-endian Int56 from the internal buffer.
---
--- @return number value read from the buffer
function Reader:read_le_i56(...)
  return self:read_int(7, true, true, ...)
end

--- Read a big-endian Int56 from the internal buffer.
---
--- @return number value read from the buffer
function Reader:read_be_i56(...)
  return self:read_int(7, true, false, ...)
end

--- Read a little-endian Int64 from the internal buffer.
---
--- @return number value read from the buffer
function Reader:read_le_i64(...)
  return self:read_int(8, true, true, ...)
end

--- Read a big-endian Int64 from the internal buffer.
---
--- @return number value read from the buffer
function Reader:read_be_i64(...)
  return self:read_int(8, true, false, ...)
end

--- Read an arbitrary number of bytes from the internal buffer.
---
--- @param len number of bytes to read
--- @return string data read from the buffer
function Reader:read_bytes(len, ...)
  if self:bit_tell() ~= 0 then
    -- Advance to byte-boundary.
    self.idx = self.idx & (-1 << 3)
    self:seek(1)
  end
  assert(self:remain() >= len, "buffer too short")
  local data = self.buf:sub(self:tell() + 1, self:tell() + len)
  self:seek(len)
  self:store(data, ...)
  return data
end

--- Read an arbitrary number of bits from self.buf.
---
--- @param self Reader buffer to read from
--- @param len number number of bits to read
--- @return number bit data
local function deserialize_bits(self, len)
  assert(len >= 0 and len <= 63, "Lua bit operations must be [0,63] bits wide")
  local data = 0
  local shift  = 0
  if self:bit_tell() > 0 then
    local cur = string.byte(self.buf, self:tell())
    shift = self:bit_tell()
    local width = 8 - shift
    width = width <= len and width or len
    assert(self:bits_remain() >= width, "buffer too short")
    cur = cur >> shift
    cur = cur & ((1 << width) - 1)
    data = cur
    self:bit_seek(width)
    len = len - width
    shift = width
  end
  while len >= 8 do
    assert(self:remain() > 0, "buffer too short")
    local cur = string.byte(self.buf, self:tell() + 1)
    cur = cur << shift
    data = data | cur
    self:seek(1)
    len = len - 8
    shift = shift + 8
  end
  if len > 0 then
    assert(self:bits_remain() >= len, "buffer too short")
    local cur = string.byte(self.buf, self:tell() + 1)
    cur = cur & ((1 << len) - 1)
    cur = cur << shift
    data = data | cur
    self:bit_seek(len)
  end
  return data
end

--- Read a boolean bit from the internal buffer.
---
--- @return boolean true if the bit read is set, false if not
function Reader:read_bool(...)
  local value
  if self:bits_remain() <= 0 then
    value = false -- Absence of a flag is implicitly false.
  else
    value = deserialize_bits(self, 1)
    if value == nil then
      return value
    end
    if value ~= 0 then
      value = true
    else
      value = false
    end
  end
  self:store(value, ...)
  return value
end

--- Read a bit field from the internal buffer.
---
--- Bit extractions are returned in little-endian order.
---
--- @param len number of bits to read
--- @return number numerical representation of the bit field.
function Reader:read_bits(len, ...)
  local data = deserialize_bits(self, len)
  self:store(data, ...)
  return data
end

--- Peek a Uint8 from the internal buffer, but do not advance internal pointer.
---
--- @return number value read from the buffer
function Reader:peek_u8()
  local value = self:read_u8()
  self:seek(-1)
  return value
end

buf.Writer = Writer
buf.Reader = Reader
return buf
