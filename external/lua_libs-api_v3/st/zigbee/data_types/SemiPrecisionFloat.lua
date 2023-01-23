
local FloatABC = require "st.zigbee.data_types.base_defs.FloatABC"

--- @class st.zigbee.data_types.SemiPrecisionFloat: st.zigbee.data_types.FloatABC
--- @field public ID number 0x38
--- @field public NAME string "SemiPrecision"
--- @field public byte_length number 2
--- @field public mantissa_bit_length number 10
--- @field public exponent_bit_length number 5
local SemiPrecisionFloat = {}
setmetatable(SemiPrecisionFloat, FloatABC.new_mt({ NAME = "SemiPrecisionFloat", ID = 0x38 }, 2, 10, 5))

return SemiPrecisionFloat
