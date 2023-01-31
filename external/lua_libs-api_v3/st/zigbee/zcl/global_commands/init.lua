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
local generic_body = require "st.zigbee.generic_body"

--- @module zcl.global_commands
local zcl_global_commands = {}

zcl_global_commands.READ_ATTRIBUTE_ID = 0x00
zcl_global_commands.READ_ATTRIBUTE_RESPONSE_ID = 0x01
zcl_global_commands.WRITE_ATTRIBUTE_ID = 0x02
zcl_global_commands.WRITE_ATTRIBUTE_RESPONSE_ID = 0x04
zcl_global_commands.CONFIGURE_REPORTING_ID = 0x06
zcl_global_commands.CONFIGURE_REPORTING_RESPONSE_ID = 0x07
zcl_global_commands.READ_REPORTING_CONFIGURATION_ID = 0x08
zcl_global_commands.READ_REPORTING_CONFIGURATION_RESPONSE_ID = 0x09
zcl_global_commands.DEFAULT_RESPONSE_ID = 0x0B
zcl_global_commands.REPORT_ATTRIBUTE_ID = 0x0A

local camel_to_snake = function(str)
  local out_str = ""
  for  v in str:gmatch("%u[^%u]*") do
    out_str = out_str .. string.lower(v) .. "_"
  end
  return out_str:sub(1, #out_str - 1)
end

local id_map = {
  [0x00] = "ReadAttribute",
  [0x01] = "ReadAttributeResponse",
  [0x02] = "WriteAttribute",
  [0x04] = "WriteAttributeResponse",
  [0x06] = "ConfigureReporting",
  [0x07] = "ConfigureReportingResponse",
  [0x08] = "ReadReportingConfiguration",
  [0x09] = "ReadReportingConfigurationResponse",
  [0x0B] = "DefaultResponse",
  [0x0A] = "ReportAttribute"
}

local zcl_global_mt = {_key_cache = {}}
zcl_global_mt.__index = function(self, k)
  if zcl_global_mt._key_cache[k] == nil then
    local location = string.format("st.zigbee.zcl.global_commands.%s", camel_to_snake(k))
    if location ~= nil then
      zcl_global_mt._key_cache[k] = require(location)[k]
    end
  end
  return zcl_global_mt._key_cache[k]
end
setmetatable(zcl_global_commands, zcl_global_mt)

--- Get a command class by it's ID
--- @param id number the ID of the command
--- @return command_class the command object corresponding to id nil if unrecognized
function zcl_global_commands.get_command_by_id(id)
  if id_map[id] ~= nil then
    return zcl_global_commands[id_map[id]]
  end
  return nil
end

--- Parse a stream of bytes into a global command object
--- @param command_id number the id of the command to parse
--- @param str string the bytes of the message to be parsed
--- @return table the command instance of the parsed body.  This will be a specific type in the ID is recognized a GenericBody otherwise
function zcl_global_commands.parse_global_zcl_command(command_id, str)
  if zcl_global_commands.get_command_by_id(command_id) ~= nil then
    return zcl_global_commands.get_command_by_id(command_id).deserialize(str)
  else
    return generic_body.GenericBody.deserialize(str)
  end
end

return zcl_global_commands
