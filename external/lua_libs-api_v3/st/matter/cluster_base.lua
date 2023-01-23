-- Copyright 2022 SmartThings
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
local im = require "st.matter.interaction_model"
local utils = require "st.utils"
local data_types = require "st.matter.data_types"
local buf_lib = require "st.buf"

---@module cluster_base
local cluster_base_index = {}

-- --- @class MatterClusterAttribute
-- ---
-- --- @field public NAME string the name of this attribute
-- --- @field public ID number the ID of this attribute
-- --- @field public cluster MatterCluster A reference to the cluster this is a part of
local MatterClusterAttribute = {}

-- --- Build a DataType instance of this attribute
-- ---
-- --- This can also be called with the constructor syntax MatterClusterAttribute(value)
-- ---
-- --- @param orig MatterClusterAttribute The MatterClusterAttribute object we are instantiating
-- --- @param value value The value to use to create the st.matter.data_types.DataType
-- --- @return st.matter.data_types.DataType The constructed DataType of this attribute
function MatterClusterAttribute.new_value(orig, value) end

--- Builds an Interaction Model Read Request
---
--- @param device st.matter.Device the device to send the Read Request to
--- @param endpoint_id number|nil
--- @param cluster_id number|nil the cluster id of the cluster the attribute is a part of
--- @param attribute_id number|nil the attribute id to read
--- @param event_id number|nil
--- @return st.matter.interaction_model.InteractionRequest
function cluster_base_index.read(device, endpoint_id, cluster_id, attribute_id, event_id)
  local interaction_info_block = im.InteractionInfoBlock(
                                   endpoint_id, cluster_id, attribute_id, event_id, nil, -- command
    ""
                                 )

  local interaction_info_blocks = {interaction_info_block}

  local matter_request = im.InteractionRequest(
                           im.InteractionRequest.RequestType.READ, interaction_info_blocks, nil,
                             nil, nil
                         )
  return matter_request
end

--- Builds an Interaction Model Write Request
---
--- @param device st.matter.Device the device to send the Write Request to
--- @param endpoint_id number|nil
--- @param cluster_id number the cluster id of the cluster the attribute is a part of
--- @param attribute_id number|nil the attribute id to write to
--- @param event_id number|nil TODO can you even write an event?
--- @param data st.matter.data_types.DataType the value to write
--- @param timed boolean|nil indicates a timed request, defaults to false.
--- @return st.matter.interaction_model.InteractionRequest
function cluster_base_index.write(device, endpoint_id, cluster_id, attribute_id, event_id, data,
                                  timed)
  local tlv_encoded = ""
  if data ~= nil then
    local buf = buf_lib.Writer()

    local parser = data_types[data.NAME]
    tlv_encoded = parser.serialize(data, buf, true)
  end

  local interaction_info_block = im.InteractionInfoBlock(
                                   endpoint_id, cluster_id, attribute_id, event_id, nil, tlv_encoded
                                 )
  interaction_info_block.data = data

  local interaction_info_blocks = {interaction_info_block}

  local matter_request = im.InteractionRequest(
                           im.InteractionRequest.RequestType.WRITE, interaction_info_blocks, timed
                         )
  return matter_request
end

--- Builds an Interaction Model Subscribe Request
---
--- @param device st.matter.Device the device to send the Subscribe Request to
--- @param endpoint_id number|nil
--- @param cluster_id number the cluster id of the cluster the attribute is a part of
--- @param attribute_id number|nil the attribute id to subscribe to
--- @param event_id number|nil
--- @return st.matter.interaction_model.InteractionRequest
function cluster_base_index.subscribe(device, endpoint_id, cluster_id, attribute_id, event_id)
  local interaction_info_block = im.InteractionInfoBlock(
                                   endpoint_id, cluster_id, attribute_id, event_id, nil, ""
                                 )

  local interaction_info_blocks = {interaction_info_block}

  local matter_request = im.InteractionRequest(
                           im.InteractionRequest.RequestType.SUBSCRIBE, interaction_info_blocks, nil
                         )
  return matter_request
end

