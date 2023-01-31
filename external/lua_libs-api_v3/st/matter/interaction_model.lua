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
local utils = require "st.utils"
local zap_clusters = require "st.matter.generated.zap_clusters"
local buf_lib = require "st.buf"
local log = require "log"
local TLVParser = require "st.matter.TLV.TLVParser"

--- @module interaction_module
local interaction_module = {}
interaction_module.ATTRIBUTE_WILDCARD = 0xFFFFFFFF

--- @alias InteractionInfoBlock st.matter.interaction_model.InteractionInfoBlock
--- @class st.matter.interaction_model.InteractionInfoBlock
---
--- @field public endpoint_id number device endpoint id
--- @field public cluster_id number cluster path
--- @field public attribute_id number|nil attribute path
--- @field public event_id number|nil event path
--- @field public command_id number|nil command path
--- @field public tlv string|nil data associated with the interaction path
local InteractionInfoBlock = {}
InteractionInfoBlock.NAME = "InteractionInfoBlock"
InteractionInfoBlock.__index = InteractionInfoBlock

--- Constructor for InteractionInfoBlock objects.
---
--- @param cls table UNUSED InteractionInfoBlock reference from __call
--- @param endpoint_id number device endpoint id
--- @param cluster_id number cluster path
--- @param attribute_id number|nil attribute path
--- @param event_id number|nil event path
--- @param command_id number|nil command path
--- @param tlv string|nil data associated with the interaction path
---
--- @return InteractionInfoBlock constructed path
function InteractionInfoBlock.from_parts(cls, endpoint_id, cluster_id, attribute_id, event_id,
                                         command_id, tlv)

  local info_block = {
    endpoint_id = endpoint_id,
    cluster_id = cluster_id,
    attribute_id = attribute_id,
    event_id = event_id,
    command_id = command_id,
    tlv = tlv or "",
  }
  setmetatable(info_block, InteractionInfoBlock)

  -- Augment with data model elements if possible
  local cluster = zap_clusters.get_cluster_from_id(info_block.cluster_id) or info_block.cluster_id
  info_block.cluster = cluster

  if type(cluster) == "table" then
    local attribute = cluster.get_attribute_by_id and cluster:get_attribute_by_id(info_block.attribute_id)
    local clnt_cmd = cluster.get_client_command_by_id and cluster:get_client_command_by_id(info_block.command_id)
    local srv_cmd = cluster.get_server_command_by_id and cluster:get_server_command_by_id(info_block.command_id)
    local event = cluster.get_event_by_id and cluster:get_event_by_id(info_block.event_id)
    if type(attribute) == "table" then
      info_block.attribute = attribute
      info_block.data = #info_block.tlv > 0 and attribute:deserialize(info_block.tlv) or nil
    elseif type(event) == "table" then
      info_block.event = event
      info_block.data = #info_block.tlv > 0 and event:deserialize(info_block.tlv) or nil
    elseif type(clnt_cmd) == "table" then
      info_block.command = clnt_cmd
      info_block.data = #info_block.tlv > 0 and clnt_cmd:deserialize(info_block.tlv) or nil
    elseif type(srv_cmd) == "table" then
      info_block.command = srv_cmd
      info_block.data = #info_block.tlv > 0 and srv_cmd:deserialize(info_block.tlv) or nil
    else -- Manufacturer specific attribute or command
      info_block.data = #info_block.tlv > 0 and TLVParser.decode_tlv(info_block.tlv) or nil
    end
  else -- Manufacturer specific cluster
    info_block.data = #info_block.tlv > 0 and TLVParser.decode_tlv(info_block.tlv) or nil
  end


  return info_block
end

--- Checks if two interaction info blocks are equal to each other
--- 
--- @param cls InteractionInfoBlock
--- @param other InteractionInfoBlock
--- @return boolean
function InteractionInfoBlock.equals(cls, other)
  return cls.endpoint_id == other.endpoint_id and cls.cluster_id == other.cluster_id
           and cls.attribute_id == other.attribute_id and cls.event_id == other.event_id
           and cls.command_id == other.command_id and cls.tlv == other.tlv
end

