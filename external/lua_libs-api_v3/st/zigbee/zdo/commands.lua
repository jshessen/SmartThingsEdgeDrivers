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
local bind_request = require "st.zigbee.zdo.bind_request"
local bind_request_response = require "st.zigbee.zdo.bind_request_response"
local generic_body = require "st.zigbee.generic_body"
local binding_table_request = require "st.zigbee.zdo.mgmt_bind_request"
local binding_table_response = require "st.zigbee.zdo.mgmt_bind_response"

--- @module st.zigbee.zdo.commands
local zdo_commands = {}

zdo_commands.BindRequest = bind_request.BindRequest
zdo_commands.BindRequestResponse = bind_request_response.BindRequestResponse
zdo_commands.MgmtBindResponse = binding_table_response.MgmtBindResponse
zdo_commands.MgmtBindRequest = binding_table_request.MgmtBindRequest

zdo_commands.commands = {
  [zdo_commands.BindRequest.ID] = zdo_commands.BindRequest,
  [zdo_commands.BindRequestResponse.ID] = zdo_commands.BindRequestResponse,
  [zdo_commands.MgmtBindResponse.ID] = zdo_commands.MgmtBindResponse,
  [zdo_commands.MgmtBindRequest.ID] = zdo_commands.MgmtBindRequest
}

--- Parse a stream of bytes into a zdo command object
--- @param command_cluster number the id of the command to parse
--- @param str string the bytes of the message to be parsed
--- @return table the command instance of the parsed body.  This will be a specific type in the ID is recognized a GenericBody otherwise
function zdo_commands.parse_zdo_command(command_cluster, str)
  if zdo_commands.commands[command_cluster] ~= nil then
    return zdo_commands.commands[command_cluster].deserialize(str)
  else
    return generic_body.GenericBody.deserialize(str)
  end
end

return zdo_commands