--- Builds an Interaction Model Invoke Command
---
--- @param self table
--- @param device st.matter.Device the device to send the command to
--- @param command_parameters table command parameters
--- @param endpoint_id number
--- @param cluster_id number the cluster id of the cluster the attribute is a part of
--- @param command_id number
--- @return st.matter.interaction_model.InteractionRequest
function cluster_base_index.build_cluster_command(self, device, command_parameters, endpoint_id,
                                                  cluster_id, command_id, timed_invoke)
  local tlv_encoded = ""
  if utils.table_size(command_parameters) > 0 then
    local parser = data_types["Structure"]
    tlv_encoded = parser.serialize(command_parameters, nil, true)
  end

  local interaction_info_block = im.InteractionInfoBlock(
                                   endpoint_id, cluster_id, nil, nil, command_id,
                                     tlv_encoded
                                 )
  interaction_info_block.data = data_types.Structure(command_parameters)
  interaction_info_blocks = {interaction_info_block}

  local matter_request = im.InteractionRequest(
                           im.InteractionRequest.RequestType.INVOKE, interaction_info_blocks, timed_invoke
                         )
  return matter_request
end

--- Builds an Interaction Model Command Response for use with driver tests
---
--- @param self table
--- @param device st.matter.Device the device to send the command from
--- @param endpoint_id number endpoint on the device
--- @param cluster_id number the cluster id of the command
--- @param command_id number the command id
--- @param tlv string|nil the data associated with the response
--- @param status number the status of the command
function cluster_base_index.build_test_command_response(self, device, endpoint_id, cluster_id,
                                                        command_id, tlv, status)
  status = status or im.InteractionResponse.Status.SUCCESS
  tlv = tlv or ""
  local interaction_info_block = im.InteractionInfoBlock(
                                   endpoint_id, cluster_id, nil, nil, command_id, tlv
                                 )

  local interaction_response_info_block = im.InteractionResponseInfoBlock(
                                            interaction_info_block, status, nil, nil
                                          )

  local info_blocks = {}
  info_blocks[1] = interaction_response_info_block

  local matter_response = im.InteractionResponse(
                            im.InteractionResponse.ResponseType.COMMAND_RESPONSE, info_blocks, nil,
                              nil
                          )
  return matter_response
end

--- Builds an Interaction Model Report Data Response for use with driver tests
---
--- @param device st.matter.Device the device to send the response from
--- @param endpoint_id number endpoint on the device
--- @param cluster_id number the cluster id of the attribute
--- @param attribute_id number the attribute id of the attribute that is reporting
--- @param data string the data to report
--- @param status number the status of the command
function cluster_base_index.build_test_report_data(device, endpoint_id, cluster_id, attribute_id,
                                                   data, status)
  status = status or im.InteractionResponse.Status.SUCCESS
  local tlv_encoded = ""
  if data ~= nil then
    local buf = buf_lib.Writer()

    local parser = data_types[data.NAME]
    tlv_encoded = parser.serialize(data, buf, true)
  end

  local interaction_info_block = im.InteractionInfoBlock(
                                   endpoint_id, cluster_id, attribute_id, nil, nil, tlv_encoded
                                 )

  local interaction_response_info_block = im.InteractionResponseInfoBlock(
                                            interaction_info_block, status, nil, nil
                                          )

  local interaction_response = im.InteractionResponse(
                                 im.InteractionResponse.ResponseType.REPORT_DATA,
                                   {interaction_response_info_block}, nil, nil
                               )

  return interaction_response
end

--- Builds an Interaction Model Report Data Response for use with driver tests
---
--- @param device st.matter.Device the device to send the response from
--- @param endpoint_id number endpoint on the device
--- @param cluster_id number the cluster id of the attribute
--- @param event_id number the attribute id of the attribute that is reporting
--- @param data string the data to report
--- @param status number the status of the command
function cluster_base_index.build_test_event_report(device, endpoint_id, cluster_id, event_id,
                                                   data, status)
  status = status or im.InteractionResponse.Status.SUCCESS
  local tlv_encoded = ""
  if data ~= nil then
    tlv_encoded = data.serialize(data.elements, nil, true)
  end

  local interaction_info_block = im.InteractionInfoBlock(
                                   endpoint_id, cluster_id, nil, event_id, nil, tlv_encoded
                                 )

  local interaction_response_info_block = im.InteractionResponseInfoBlock(
                                            interaction_info_block, status, nil, nil
                                          )

  local interaction_response = im.InteractionResponse(
                                 im.InteractionResponse.ResponseType.REPORT_DATA,
                                   {interaction_response_info_block}, nil, nil
                               )
  return interaction_response
end

return cluster_base_index
