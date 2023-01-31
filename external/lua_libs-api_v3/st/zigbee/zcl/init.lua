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
local data_types = require "st.zigbee.data_types"
local zcl_global_commands = require "st.zigbee.zcl.global_commands"
local utils = require "st.zigbee.utils"
local FrameCtrl = require "st.zigbee.zcl.frame_ctrl"
local zcl_clusters = require "st.zigbee.zcl.clusters"
local generic_body = require "st.zigbee.generic_body"
--- @type st.zigbee.zcl.types.ZclStatus
local Status = require "st.zigbee.generated.types.ZclStatus"

local zcl_messages = {}

--- A class representing the Header information of a Zigbee ZCL message
--- @class st.zigbee.zcl.Header
---
--- @field public NAME string "ZclHeader" used for printing
--- @field public frame_ctrl st.zigbee.zcl.FrameCtrl The frame control for this message
--- @field public mfg_code st.zigbee.data_types.Uint16 (optional) present if the frame_ctrl field specifies the message is manufacturer specific
--- @field public seqno st.zigbee.data_types.Uint8 The sequence number of the message (unused in most contexts)
--- @field public cmd st.zigbee.data_types.Uint8 The command ID for this message
local ZclHeader = {
    NAME = "ZCLHeader",
    set_child_field_names = function(self)
        self.frame_ctrl.field_name = "frame_ctrl"
        if self.frame_ctrl:is_mfg_specific_set() then
            self.mfg_code.field_name = "mfg_code"
        end
        self.seqno.field_name = "seqno"
    end,
}
ZclHeader.__index = ZclHeader
zcl_messages.ZclHeader = ZclHeader

--- A function to take a stream of bytes and parse a zigbee message zcl header
--- @param buf Reader The buf Reader in the position of representing the ZclHeader
--- @return st.zigbee.zcl.Header a new instance of the  ZclHeader parsed from the bytes
function ZclHeader.deserialize(buf)
    local s = {}
    s.frame_ctrl = FrameCtrl.deserialize(buf)
    if s.frame_ctrl:is_mfg_specific_set() then
        s.mfg_code = data_types.Uint16.deserialize(buf)
    end
    s.seqno = data_types.Uint8.deserialize(buf)
    s.cmd = data_types.ZCLCommandId.deserialize(buf)
    setmetatable(s, ZclHeader)
    s:set_child_field_names()
    return s
end