--- @return string
function InteractionInfoBlock:pretty_print()
  local res = string.format("<%s || ", self.NAME)
  if self.endpoint_id then res = res .. string.format("endpoint: 0x%02X, ", self.endpoint_id) end
  if self.cluster and self.cluster.NAME then
    res = res .. string.format("cluster: %s, ", self.cluster.NAME)
  elseif self.cluster_id then
    res = res .. string.format("cluster: 0x%04X, ", self.cluster_id)
  end
  if self.attribute and self.attribute.NAME then
    res = res .. string.format("attribute: %s, ", self.attribute.NAME)
  elseif self.attribute_id then
    res = res .. string.format("attribute: 0x%04X, ", self.attribute_id)
  end
  if self.command and self.command.NAME then
    res = res .. string.format("command: %s, ", self.command.NAME)
  elseif self.command_id then
    res = res .. string.format("command: 0x%04X, ", self.command_id)
  end
  if self.event and self.event.NAME then
    res = res .. string.format("event: %s, ", self.event.NAME)
  elseif self.event_id then
    res = res .. string.format("event: 0x%04X, ", self.event_id)
  end
  if self.tlv and #self.tlv > 0 then
    if self.data then
      res = res .. string.format("data: %s", self.data)
    else
      res = res .. string.format("tlv: %s, ", utils.get_print_safe_string(self.tlv))
    end
  end
  if res:sub(-2) == ", " then
    res = res:sub(1, -3) .. ">"
  else
    res = res .. ">"
  end

  return res
end

function InteractionInfoBlock:serialize()
  local res = {
    endpoint_id = self.endpoint_id,
    cluster_id = self.cluster_id,
    attribute_id = self.attribute_id,
    event_id = self.event_id,
    command_id = self.command_id,
    tlv = self.tlv,
  }
  return res
end

InteractionInfoBlock.__tostring = InteractionInfoBlock.pretty_print
setmetatable(InteractionInfoBlock, {__call = InteractionInfoBlock.from_parts})
interaction_module.InteractionInfoBlock = InteractionInfoBlock

--- @class st.matter.interaction_model.InteractionRequest
--- @alias InteractionRequest st.matter.interaction_model.InteractionRequest
---
--- Interaction Request sent on a matter socket to initiate an device interaction
--- with a matter device.
---
--- @field public type number Interaction Request type
--- @field public info_blocks table list<InteractionInfoBlock> info_blocks for the given Interaction Request.
--- @field public timed bool|nil This is a timed interaction if true
local InteractionRequest = {}
InteractionRequest.NAME = "InteractionRequest"
InteractionRequest.__index = InteractionRequest

local RequestType = {READ = 0, SUBSCRIBE = 1, WRITE = 2, INVOKE = 3}
local _req_type_strings = {
  [RequestType.READ] = "READ",
  [RequestType.SUBSCRIBE] = "SUBSCRIBE",
  [RequestType.WRITE] = "WRITE",
  [RequestType.INVOKE] = "INVOKE",

}

--- Constructor for InteractionRequests
---
--- @param cls table InteractionRequest reference from __call
--- @param type number Matter Request type
--- @param info_blocks table list<InteractionInfoBlock> info_blocks for the given Interaction Request.
--- @param timed bool|nil Specifies that a write/invoke interaction is a timed interaction
--- @return InteractionRequest constructed InteractionRequest instance
function InteractionRequest.from_parts(cls, type, info_blocks, timed)
  for i, ib in ipairs(info_blocks) do
    if getmetatable(ib) ~= InteractionInfoBlock then
      info_blocks[i] = InteractionInfoBlock(ib.endpoint_id, ib.cluster_id, ib.attribute_id, ib.event_id, ib.command_id, ib.tlv)
    end
  end
  return setmetatable({type = type, info_blocks = info_blocks, timed = timed}, InteractionRequest)
end

---@return string
function InteractionRequest:pretty_print()
  local res = string.format(
                "<%s || type: %s, info_blocks: [", self.NAME,
                  _req_type_strings[self.type] or self.type
              )
  for _, v in ipairs(self.info_blocks) do res = res .. string.format("%s, ", v) end
  if res:sub(-2) == ", " then
    res = res:sub(1, -3) .. "]"
  else
    res = res .. "]"
  end
  if self.timed then res = res .. string.format(", timed: %s>", self.timed) end
  res = res .. ">"
  return res
end

