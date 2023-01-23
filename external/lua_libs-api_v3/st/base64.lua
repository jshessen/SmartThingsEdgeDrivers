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
--- @module base64 Functions for encoding and decoding base64
--- @alias base64 st.base64
local base64 = {}

-- Start 0 indexed for base64
local encode_map = { [0] = 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
                     'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
                     'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
                     'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/', }

--- Encode a string into it's base 64 encoding
---
--- @param orig string the string to encode
--- @return string the base 64 encoded string
function base64.encode(orig)
  local out_str = ""
  -- Pad with 0s to multiples of 3
  local pad_chars = (3 - (#orig % 3)) % 3
  local s = orig .. (string.rep("\0", pad_chars))
  for i = 1, #s, 3 do
    -- Convert 3 orig bytes to 4 b64 encoded bytes
    local b1, b2, b3 = s:byte(i, i + 2)
    out_str = out_str .. encode_map[(b1 >> 2)] .. -- Top 6 bits of byte 1
        encode_map[((b1 & 0x03) << 4) + (b2 >> 4)] .. -- Bottom 2 bits of byte 1 and top 4 of byte 2
        encode_map[((b2 & 0x0F) << 2) + (b3 >> 6)] .. -- bottom 4 bits of byte 2 and top 2 bits of byte 3
        encode_map[(b3 & 0x3F)] -- bottom 6 bits of byte 3
  end
  out_str = out_str:sub(1, #out_str - pad_chars) .. string.rep("=", pad_chars)
  return out_str
end

local decode_map = { ['A'] = 0, ['B'] = 1, ['C'] = 2, ['D'] = 3, ['E'] = 4, ['F'] = 5, ['G'] = 6, ['H'] = 7, ['I'] = 8,
                     ['J'] = 9, ['K'] = 10, ['L'] = 11, ['M'] = 12, ['N'] = 13, ['O'] = 14, ['P'] = 15, ['Q'] = 16,
                     ['R'] = 17, ['S'] = 18, ['T'] = 19, ['U'] = 20, ['V'] = 21, ['W'] = 22, ['X'] = 23, ['Y'] = 24,
                     ['Z'] = 25, ['a'] = 26, ['b'] = 27, ['c'] = 28, ['d'] = 29, ['e'] = 30, ['f'] = 31, ['g'] = 32,
                     ['h'] = 33, ['i'] = 34, ['j'] = 35, ['k'] = 36, ['l'] = 37, ['m'] = 38, ['n'] = 39, ['o'] = 40,
                     ['p'] = 41, ['q'] = 42, ['r'] = 43, ['s'] = 44, ['t'] = 45, ['u'] = 46, ['v'] = 47, ['w'] = 48,
                     ['x'] = 49, ['y'] = 50, ['z'] = 51, ["0"] = 52, ['1'] = 53, ['2'] = 54, ['3'] = 55, ['4'] = 56,
                     ['5'] = 57, ['6'] = 58, ['7'] = 59, ['8'] = 60, ['9'] = 61, ['+'] = 62, ['/'] = 63, ['='] = 0 }

--- Convert a base 64 encoded string back to the original string
---
--- @param encoded string the base64 encoded string
--- @return string the original string that was encoded into the parameter
function base64.decode(encoded)
  local out_bytes = ""
  local pad_chars = #encoded:match("[^=]*(=*)")
  -- Map every 4 b64 characters back to 3 original bytes
  for i = 1, #encoded, 4 do
    local nums = {}
    for next_char in string.gmatch(encoded:sub(i, i + 3), ".") do
      nums[#nums + 1] = decode_map[next_char]
    end
    -- All resulting numbers are  < 0x3F and so the top 2 bits are 0s
    out_bytes = out_bytes .. string.char((nums[1] << 2) + (nums[2] >> 4)) .. -- bottom 6 from byte 1 and top 2
        string.char(((nums[2] & 0x0F) << 4) + (nums[3] >> 2)) .. -- bottom 4 of byte 2 and top 4 of byte 3
        string.char(((nums[3] & 0x03) << 6) + nums[4]) -- bottom 2 of byte 3 and top 6 of byte 4
  end
  -- remove padding characters
  return out_bytes:sub(1, #out_bytes - pad_chars)
end

return base64
