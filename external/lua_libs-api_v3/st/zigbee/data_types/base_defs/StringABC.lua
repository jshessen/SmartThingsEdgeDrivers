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
local st_utils = require "st.utils"
local log = require "log"

--- @class st.zigbee.data_types.StringABC: st.zigbee.data_types.DataType
---
--- Classes being created using the StringABC class represent Zigbee data types whose lua "value" is stored
--- as a string.  In general these are the Zigbee data types CharString, OctetString, LongCharString,
--- and LongOctetString represented by IDs 0x41-0x44.  All of these are length prefixed and there is no difference
--- in the lua storage between Octet and Char strings.
local StringABC = {}

--- This function will create a new metatable with the appropriate functionality for a Zigbee String
--- @param base table the base meta table, this will include the ID and NAME of the type being represented
--- @param length_byte_length number the length in bytes of this String
function StringABC.new_mt(base, length_byte_length)
  local mt = {}
  mt.__index = base or {}
  mt.__index.length_byte_length = length_byte_length
  mt.__index.is_fixed_length = false
  mt.__index.is_discrete = true
  mt.__index._serialize = function(s)
    s:check_if_valid(s.value)
    return st_utils.serialize_int(s.byte_length, s.length_byte_length, false, true) .. s.value
  end
  mt.__index.is_invalid_length = function(length_val)
    return length_val == (1 << (8 * length_byte_length)) - 1
  end
  mt.__index.get_length = function(self)
    -- Valid Zigbee String
    if self.is_invalid_length(self.byte_length) then
      return self.length_byte_length
    end
    -- Invalid value, return just the byte length
    return self.byte_length + self.length_byte_length
  end
  mt.__index.deserialize = function(buf, field_name)
    local o = {}
    setmetatable(o, mt)
    o.byte_length = buf:read_int(length_byte_length, false, true)
    -- Zigbee String invalid value
    if mt.__index.is_invalid_length(o.byte_length) then
      o.value = ""
    else
      local status, val = pcall(buf.read_bytes, buf, o.byte_length)
      if status then
        o.value = val
      elseif string.find(val, ": buffer too short") ~= nil then
        o.value = buf:read_bytes(buf:remain())
      else
        error(val)
      end
      if #o.value < o.byte_length then
        log.warn_with({ hub_logs = true }, string.format("Zigbee string reported length %d but was actually only %d bytes long", o.byte_length, #o.value))
        o.byte_length = #o.value
      end
    end
    o.field_name = field_name
    return o
  end
  mt.__index.pretty_print = function(self)
    if self.value == nil then
      return "Uninitialized " .. self.NAME
    end
    if self.is_invalid_length(self.byte_length) then
      return string.format("%s: INVALID VALUE", self.field_name or self.NAME)
    end
    return string.format("%s: \"%s\"", self.field_name or self.NAME, st_utils.get_print_safe_string(self.value))
  end
  mt.__index.check_if_valid = function(self, value)
    if type(value) ~= "string" then
      error(string.format("%s value must be a string", self.NAME), 2)
    end
  end
  mt.__newindex = function(self, k, v)
    if k == "value" then
      self:check_if_valid(v)
      rawset(self, k, v)
    else
      rawset(self, k, v)
    end
  end
  mt.__call = function(orig, value)
    local o = {}
    setmetatable(o, mt)
    o.byte_length = #value
    o.value = value
    return o
  end
  mt.__tostring = function(self)
    return self:pretty_print()
  end
  return mt
end

return StringABC