--- Merge the info blocks of a different interaction request into
--- the info blocks of this request, so they can be sent on the channel together.
---
--- Note this does not take into account wildcard clusters. If one IB path contains
--- a wildcard and therefore encompasses another IB path both paths will be merged.
--- 
--- @param cls InteractionRequest request to merge into
--- @param other InteractionRequest request getting merged
--- @return err string|nil
function InteractionRequest.merge(cls, other)
  if type(cls) ~= "table" and type(other) ~= "table" then
    return "Two InteractionRequest objects must be provided"
  end
  if cls.type ~= other.type then return "Cannot merge interaction requests of different types." end
  for _, block in ipairs(other.info_blocks) do
    for _, b in ipairs(cls.info_blocks) do if b:equals(block) then goto continue end end
    table.insert(cls.info_blocks, block)
    ::continue::
  end
end

--- Append the InteractionInfoBlock to the request
---
--- @param ib InteractionInfoBlock to append to the requests info_blocks field
function InteractionRequest:with_info_block(ib)
  if type(ib) ~= "table" or ib.NAME ~= InteractionInfoBlock.NAME then
    log.warn("Must pass InteractionInfoBlock object")
    return
  end

  table.insert(self.info_blocks, ib)
end

--- Serialize the InteractionRequest into the raw table that goes on the matter socket
---
--- @return table
function InteractionRequest:serialize()
  local res = {
    type = self.type,
    info_blocks = {},
    timed = self.timed
  }
  for _, ib in ipairs(self.info_blocks) do
    table.insert(res.info_blocks, ib:serialize())
  end
  return res
end

InteractionRequest.__tostring = InteractionRequest.pretty_print
--- @alias RequestType st.matter.interaction_model.InteractionRequest.RequestType
--- @class st.matter.interaction_model.InteractionRequest.RequestType
---
--- @field public READ number 0
--- @field public SUBSCRIBE number 1
--- @field public WRITE number 2
--- @field public INVOKE number 3
InteractionRequest.RequestType = RequestType
InteractionRequest._req_type_strings = _req_type_strings
setmetatable(InteractionRequest, {__call = InteractionRequest.from_parts})
interaction_module.InteractionRequest = InteractionRequest

--- @alias InteractionResponse st.matter.interaction_model.InteractionResponse
--- @class st.matter.interaction_model.InteractionResponse
---
--- Interaction Response received on a matter socket as a result of initiating a device interaction.
---
--- @field public type number Matter interaction type
--- @field public info_blocks table InteractionInfoBlock interaction info_blocks for the given interaction
--- @field public status number InteractionRequest.status enum value
local InteractionResponse = {}
InteractionResponse.NAME = "InteractionResponse"
InteractionResponse.__index = InteractionResponse

