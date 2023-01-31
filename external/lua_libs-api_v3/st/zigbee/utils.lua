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
local utils = {}

utils.serialize_from_fields = function(frame)
  local out_str = ""
  for _, v in ipairs(frame:get_fields()) do
    out_str = out_str .. v:_serialize()
  end
  return out_str
end

utils.length_from_fields = function(frame)
  local total_len = 0
  for _, v in ipairs(frame:get_fields()) do
    total_len = total_len + v:get_length()
  end
  return total_len
end

utils.MULTILINE_FORMAT_CONFIG = {
  header_sep = ":\n",
  header_prefix = function(depth) return "" end,
  header_postfix = function(depth) return "" end,
  item_sep = "\n",
  item_prefix = function(depth) return string.rep(" ", 4 * depth) end,
  item_postfix = function(depth) return "" end,
}

utils.DEFAULT_FORMAT_CONFIG = {
  header_sep = " || ",
  item_sep = ", ",
  header_prefix = function(depth) return "< " end,
  header_postfix = function(depth) return " >" end,
  item_prefix = function(depth) return "" end,
  item_postfix = function(depth) return "" end,
}

utils.format_from_fields_helper = function(frame, format_config, depth)
  depth = depth or 0
  local out_str = format_config.header_prefix(depth) .. frame.NAME .. format_config.header_sep
  depth = depth + 1
  local field_list = frame:get_fields()
  for _, v in ipairs(field_list) do
    out_str = out_str  .. format_config.item_prefix(depth) .. v:pretty_print(format_config, depth) .. format_config.item_postfix(depth) .. format_config.item_sep
  end
  if out_str:sub(-(#format_config.item_sep),-1) == format_config.item_sep then
    out_str = out_str:sub(1, -(#format_config.item_sep + 1)) .. format_config.header_postfix(depth)
  else
    out_str = out_str .. format_config.header_postfix(depth)
  end
  return out_str
end

utils.build_pretty_print_from_fields_with_default = function(f_config)
  return function(frame, format_config, depth)
    format_config = format_config or f_config
    return utils.format_from_fields_helper(frame, format_config, depth)
  end
end

utils.print_from_fields = utils.build_pretty_print_from_fields_with_default(utils.DEFAULT_FORMAT_CONFIG)

utils.pretty_print_hex_str = function(str)
  return string.format(string.rep("%02X", #str), string.byte(str, 1, #str))
end

utils.deserialize_field_list = function(self, field_list, buf)
  for _, v in ipairs(field_list) do
    self[v.name] = v.type.deserialize(buf, v.name)
  end
end

return utils
