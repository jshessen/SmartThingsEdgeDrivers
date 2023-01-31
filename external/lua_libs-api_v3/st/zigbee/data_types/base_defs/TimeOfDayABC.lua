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
local Uint8 = require "st.zigbee.data_types.Uint8"

--- @class st.zigbee.data_types.TimeOfDayABC: st.zigbee.data_types.DataType
---
--- Classes being created using the TimeOfDayABC class represent Zigbee data types whose lua "value" is stored
--- as a set of hours, minutes, seconds, and hundredths of seconds (all Uints)
local TimeOfDayABC = {}

--- This function will create a new metatable with the appropriate functionality for a Zigbee TimeOfDay
--- @param base table the base meta table, this will include the ID and NAME of the type being represented
--- @return table The meta table containing the functionality for this type class
function TimeOfDayABC.new_mt(base)
  local mt = {}
  mt.__index = base or {}
  mt.__index.is_fixed_length = true
  mt.__index.is_discrete = false
  mt.__index._serialize = function(self)
    return self.hours:_serialize() .. self.minutes:_serialize() .. self.seconds:_serialize() .. self.hundredths:_serialize()
  end
  mt.__index.get_length = function(self)
    return self.hours:get_length() + self.minutes:get_length() + self.seconds:get_length() + self.hundredths:get_length()
  end
  mt.__index.deserialize = function(buf, field_name)
    local o = {}
    setmetatable(o, mt)
    o.field_name = field_name

    o.hours = Uint8.deserialize(buf, "hours")
    o.minutes = Uint8.deserialize(buf, "minutes")
    o.seconds = Uint8.deserialize(buf, "seconds")
    o.hundredths = Uint8.deserialize(buf, "hundredths")
    return o
  end
  mt.__index.pretty_print = function(self)
    if self.hours == nil or self.minutes == nil or self.seconds == nil or self.hundredths == nil then
      return "Uninitialized " .. self.NAME
    end
    return string.format("%s: %02d:%02d:%02d.%02d", self.field_name or self.NAME, self.hours.value, self.minutes.value, self.seconds.value, self.hundredths.value)
  end
  mt.__call = function(orig, hours, minutes, seconds, hundredths)
    local o = {}
    setmetatable(o, mt)
    o.hours = Uint8(hours)
    o.minutes = Uint8(minutes)
    o.seconds = Uint8(seconds)
    o.hundredths = Uint8(hundredths)
    return o
  end
  mt.__tostring = function(self)
    return self:pretty_print()
  end
  return mt
end

return TimeOfDayABC