local _STATUS = {
  SUCCESS = 0x00,
  FAILURE = 0x01,
  INVALID_SUBSCRIPTION = 0x7D,
  UNSUPPORTED_ACCESS = 0x7E,
  UNSUPPORTED_ENDPOINT = 0x7F,
  INVALID_ACTION = 0x80,
  UNSUPPPORTED_COMMAND = 0x81,
  INVALID_COMMAND = 0x85,
  UNSUPPORTED_ATTRIBUTE = 0x86,
  CONSTRAINT_ERROR = 0x87,
  UNSUPPPORTED_WRITE = 0x88,
  RESOURCE_EXHAUSTED = 0x89,
  NOT_FOUND = 0x8B,
  UNREPORTABLE_ATTRIBUTE = 0x8C,
  INVALID_DATA_TYPE = 0x8D,
  UNSUPPORTED_READ = 0x8F,
  TIMEOUT = 0x94,
  BUSY = 0x9C,
  UNSUPPORTED_CLUSTER = 0xC3,
  NEEDS_TIMED_INTERACTION = 0xC6,
  UNSUPPORTED_EVENT = 0xC7,
  PATHS_EXHAUSTED = 0xC8,
}
local _STATUS_STRINGS = {
  [_STATUS.SUCCESS] = "SUCCESS",
  [_STATUS.FAILURE] = "FAILURE",
  [_STATUS.INVALID_SUBSCRIPTION] = "INVALID_SUBSCRIPTION",
  [_STATUS.UNSUPPORTED_ACCESS] = "UNSUPPORTED_ACCESS",
  [_STATUS.UNSUPPORTED_ENDPOINT] = "UNSUPPORTED_ENDPOINT",
  [_STATUS.INVALID_ACTION] = "INVALID_ACTION",
  [_STATUS.UNSUPPPORTED_COMMAND] = "UNSUPPPORTED_COMMAND",
  [_STATUS.INVALID_COMMAND] = "INVALID_COMMAND",
  [_STATUS.UNSUPPORTED_ATTRIBUTE] = "UNSUPPORTED_ATTRIBUTE",
  [_STATUS.CONSTRAINT_ERROR] = "CONSTRAINT_ERROR",
  [_STATUS.UNSUPPPORTED_WRITE] = "UNSUPPPORTED_WRITE",
  [_STATUS.RESOURCE_EXHAUSTED] = "RESOURCE_EXHAUSTED",
  [_STATUS.NOT_FOUND] = "NOT_FOUND",
  [_STATUS.UNREPORTABLE_ATTRIBUTE] = "UNREPORTABLE_ATTRIBUTE",
  [_STATUS.INVALID_DATA_TYPE] = "INVALID_DATA_TYPE",
  [_STATUS.UNSUPPORTED_READ] = "UNSUPPORTED_READ",
  [_STATUS.TIMEOUT] = "TIMEOUT",
  [_STATUS.BUSY] = "BUSY",
  [_STATUS.UNSUPPORTED_CLUSTER] = "UNSUPPORTED_CLUSTER",
  [_STATUS.NEEDS_TIMED_INTERACTION] = "NEEDS_TIMED_INTERACTION",
  [_STATUS.UNSUPPORTED_EVENT] = "UNSUPPORTED_EVENT",
  [_STATUS.PATHS_EXHAUSTED] = "PATHS_EXHAUSTED",
}
--- @alias Status st.matter.interaction_model.InteractionResponse.Status
--- @class st.matter.interaction_model.InteractionResponse.Status
---
--- These are the matter interaction status that may be received as part of a device interaction
--- SUCCESS = 0x00,
--- FAILURE = 0x01,
--- INVALID_SUBSCRIPTION = 0x7D,
--- UNSUPPORTED_ACCESS = 0x7E,
--- UNSUPPORTED_ENDPOINT = 0x7F,
--- INVALID_ACTION = 0x80,
--- UNSUPPPORTED_COMMAND = 0x81,
--- INVALID_COMMAND = 0x85,
--- UNSUPPORTED_ATTRIBUTE = 0x86,
--- CONSTRAINT_ERROR = 0x87,
--- UNSUPPPORTED_WRITE = 0x88,
--- RESOURCE_EXHAUSTED = 0x89,
--- NOT_FOUND = 0x8B,
--- UNREPORTABLE_ATTRIBUTE = 0x8C,
--- INVALID_DATA_TYPE = 0x8D,
--- UNSUPPORTED_READ = 0x8F,
--- TIMEOUT = 0x94,
--- BUSY = 0x9C,
--- UNSUPPORTED_CLUSTER = 0xC3,
--- NEEDS_TIMED_INTERACTION = 0xC6,
--- UNSUPPORTED_EVENT = 0xC7,
--- PATHS_EXHAUSTED = 0xC8,
InteractionResponse.Status = _STATUS
InteractionResponse._status_strings = _STATUS_STRINGS

--- @alias InteractionResponseInfoBlock st.matter.interaction_model.InteractionResponseInfoBlock
--- @class st.matter.interaction_model.InteractionResponseInfoBlock
---
--- @field public info_block table data/path associated with the response block
--- @field public status number Interaction status associated with the path
--- @field public cluster_status number|nil Optional cluster status associated with the interaction path.
local InteractionResponseInfoBlock = {}
InteractionResponseInfoBlock.NAME = "InteractionResponseInfoBlock"
InteractionResponseInfoBlock.__index = InteractionResponseInfoBlock

--- Constructor for InteractionResponseInfoBlock objects.
---
--- @param cls table UNUSED InteractionResponseInfoBlock reference from __call
--- @param info_block InteractionInfoBlock Single info block of data in the response
--- @param status string Interaction status associated with the path
--- @param cluster_status number|nil Optional cluster status associated with the interaction path.
--- @param event_number number|nil The event number if this block holds event data.
---
--- @return InteractionResponseInfoBlock constructed path
function InteractionResponseInfoBlock.from_parts(cls, info_block, status, cluster_status, event_number)
  return setmetatable(
           {info_block = info_block, status = status, cluster_status = cluster_status, event_number = event_number},
             InteractionResponseInfoBlock
         )
