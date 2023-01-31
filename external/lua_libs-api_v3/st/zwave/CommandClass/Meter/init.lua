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
--- @module st.zwave.CommandClass.meter
--- @alias Meter st.zwave.CommandClass.meter
local Meter = require "st.zwave.generated.Meter"
local zw = require "st.zwave"
local buf = require "st.zwave.utils.buf"

do
local _set_reflectors = Meter.ReportV3._set_reflectors
--- Set const reflectors to allow enum stringification.
---
--- @param self st.zwave.CommandClass.Meter.ReportV3
Meter.ReportV3._set_reflectors = function(self)
  _set_reflectors(self)
  local args = self.args
  args._reflect = args._reflect or {}
  args._reflect.scale_2 = function()
    return zw._reflect(
      Meter._reflect_scale_2,
      args.meter_type,
      args.scale,
      args.scale_2
    )
  end
end
end

do
local _set_reflectors = Meter.ReportV4._set_reflectors
--- Set const reflectors to allow enum stringification.
---
--- @param self st.zwave.CommandClass.Meter.ReportV4
Meter.ReportV4._set_reflectors = function(self)
  _set_reflectors(self)
  local args = self.args
  args._reflect = args._reflect or {}
  args._reflect.scale_2 = function()
    return zw._reflect(
      Meter._reflect_scale_2,
      args.meter_type,
      args.scale,
      args.scale_2
    )
  end
end
end

do
--- Serialize v4 or forward-compatible v5 METER_SUPPORTED_REPORT command arguments.
---
--- This overload of the generated library method provides special handling
--- for the mst bit, which if set indicates append of the scale_supported field
--- with additional bytes.
---
--- @return string serialized payload
local function serialize(self)
  local writer = buf.Writer()
  local args = self.args
  writer:write_bits(5, args.meter_type)
  writer:write_bits(2, args.rate_type)
  writer:write_bool(args.meter_reset)
  writer:write_bits(7, args.scale_supported & 0x7F)
  assert(args.scale_supported & 0x80 == 0, "illegal set of mst bit")
  writer:write_bool(args.scale_supported > 0x7F and true or false) -- mst
  if args.scale_supported > 0x7F then
    local mst = args.scale_supported >> 8
    writer:write_u8(writer.size(mst)) -- number_of_scale_supported_bytes_to_follow
    writer:write_bits(writer.size(mst) * 8, mst)
  end
  return writer.buf
end
Meter.SupportedReportV4.serialize = serialize
end

do
--- Deserialize a v4 or forward-compatible v5 METER_SUPPORTED_REPORT command payload.
---
--- This overload of the generated library method provides special handling
--- for the mst bit, which if set indicates append of the scale_supported field
--- with additional bytes.
---
--- @return st.zwave.CommandClass.Meter.SupportedReportV4Args deserialized command arguments
local function deserialize(self)
  local reader = buf.Reader(self.payload)
  reader:read_bits(5, "meter_type")
  reader:read_bits(2, "rate_type")
  reader:read_bool("meter_reset")
  reader:read_bits(7, "scale_supported")
  if reader:read_bool() then -- mst
    local len = reader:read_u8()
    local mst = reader:read_bits(len * 8)
    reader.parsed.scale_supported = reader.parsed.scale_supported + (mst << 8)
  end
  return reader.parsed
end
Meter.SupportedReportV4.deserialize = deserialize
end

do
--- Return a deep copy of self.args, merging defaults for unset, but required parameters.
---
--- @param self st.zwave.CommandClass.Meter.SupportedReportV4
--- @return st.zwave.CommandClass.Meter.SupportedReportV4Args
local function _defaults()
  local args = {}
  args.meter_type = args.meter_type or 0
  args.rate_type = args.rate_type or 0
  args.meter_reset = args.meter_reset or false
  args.scale_supported = args.scale_supported or 0
  return args
end
Meter.SupportedReportV4._defaults = _defaults
end

--- @class st.zwave.CommandClass.Meter.scale_2_electric_meter_mst
--- @alias scale_2_electric_meter_mst st.zwave.CommandClass.Meter.scale_2_electric_meter_mst
---
--- @field public KILOVOLT_AMPERE_REACTIVE number 0x00
--- @field public KILOVOLT_AMPERE_REACTIVE_HOURS number 0x01
local scale_2_electric_meter_mst = {}

--- @class st.zwave.CommandClass.Meter.scale_2_electric_meter
--- @alias scale_2_electric_meter st.zwave.CommandClass.Meter.scale_2_electric_meter
---
--- @field public mst st.zwave.CommandClass.Meter.scale_2_electric_meter_mst
local scale_2_eletric_meter = {}

--- @class st.zwave.CommandClass.Meter.scale_2
--- @alias scale_2 st.zwave.CommandClass.Meter.scale_2
---
--- @field public electric_meter st.zwave.CommandClass.scale_2_electric_meter
local scale_2 = {
  electric_meter = {
    mst = {
      KILOVOLT_AMPERE_REACTIVE = 0x00,
      KILOVOLT_AMPERE_REACTIVE_HOURS = 0x01,
    }
  },
  gas_meter = {
    mst = {
    }
  },
  water_meter = {
    mst = {
    }
  }
}
Meter.scale_2 = scale_2
Meter._reflect_scale_2 = zw._reflection_builder(Meter.scale_2, Meter.meter_type, Meter.scale)

return Meter
