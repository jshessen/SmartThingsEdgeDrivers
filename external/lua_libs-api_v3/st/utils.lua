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
---@module st.utils
local utils = {}

--- Print binary string as ascii hex
---@param str string
---@return string ascii hex string
function utils.get_print_safe_string(str)
  if str:match("^[%g ]+$") ~= nil then
    return string.format("%s", str)
  else
    return string.format(string.rep("\\x%02X", #str), string.byte(str, 1, #str))
  end
end

local key_order_cmp = function (key1, key2)
  local type1 = type(key1)
  local type2 = type(key2)
  if type1 ~= type2 then
    return type1 < type2
  elseif type1 == "number" or type1 == "string" then -- comparable types
    return key1 < key2
  elseif type1 == "boolean" then
    return key1 == true
  else
    return tostring(key1) < tostring(key2)
  end
end

local stringify_table_helper

stringify_table_helper = function(val, name, multi_line, indent, previously_printed)
  local tabStr = multi_line and string.rep(" ", indent) or ""

  if name then tabStr = tabStr .. tostring(name) .. "=" end

  local multi_line_str = ""
  if multi_line then multi_line_str = "\n" end

  if type(val) == "table" then
    if not previously_printed[val] then
      tabStr = tabStr .. "{" .. multi_line_str
      -- sort keys for repeatability of print
      local tkeys = {}
      for k in pairs(val) do table.insert(tkeys, k) end
      table.sort(tkeys, key_order_cmp)

      for _, k in ipairs(tkeys) do
        local v = val[k]
        previously_printed[val] = name
        if #val > 0 and type(k) == "number" then
          tabStr =  tabStr .. stringify_table_helper(v, nil, multi_line, indent + 2, previously_printed) .. ", " .. multi_line_str
        else
          tabStr =  tabStr .. stringify_table_helper(v, k, multi_line, indent + 2, previously_printed) .. ", ".. multi_line_str
        end
      end
      if tabStr:sub(#tabStr, #tabStr) == "\n" and tabStr:sub(#tabStr - 1, #tabStr - 1) == "{" then
        tabStr = tabStr:sub(1, -2) .. "}"
      elseif tabStr:sub(#tabStr - 1, #tabStr - 1) == ","  then
        tabStr = tabStr:sub(1, -3) .. (multi_line and string.rep(" ", indent) or "") .. "}"
      else
        tabStr = tabStr .. (multi_line and string.rep(" ", indent) or "") .. "}"
      end
    else
      tabStr = tabStr .. "RecursiveTable: " .. previously_printed[val]
    end
  elseif type(val) == "number" then
    tabStr = tabStr .. tostring(val)
  elseif type(val) == "string" then
    tabStr = tabStr .. "\"" .. utils.get_print_safe_string(val) .. "\""
  elseif type(val) == "boolean" then
    tabStr = tabStr .. (val and "true" or "false")
  elseif type(val) == "function" then
    tabStr = tabStr .. tostring(val)
  else
    tabStr = tabStr .. "\"[unknown datatype:" .. type(val) .. "]\""
  end

  return tabStr
end

--- Convert value to string
---@param val table Value to stringify
---@param name string Print a name along with value [Optional]
---@param multi_line boolean use newlines to provide a more easily human readable string [Optional]
---@returns string String representation of `val`
function utils.stringify_table(val, name, multi_line)
  return stringify_table_helper(val, name, multi_line, 0, {})
end

--- Recursively merge all fields of template not already present in target_table.
---
--- @param target_table table table into which to merge template
--- @param template table table to merge into target_table
--- @return table target_table
function utils.merge(target_table, template)
  if template == nil then
    return target_table
  end
  for key, value in pairs(template) do
    if target_table[key] == nil then
      target_table[key] = value
    elseif type(value) == "table" and type(target_table[key]) == "table" then
      target_table[key] = utils.merge(target_table[key], value)
    end
  end
  return target_table
end

--- Recursively update all fields of target_table that are common and present in template.
---
--- @param target_table table table in which to update common fields from template
--- @param template table table from which to update common fields in target_table
--- @return table target_table
function utils.update(target_table, template)
  if template == nil then
    return target_table
  end
  for key, value in pairs(template) do
    if target_table[key] ~= nil then
      target_table[key] = value
    elseif type(value) == "table" then
      utils.update(target_table[key], value)
    end
  end
  return target_table
end

--- Force a value to fall between a min and max
--- @param val number the value to be clamped
--- @param min number the minimum value to be returned
--- @param max number the maximum value to be returned
--- @returns number min if val < min, max if val > max, val otherwise
function utils.clamp_value(val, min, max)
  if type(val) ~= "number" or type(min) ~= "number" or type(max) ~= "number" then
    error("Arguments must be numbers")
  end

  if val < min then
    return min
  elseif val > max then
    return max
  else
    return val
  end
end

--- Round a number to the nearest integer (.5 rounds up)
--- @param val number the value to be rounded
--- @return number the rounded value
function utils.round(val)
  if type(val) ~= "number"then
    error("Argument must be numbers")
  end
  return math.floor(val + 0.5)
end

--- Serialize an integer into a bytestring.
---
--- @param value number value to write
--- @param width number integer width in bytes
--- @param signed boolean true if signed, false if unsigned
--- @param little_endian boolean true if little endian, false if big endian
--- @return string serialized integer as byte string
function utils.serialize_int(value, width, signed, little_endian)
  local pattern = ">"
  if little_endian then
    pattern = "<"
  end
  if signed then
    pattern = pattern .. "i"
  else
    pattern = pattern .. "I"
  end
  pattern = pattern .. width
  return string.pack(pattern, value)
end

--- Deserialize an integer from the passed string.
---
--- @param buf string bytestring from which to deserialize an integer
--- @param width number integer width in bytes
--- @param signed boolean true if signed, false if unsigned
--- @param little_endian boolean true if little endian, false if big endian
--- @return number deserialized integer
function utils.deserialize_int(buf, width, signed, little_endian)
  assert(type(buf) == "string", "buf must be a string")
  local pattern = ">"
  if little_endian then
    pattern = "<"
  end
  if signed then
    pattern = pattern .. "i"
  else
    pattern = pattern .. "I"
  end
  pattern = pattern .. width
  return string.unpack(pattern, buf)
end

local function color_gamma_adjust(value)
  return value > 0.04045 and ((value + 0.055) / (1.0 + 0.055)) ^ 2.4 or value / 12.92
end

local function color_gamma_revert(value)
  return value <= 0.0031308 and 12.92 * value or (1.0 + 0.055) * (value ^ (1.0 / 2.4)) - 0.055
end

--- Converts Hue/Saturation to Red/Green/Blue
---
--- @param hue number hue in range [0,1]
--- @param saturation number saturation in range[0,1]
--- @return number, number, number equivalent red, green, blue with each color in range [0,1]
function utils.hsv_to_rgb(hue, saturation)
  local r, g, b

  if (saturation <= 0) then
    r, g, b = 1, 1, 1
  else
    local region = math.floor(6 * hue)
    local remainder = 6 * hue - region

    local p = 1 - saturation
    local q = 1 - saturation * remainder
    local t = 1 - saturation * (1 - remainder)

    if region == 0 then
      r, g, b = 1, t, p
    elseif region == 1 then
      r, g, b = q, 1, p
    elseif region == 2 then
      r, g, b = p, 1, t
    elseif region == 3 then
      r, g, b = p, q, 1
    elseif region == 4 then
      r, g, b = t, p, 1
    else
      r, g, b = 1, p, q
    end
  end

  return r, g, b
end

--- Converts Red/Green/Blue to Hue/Saturation
---
--- @param red number red in range [0,1]
--- @param green number green in range [0,1]
--- @param blue number blue in range [0,1]
--- @return number, number, number equivalent hue, saturation, level with each value in range [0,1]
function utils.rgb_to_hsv(red, green, blue)
  local min_rgb = math.min(red, green, blue)
  local max_rgb = math.max(red, green, blue)
  local delta = max_rgb - min_rgb

  local h, s
  local v = max_rgb

  if delta <= 0 then
    h, s = 0, 0
  else
    s = delta / max_rgb

    if red >= max_rgb then
      h = (green - blue) / delta
    elseif green >= max_rgb then
      h = 2 + (blue - red) / delta
    else
      h = 4 + (red - green) / delta
    end

    h = h / 6

    if h < 0 then
      h = h + 1
    end
  end

  return h, s, v
end

--- Convert from x/y/Y to Red/Green/Blue
---
--- @param x number x axis non-negative value
--- @param y number y axis non-negative value
--- @param Y number Y tristimulus value
--- @returns number, number, number equivalent red, green, blue vector with each color in the range [0,1]
function utils.xy_to_rgb(x, y, Y)
  local X = (Y / y) * x
  local Z = (Y / y) * (1.0 - x - y)

  local M = {
    {  3.2404542, -1.5371385, -0.4985314 },
    { -0.9692660,  1.8760108,  0.0415560 },
    {  0.0556434, -0.2040259,  1.0572252 }
  }

  local r = X * M[1][1] + Y * M[1][2] + Z * M[1][3]
  local g = X * M[2][1] + Y * M[2][2] + Z * M[2][3]
  local b = X * M[3][1] + Y * M[3][2] + Z * M[3][3]

  r = r < 0 and 0 or r
  r = r > 1 and 1 or r
  g = g < 0 and 0 or g
  g = g > 1 and 1 or g
  b = b < 0 and 0 or b
  b = b > 1 and 1 or b

  local max_rgb = math.max(r, g, b)
  r = color_gamma_revert(r / max_rgb)
  g = color_gamma_revert(g / max_rgb)
  b = color_gamma_revert(b / max_rgb)

  return r, g, b
end

--- Convert from Red/Green/Blue to x/y/Y
---
--- @param red number red in range [0,1]
--- @param green number green in range [0,1]
--- @param blue number blue in range [0,1]
--- @returns number, number, number equivalent x, y, Y
function utils.rgb_to_xy(red, green, blue)
  local r = color_gamma_adjust(red)
  local g = color_gamma_adjust(green)
  local b = color_gamma_adjust(blue)

  local M = {
    { 0.4124564,  0.3575761,  0.1804375 },
    { 0.2126729,  0.7151522,  0.0721750 },
    { 0.0193339,  0.1191920,  0.9503041 }
  }

  local X = r * M[1][1] + g * M[1][2] + b * M[1][3]
  local Y = r * M[2][1] + g * M[2][2] + b * M[2][3]
  local Z = r * M[3][1] + g * M[3][2] + b * M[3][3]

  local x = X / ( X + Y + Z )
  local y = Y / ( X + Y + Z )

  return x, y, Y
end

--- Safe convert from Hue/Saturation to x/y/Y
--- If hue or saturation is missing 0 is applied
---
--- @param hue number red in range [0,100]%
--- @param saturation number green in range [0,100]%
--- @returns number, number, number equivalent x, y, Y with x, y in range 0x0000 to 0xFFFF
function utils.safe_hsv_to_xy(hue, saturation)
  local safe_h = hue ~= nil and hue / 100 or 0
  local safe_s = saturation ~= nil and saturation / 100 or 0

  local r, g, b = utils.hsv_to_rgb(safe_h, safe_s)

  local x, y, Y = utils.rgb_to_xy(r, g, b)

  return utils.round(x * 65536), utils.round(y * 65536), Y
end

--- Convert from x/y/Y to Hue/Saturation
--- If every value is missing then [x, y, Y] = [0, 0, 1]
---
--- @param x number red in range [0x0000, 0xFFFF]
--- @param y number green in range [0x0000, 0xFFFF]
--- @param Y number blue in range [0x0000, 0xFFFF]
--- @returns number, number equivalent hue, saturation, level each in range [0,100]%
function utils.safe_xy_to_hsv(x, y, Y)
  local safe_x = x ~= nil and x / 65536 or 0
  local safe_y = y ~= nil and y / 65536 or 0
  local safe_Y = Y ~= nil and Y or 1

  local r, g, b = utils.xy_to_rgb(safe_x, safe_y, safe_Y)

  local h, s, v = utils.rgb_to_hsv(r, g, b)

  return utils.round(h * 100), utils.round(s * 100), utils.round(v * 100)
end

--- Convert from Hue/Saturation/Lightness to Red/Green/Blue
--- If lightness is missing, default to 50%.
---
--- @param hue number hue in the range [0,100]%
--- @param saturation number saturation in the range [0,100]%
--- @param lightness number lightness in the range [0,100]%, or nil
--- @returns number, number, number equivalent red, green, blue vector with each color in the range [0,255]
function utils.hsl_to_rgb(hue, saturation, lightness)
  lightness = lightness or 50 -- In most ST contexts, lightness is implicitly 50%.
  hue = hue * (1 / 100) -- ST hue is 0 to 100
  saturation = saturation * (1 / 100) -- ST sat is 0 to 100
  lightness = lightness * (1 / 100) -- Match ST hue/sat units
  if saturation <= 0 then
    return 255, 255, 255 -- achromatic
  end
  local function hue2rgb(p, q, t)
    if t < 0 then t = t + 1 end
    if t > 1 then t = t - 1 end
    if t < 1/6 then return p + (q - p) * 6 * t end
    if t < 1/2 then return q end
    if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
    return p
  end
  local red, green, blue
  local q = lightness + saturation - lightness * saturation
  local p = 2 * lightness - q
  red = hue2rgb(p, q, hue + 1/3);
  green = hue2rgb(p, q, hue);
  blue = hue2rgb(p, q, hue - 1/3);
  return utils.round(red * 255), utils.round(green * 255), utils.round(blue * 255)
end

--- Convert from red, green, blue to hue, saturation, lightness.
---
--- @param red number red component in the range [0,255]
--- @param green number green component in the range [0,255]
--- @param blue number blue component in the range [0,255]
--- @return number, number, number equivalent hue, saturation, lightness vector with each component in the range [0,100]
function utils.rgb_to_hsl(red, green, blue)
  red = red * (1 / 255)
  green = green * (1 / 255)
  blue = blue * (1 / 255)
  local min = math.min(math.min(red, green), blue)
  local max = math.max(math.max(red, green), blue)
  local lightness = (min + max) * (1 / 2)
  local saturation
  local hue
  if max == min then
    saturation = 0.0
    hue = 0.0
  else
    if lightness < 0.5 then
      saturation = (max - min) / (max + min)
    else
      saturation = (max - min) / (2.0 - max - min)
    end

    if max == red then
      hue = (green - blue) / (max - min)
    elseif max == green then
      hue = 2 + (blue - red) / (max - min)
    else
      hue = 4 + (red - green) / (max - min)
    end
    hue = hue * (1 / 6)
    if hue < 0 then hue = hue + 1 end -- normalize to [0,1]
  end
  return utils.round(hue * 100), utils.round(saturation * 100), utils.round(lightness * 100)
end

--- Convert celsius to fahrenheit.
---
--- @param celsius number temperature in celsius
--- @return number integer fahrenheit value
function utils.c_to_f(celsius)
  return utils.round((celsius * 9 / 5.0 + 32) * 100) / 100
end

--- Convert fahrenheit to celsius.
---
--- @param fahrenheit number temperature in fahrenheit
--- @return number integer celsius value
function utils.f_to_c(fahrenheit)
  return utils.round(((fahrenheit - 32) * (5 / 9.0)) * 100) / 100
end

local function deep_copy_helper(val, previously_copied, tab_ref)
  if type(val) ~= "table" then
    return val
  end
  local out = tab_ref or {}
  for k,v in pairs(val) do
    if type(v) == "table" then
      if previously_copied[v] ~= nil then
        out[k] = previously_copied[v]
      else
        out[k] = {}
        previously_copied[v] = out[k]
        out[k] = deep_copy_helper(v, previously_copied, out[k])
      end
    else
      out[k] = deep_copy_helper(v, previously_copied)
    end
  end
  return out
end

--- Copy a table and all it's values recursively
--- @param val table the table to copy
--- @return table the copied table
function utils.deep_copy(val)
  if type(val) ~= "table" then
    return val
  end

  local previously_copied = {}
  local out = {}
  previously_copied[val] = out
  return deep_copy_helper(val, previously_copied, out)
end

--- Reverse-sort the passed table.
---
--- @param tbl table (in/out) table to be reverse sorted
--- @return table reverse-sorted table
function utils.rsort(tbl)
  table.sort(tbl, function(a, b) return a > b end)
  return tbl
end

--- Table iterator for traversal by ordered keys.
---
--- @param t table over which to iterate
--- @param f function optional key comparison function
--- @return function table iterator
function utils.pairs_by_key(t, f)
  local keys = {}
  for k in pairs(t) do table.insert(keys, k) end
  table.sort(keys, f)
  local i = 0      -- iterator variable
  local iter = function()   -- iterator function
     i = i + 1
     local k = keys[i]
     if k ~= nil then
       return k, t[k]
     end
  end
  return iter
end

--- Table iterator for traversal by reverse-sorted keys.
---
--- @param t table over which to iterate
--- @return function table iterator
function utils.rkeys(t)
  return utils.pairs_by_key(t, function(a, b) return a > b end)
end

--- Table iterator for traversal by forward-sorted keys.
---
--- @param t table over which to iterate
--- @return function table iterator
function utils.fkeys(t)
  return utils.pairs_by_key(t)
end

--- Table iterator for traversal by ordered values.
---
--- @param t table over which to iterate
--- @param f value required value comparison function
--- @return function table iterator
function utils.pairs_by_value(t, f)
   local keys = {}
   for k in pairs(t) do
      keys[#keys + 1] = k
   end
   table.sort(keys, function(a, b) return f(t[a], t[b]) end)
   local i = 0
   local iter = function()
     i = i + 1
     local k = keys[i]
     if k ~= nil then
       return k, t[k]
     end
  end
  return iter
end

--- Table iterator for traversal by reverse-sorted values.
---
--- @param t table over which to iterate
--- @return function table iterator
function utils.rvalues(t)
  return utils.pairs_by_value(t, function(a, b) return a > b end)
end

--- Table iterator for traversal by forward-sorted values.
---
--- @param t table over which to iterate
--- @return function table iterator
function utils.fvalues(t)
  return utils.pairs_by_value(t, function(a, b) return a < b end)
end

--- Convert the passed string to camelCase.
---
--- @param str string string to convert
--- @return string camelCase version of the string
function utils.camel_case(str)
  return str:lower():gsub("_%a", string.upper):gsub("_", ""):gsub(" %a", string.upper):gsub(" ","")
end

--- Convert the passed string to PascalCase.
---
--- @param str string string to convert
--- @return string PascalCase version of the string
function utils.pascal_case(str)
  return utils.camel_case(str):gsub("^%l", string.upper)
end

--- Convert the passed string to snake_case.
---
--- @param str string string to convert
--- @return string snake_case version of the string
function utils.snake_case(str)
  return str:gsub('%f[^%l]%u','_%1'):gsub('%f[^%d]%a','_%1'):gsub('(%u)(%u%l)','%1_%2'):lower()
end

--- Convert the passed string to SCREAMING_SNAKE_CASE.
---
--- @param str string string to convert
--- @return string SCREAMING_SNAKE_CASE version of the string
function utils.screaming_snake_case(str)
  return utils.snake_case(str):upper()
end

--- Throw an error if the provided value isn't of the provided type
---
--- @param value any The value to check the type of
--- @param v_type string the expected value of `type(value)`
--- @param arg_name string|nil If present, used in generated error message
function utils.verify_type(value, v_type, arg_name)
  if type(value) ~= v_type then
    if arg_name ~= nil then
      error(string.format("%s should be of type %s but was %s", arg_name, v_type, type(value)), 2)
    else
      error(string.format("Expected type %s but received %s", v_type, type(value)), 2)
    end
  end

end

--- Return number of elements stored in a table
---
--- @param t table The table which length needs to be calculated
--- @return number Count of elements in table
function utils.table_size(t)
  utils.verify_type(t, "table")
  local cnt = 0
  for _ in pairs(t) do cnt = cnt + 1 end
  return cnt
end

---Generate a version 4 uuid as a string
---@return string
function utils.generate_uuid_v4()
  return string.format("%08x-%04x-%04x-%04x-%06x%06x",
    math.random(0, 0xffffffff),
    math.random(0, 0xffff),
    math.random(0, 0x0fff) + 0x4000, -- version 4, random
    math.random(0, 0x3fff) + 0x0800, -- variant 1
    math.random(0, 0xffffff),
    math.random(0, 0xffffff))
end


--- Turn a byte string into an array of bits with the most significant bit of each byte listed first
---
--- @param byte_string string the byte string to convert to bits
--- @return number[] an array of bits representing the byte string
function utils.bitify(byte_string)
  local bytes = { byte_string:byte(1, #byte_string) }
  local bits = {}
  for _, byte in ipairs(bytes) do
    for bit_pos = 0,7,1 do
      table.insert(bits, (byte & (1 << (7 - bit_pos))) >> (7 - bit_pos))
    end
  end
  return bits
end

--- Turn an array of bits into a number
---
--- @param bit_list number[] An array of bits (1 or 0)
--- @return number the numeric value of the bit_list
function utils.bit_list_to_int(bit_list)
  local total = 0
  local bit_list_len = #bit_list
  for i, bit in ipairs(bit_list) do
    if bit ~= 1 and bit ~= 0 then
      error("bit_list must contain only 1s and 0s", 2)
    end
    total = total + (bit << (bit_list_len - i))
  end
  return total
end

--- Convert a bit list to a byte string
---
--- @param bit_list number[] An array of bits (1 or 0) must be a length multiple of bytes
--- @return string the byte list of the bit array
function utils.bit_list_to_byte_str(bit_list)
  if #bit_list % 8 ~= 0 then
    error("Bit list length must be a multiple of 8")
  end
  local out = ""
  local byte = 0
  for i, bit in ipairs(bit_list) do
    local cur_byte_bit_pos = (7 - ((i - 1) % 8))
    byte = byte + (bit << cur_byte_bit_pos)
    if i % 8 == 0 then
      out = out .. utils.serialize_int(byte, 1, false, true)
      byte = 0
    end
  end
  return out
end

--- Convert a gas concentration given in moles per cubic meter [mol/m3] to value in part per million [ppm]
---
--- @param value number Concentration of gas [mol/m3]
--- @return string Concentration of gas [ppm]
function utils.mole_per_cubic_meter_to_ppm(value)
  -- Conversion based on https://www.teesing.com/files/source/understanding-units-of-measurement.pdf
  -- (1) concentration [ppm] = 24.45 * concentration [mg/m3] / molecular_weight [g/mol]
  -- (2) concentration [mg/m3] = concentration [mol/m3] * molecular_weight [g/mol] * 1000
  -- Insterting (2) into (1) results with:
  -- concentration [ppm] = 24450 * concentration [mol/m3]
  return 24450 * value
end

--- Wrap a function that will log all calls to the function along with the arguments
---
--- This will take a function and return a function that will perform the same actions as the passed in function but
--- also log every call to the function along with the arguments passed in.  Arguments will be expanded to readable
--- strings when possible, but will be truncated to 25 characters except when logged at the LOG_LEVEL_TRACE level
--- when full arguments will be logged regardless of length.
---
--- @param func function the function to be wrapped
--- @param func_name string the name of the function to include in the logs
--- @param log_level string the level you want the function logging to print at, defaults to LOG_LEVEL_DEBUG
--- @return function The new function that will perform the same behavior, but also log calls
function utils.log_func_wrapper(func, func_name, log_level)
  log_level = log_level or log.LOG_LEVEL_DEBUG
  local wrapped_f = function(...)
    local args = {...}
    local log_str = "call to " .. func_name .. ": "
    for i, a in ipairs(args) do
      local arg_string = utils.stringify_table(a)
      -- Truncate extremely long args except for TRACE log level
      if #arg_string > 25 and log_level ~= log.LOG_LEVEL_TRACE then
        arg_string = string.sub(arg_string, 1, 26)
      end
      log_str = log_str .. arg_string
    end
    log.log({}, log_level, log_str)
    return func(table.unpack(args))
  end
  return wrapped_f
end

--- Build an exponential backoff time value generator (function)
---
--- @param max number the maximum wait interval (not including `rand factor`)
--- @param inc number the rate at which to exponentially back off
--- @param rand number a randomization range of (-rand, rand) to be added to each interval
--- @return function the backoff generator that will return a new value each time it is called.
function utils.backoff_builder(max, inc, rand)
  local count = 0
  inc = inc or 1
  return function()
    local randval = 0
    if rand then
      --- We use this pattern because the version of math.random()
      --- that takes a range only works for integer values and we
      --- want floating point.
      randval = math.random() * rand * 2 - rand
    end

    local base = inc * (2 ^ count - 1)
    count = count + 1

    -- ensure base backoff (not including random factor) is less than max
    if max then base = math.min(base, max) end

    -- ensure total backoff is >= 0
    return math.max(base + randval, 0)
  end
end

return utils