end

--- Deserialize raw matter socket response info block into InteractionResponseInfoBlock
---
--- @param socket_response_block table
--- @return InteractionResponseInfoBlock
function InteractionResponseInfoBlock.deserialize(socket_response_block)
  local is_success = socket_response_block.status == InteractionResponse.Status.SUCCESS
  local info_block = InteractionInfoBlock(
                       socket_response_block.endpoint_id, socket_response_block.cluster_id,
                         socket_response_block.attribute_id, socket_response_block.event_id,
                         socket_response_block.command_id, socket_response_block.tlv
                     )

  return InteractionResponseInfoBlock(
           info_block, socket_response_block.status, socket_response_block.cluster_status,
             socket_response_block.event_number
         )
end

--- @return string
function InteractionResponseInfoBlock:pretty_print()
  local res = string.format(
                "<%s || status: %s, ", self.NAME, InteractionResponse._status_strings[self.status]
                  or string.format("0x%02X", self.status)
              ) -- status should never be nil
  if self.cluster_status then res = res .. string.format("cluster: 0x%04X, ", self.cluster_id) end
  if self.event_number then res = res .. string.format("event number: 0x%04X, ", self.event_number) end
  res = res .. string.format("%s", self.info_block) .. ">" -- info_block should never be nil
  return res
end
InteractionResponseInfoBlock.__tostring = InteractionResponseInfoBlock.pretty_print
setmetatable(InteractionResponseInfoBlock, {__call = InteractionResponseInfoBlock.from_parts})
interaction_module.InteractionResponseInfoBlock = InteractionResponseInfoBlock

local ResponseType = {
  REPORT_DATA = 0,
  COMMAND_RESPONSE = 1,
  WRITE_RESPONSE = 2,
  SUBSCRIBE_RESPONSE = 3,
}
local _resp_type_strings = {
  [ResponseType.REPORT_DATA] = "REPORT_DATA",
  [ResponseType.COMMAND_RESPONSE] = "COMMAND_RESPONSE",
  [ResponseType.WRITE_RESPONSE] = "WRITE_RESPONSE",
  [ResponseType.SUBSCRIBE_RESPONSE] = "SUBSCRIBE_RESPONSE",
}

--- Constructor for InteractionResponse objects
---
--- @param cls table InteractionResponse reference from __call
--- @param type number Matter interaction type
--- @param info_blocks InteractionInfoBlock[] interaction info_blocks for the given interaction
--- @return InteractionResponse constructed interaction req instance
function InteractionResponse.from_parts(cls, type, info_blocks)
  return setmetatable({type = type, info_blocks = info_blocks}, InteractionResponse)
end

--- Deserialize raw matter socket message into InteractionResponse
---
--- @param socket_message table
--- @return InteractionResponse
function InteractionResponse.deserialize(socket_message)
  local response_blocks = {}
  for _, ib in ipairs(socket_message.info_blocks) do
    block = InteractionResponseInfoBlock.deserialize(ib)
    table.insert(response_blocks, block)
  end
  local response = InteractionResponse(socket_message.response_type, response_blocks)

  return response
end

---@return string
function InteractionResponse:pretty_print()
  local res = string.format(
                "<%s || type: %s, response_blocks: [", self.NAME,
                  _resp_type_strings[self.type] or self.type
              )
  for _, v in ipairs(self.info_blocks) do res = res .. string.format("%s, ", v) end
  if res:sub(-2) == ", " then
    res = res:sub(1, -3) .. "]"
  else
    res = res .. "]"
  end
  res = res .. ">"
  return res
end
InteractionResponse.__tostring = InteractionResponse.pretty_print
--- @alias ResponseType st.matter.interaction_model.InteractionResponse.ResponseType
--- @class st.matter.interaction_model.InteractionResponse.ResponseType
---
--- @field public REPORT_DATA number 0
--- @field public COMMAND_RESPONSE number 1
--- @field public WRITE_RESPONSE number 2
--- @field public SUBSCRIBE_RESPONSE number 3, not used currently as the hub manages the subscription interaction completely
InteractionResponse.ResponseType = ResponseType
InteractionResponse._resp_type_strings = _resp_type_strings
setmetatable(InteractionResponse, {__call = InteractionResponse.from_parts})
interaction_module.InteractionResponse = InteractionResponse

return interaction_module