--- A helper function used by common code to get all the component pieces of this message frame
---@return table An array formatted table with each component field in the order their bytes should be serialized
function ZclHeader:get_fields()
    local out = {}
    out[#out + 1] = self.frame_ctrl
    if self.frame_ctrl:is_mfg_specific_set() then
        out[#out + 1] = self.mfg_code
    end
    out[#out + 1] = self.seqno
    out[#out + 1] = self.cmd
    return out
end

--- A function to return the total length in bytes this frame uses when serialized
--- @return number the length in bytes of this frame
function ZclHeader:get_length() end
ZclHeader.get_length = utils.length_from_fields

--- A function for serializing this Zcl header
--- @return string This message frame serialized
ZclHeader._serialize = utils.serialize_from_fields

--- A function for printing in a human readable format
--- @return string A human readable representation of this message frame
function ZclHeader:pretty_print() end
ZclHeader.pretty_print = utils.print_from_fields
ZclHeader.__tostring = ZclHeader.pretty_print

--- This is a function to build an zcl header from its individual components
--- @param orig table UNUSED This is the AddressHeader object when called with the syntax ZclHeader(...)
--- @param data_table table a table containing the fields of this ZclHeader.  Only cmd is required as seqno and frame_ctrl will be given default values if not specified
--- @return st.zigbee.zcl.Header The constructed ZclHeader
function ZclHeader.from_values(orig, data_table)
    if data_table.frame_ctrl == nil then
        -- TODO: right default?
        data_table.frame_ctrl = FrameCtrl(0x00)
    end
    if data_table.seqno == nil then
        data_table.seqno = data_types.Uint8(0x00)
    end
    if data_table.cmd == nil then
        error(string.format("%s requires a command id", orig.NAME), 2)
    end
    if data_table.frame_ctrl:is_mfg_specific_set() and data_table.mfg_code == nil then
        error(string.format("%s that is manufacturer specific requires manufacturer code", orig.NAME), 2)
    end
    setmetatable(data_table, ZclHeader)
    data_table:set_child_field_names()
    return data_table
end

setmetatable(zcl_messages.ZclHeader, {
    __call = zcl_messages.ZclHeader.from_values
})

--- A class representing the body of a Zigbee ZCL message
--- @class st.zigbee.zcl.MessageBody
---
--- @field public NAME string "ZclMessageBody" used for printing
local ZclMessageBody = {
    NAME = "ZCLMessageBody"
}
ZclMessageBody.__index = ZclMessageBody
zcl_messages.ZclMessageBody = ZclMessageBody

--- Convert a stream of bytes into a zigbee message ZCL body
--- @param parent st.zigbee.ZigbeeMessageRx|st.zigbee.ZigbeeMessageTx the full Zigbee message containing the appropriate addressing information
--- @param buf Reader The buf Reader in the position of representing the ZclMessageBody
--- @return st.zigbee.zcl.MessageBody a new instance of the ZclMessageBody parsed from the bytes
function ZclMessageBody.deserialize(parent, buf)
    local s = {}
    s.zcl_header = zcl_messages.ZclHeader.deserialize(buf)
    local cluster = zcl_clusters.get_cluster_from_id(parent.address_header.cluster.value)
    if s.zcl_header.frame_ctrl:is_cluster_specific_set() then
        if cluster ~= nil then
            s.zcl_body = cluster:parse_cluster_specific_command(s.zcl_header.cmd, s.zcl_header.frame_ctrl:get_direction(), buf)
        end
    else
        s.zcl_body = zcl_global_commands.parse_global_zcl_command(s.zcl_header.cmd.value, buf)
        -- Convert attribute records to the cluster specific types if possible
        if s.zcl_header.cmd.value == zcl_global_commands.READ_ATTRIBUTE_RESPONSE_ID or s.zcl_header.cmd.value == zcl_global_commands.REPORT_ATTRIBUTE_ID then
            for _, v in ipairs(s.zcl_body.attr_records) do
                if v.status == nil or v.status.value == Status.SUCCESS then
                    if cluster ~= nil then
                        local attr_def = cluster:get_attribute_by_id(v.attr_id.value)
                        -- Augment the base type with any attribute specific functionality (enum defs or helper functions)
                        if attr_def ~= nil and attr_def.augment_type ~= nil then
                            attr_def:augment_type(v.data)
                        end
                    end
                end
            end
        end
    end
    if s.zcl_body == nil then
        s.zcl_body = generic_body.GenericBody.deserialize(buf)
    end
    setmetatable(s, ZclMessageBody)
    return s
end

--- A helper function used by common code to get all the component pieces of this message frame
---@return table An array formatted table with each component field in the order their bytes should be serialized
function ZclMessageBody:get_fields()
    return {
        self.zcl_header,
        self.zcl_body
    }
end

--- A function to return the total length in bytes this frame uses when serialized
--- @return number the length in bytes of this frame
function ZclMessageBody:get_length() end
ZclMessageBody.get_length = utils.length_from_fields

--- A function for serializing this Zcl message
--- @return string This message frame serialized
ZclMessageBody._serialize = utils.serialize_from_fields

--- A function for printing in a human readable format
--- @return string A human readable representation of this message frame
function ZclMessageBody:pretty_print() end
ZclMessageBody.pretty_print = utils.print_from_fields
ZclMessageBody.__tostring = ZclMessageBody.pretty_print

--- This is a function to build an zcl message body from its individual components
--- @param proto table UNUSED This is the ZclMessageBody class when called with the syntax ZclMessageBody(...)
--- @param data_table table a table containing the fields of this ZclMessageBody. zcl_header, and body are required.
--- @return st.zigbee.zcl.MessageBody The constructed  containing the Zcl MessageBody
function ZclMessageBody.from_values(proto, data_table)
    if data_table.zcl_header == nil then
        error(string.format("%s requires valid ZCL Header", proto.NAME), 2)
    end
    if data_table.zcl_body == nil then
        error(string.format("%s requires valid body", proto.NAME), 2)
    end
    setmetatable(data_table, ZclMessageBody)
    return data_table
end

setmetatable(zcl_messages.ZclMessageBody, {
    __call = zcl_messages.ZclMessageBody.from_values,
})

return zcl_messages
