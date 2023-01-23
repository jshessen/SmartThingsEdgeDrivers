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
local utils = require "st.utils"

--- @class st.matter.data_types.FloatABC: st.matter.data_types.DataType
---
--- This represents a number of the form (1 + mantissa) * 2 ^ exponent with some exceptions
--- see the Matter spec for further details
---
--- @field public mantissa number The fractional component of the number
--- @field public exponent number The exponent for 2
--- @field public sign number either 1 if the value is negative or 0 if positive
local FloatABC = {}

local function mantissa_from_bits(bit_list)
  local out = 0
  for i, bit in ipairs(bit_list) do out = out + (bit * (1 / (2 ^ i))) end
  return out
end

local function mantissa_to_bits(mantissa, bit_length)
  local out_bits = {}
  local remainder = mantissa
  for i = 1, bit_length do
    local two_pow = 1 / (2 ^ i)

    if remainder >= two_pow then
      remainder = remainder - two_pow
      table.insert(out_bits, 1)
    else
      table.insert(out_bits, 0)
    end
  end
  return out_bits
end

--- This function will create a new metatable with the appropriate functionality for a Matter Float field
--- @param base table the base meta table, this will include the ID and NAME of the type being represented
--- @param byte_length number the length in bytes of this Float field
--- @param mantissa_bit_length number the number of bits to use for the mantissa field
--- @param exponent_bit_length number the number of bits to use for the exponent field
function FloatABC.new_mt(base, byte_length, mantissa_bit_length, exponent_bit_length)
  if mantissa_bit_length + exponent_bit_length + 1 > (byte_length * 8) then
    error("Mantissa, exponent, and sign bit lengths cannot exceed the total byte length")
  end
  local mt = {}
  local i_table = base or {}
  mt.i_table = i_table
  mt.__index = function(self, k)
    if mt.i_table[k] ~= nil then
      return mt.i_table[k]
    elseif k == "value" then
      return mt.i_table["get_float_val"](self)
    end
  end
  i_table.byte_length = byte_length
  i_table.is_fixed_length = true
  i_table.is_discrete = false
  i_table.mantissa_bit_length = mantissa_bit_length
  i_table.exponent_bit_length = exponent_bit_length
  i_table.exponent_modifier = (1 << (exponent_bit_length - 1)) - 1
  i_table._serialize = function(s) return nil end

  i_table.deserialize = function(buf, include_control_octet, field_name)
    local TLVParser = require "st.matter.TLV.TLVParser"
    local data_types = require "st.matter.data_types"

    local o = {}
    setmetatable(o, mt)

    local read_type_length = byte_length
    local read_mantissa_bit_length = mantissa_bit_length
    local read_exponent_bit_length = exponent_bit_length
    o.exponent_modifier = (1 << (exponent_bit_length - 1)) - 1

    if include_control_octet then
      local control_octet = buf:read_u8()
      local tag_control = control_octet & TLVParser.TAG_CONTROL_MASK
      local element_type = control_octet & TLVParser.TAG_ELEMENT_TYPE_MASK
      if (element_type ~= o.ID) then
        read_type_length, read_mantissa_bit_length, read_exponent_bit_length =
          data_types.get_subtype_length(
            mt.i_table.SUBTYPES, element_type
          )
        o.exponent_modifier = (1 << (read_exponent_bit_length - 1)) - 1
        if read_type_length == nil then
          error("Float deserialization failed, incorrect element type in control octet")
        end
      end
    end

    local read_bytes = buf:read_bytes(read_type_length)
    local raw_bytes = string.reverse(read_bytes)
    local raw_bits = utils.bitify(raw_bytes)
    o.raw_bits = raw_bits
    o.sign_bit = raw_bits[1]
    local bit_pos = 2
    local exponent_bits = {}
    for i = bit_pos, (bit_pos + read_exponent_bit_length - 1) do
      table.insert(exponent_bits, raw_bits[i])
    end
    bit_pos = bit_pos + read_exponent_bit_length
    local mantissa_bits = {}
    for i = bit_pos, (bit_pos + read_mantissa_bit_length - 1) do
      table.insert(mantissa_bits, raw_bits[i])
    end
    bit_pos = bit_pos + read_mantissa_bit_length
    if (bit_pos - 1) / 8 ~= read_type_length then error("Something went wrong") end
    o.exponent = utils.bit_list_to_int(exponent_bits) - o.exponent_modifier
    if o.exponent == -o.exponent_modifier then
      o.hidden_bit = 0
    else
      o.hidden_bit = 1
    end
    o.mantissa = mantissa_from_bits(mantissa_bits)
    o.field_name = field_name
    return o
  end
  i_table.get_float_val = function(self)
    local sign_mult = self.sign_bit == 1 and -1 or 1
    -- Handle 0 to avoid math resulting in very small float number
    if self.exponent == -1 * self.exponent_modifier and self.mantissa == 0 then
      -- Zero mantissa and all 0s exponent represents +/- zero
      return 0
    else
      return sign_mult * (1 + self.mantissa) * (2 ^ self.exponent)
    end
  end
  i_table.serialize = function(self, buf, include_control_octet, tag)
    if include_control_octet then
      local tag_control = tag and 0x20 or 0x0 -- 0x20 is context specific tag
      local element_type = self.ID
      local control_octet = tag_control | element_type
      buf:write_u8(control_octet)
      if tag ~= nil then
        buf:write_u8(tag)
      end
    end
    buf:write_int(self.value, self.byte_length, false, true)
    return buf.buf
  end
  i_table.pretty_print = function(self)
    local value_str = ""
    local sign_str = self.sign_bit == 1 and "-" or ""
    if self.exponent == -1 * self.exponent_modifier and self.mantissa == 0 then
      -- Zero mantissa and all 0s exponent represents +/- zero
      value_str = sign_str .. "0"
    elseif self.mantissa == 0 and self.exponent == (self.exponent_modifier + 1) then
      -- Zero mantissa and all 1s exponent represents +/- infinity
      value_str = sign_str .. "INF"
    else
      value_str = string.format(
                    "%s(%d + %f) * 2^(%d)", sign_str, self.hidden_bit, self.mantissa, self.exponent
                  )

    end
    return string.format("%s: %s", self.field_name or self.NAME, value_str)
  end
  i_table.check_mantissa_is_valid = function(self, mantissa)
    if type(mantissa) ~= "number" then
      error(string.format("%s mantissa values must be numbers", self.NAME), 2)
    elseif mantissa > 1 then
      error(string.format("%s mantissa must be less than 1", self.NAME))
    end
  end
  i_table.check_exponent_is_valid = function(self, exponent)
    if type(exponent) ~= "number" then
      error(string.format("%s exponent values must be numbers", self.NAME), 2)
    elseif exponent > (self.exponent_modifier + 1) then
      error(
        string.format(
          "%s exponent must be between -%d and %d", self.NAME, self.exponent_modifier,
            self.exponent_modifier + 1
        )
      )
    end
  end
  i_table.check_sign_is_valid = function(self, sign)
    if sign ~= 1 and sign ~= 0 then error(string.format("%s sign must be 0 or 1", self.NAME), 2) end
  end
  mt.__newindex = function(self, k, v)
    if k == "mantissa" then
      self:check_mantissa_is_valid(v)
    elseif k == "exponent" then
      self:check_exponent_is_valid(v)
    elseif k == "sign" then
      self:check_sign_is_valid(v)
    elseif k == "value" then
      error(
        "You cannot directly set the value of a Float, set the compenents instead (sign, mantissa, exponent)"
      )
    end
    rawset(self, k, v)
  end
  mt.__call = function(orig, sign, exponent, mantissa)
    local o = {}
    setmetatable(o, mt)
    o.exponent = exponent
    o.mantissa = mantissa
    if o.exponent == -o.exponent_modifier then
      o.hidden_bit = 0
    else
      o.hidden_bit = 1
    end
    o.sign_bit = sign
    return o
  end
  mt.__tostring = function(self) return self:pretty_print() end
  return mt
end

return FloatABC
