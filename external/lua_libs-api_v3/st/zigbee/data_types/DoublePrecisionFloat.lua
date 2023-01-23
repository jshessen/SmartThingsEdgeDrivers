
local FloatABC = require "st.zigbee.data_types.base_defs.FloatABC"

--- @class st.zigbee.data_types.DoublePrecisionFloat: st.zigbee.data_types.FloatABC
--- @field public ID number 0x3A
--- @field public NAME string "DoublePrecision"
--- @field public byte_length number 8
--- @field public mantissa_bit_length number 52
--- @field public exponent_bit_length number 11
local DoublePrecisionFloat = {}
setmetatable(DoublePrecisionFloat, FloatABC.new_mt({ NAME = "DoublePrecisionFloat", ID = 0x3A }, 8, 52, 11))

return DoublePrecisionFloat
