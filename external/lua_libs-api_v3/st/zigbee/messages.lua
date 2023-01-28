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
---@module messages
local messages = {}

--- @type st.zigbee.data_types
local data_types = require "st.zigbee.data_types"
local utils = require "st.zigbee.utils"
local generic_body = require "st.zigbee.generic_body"
local zb_const = require "st.zigbee.constants"
local zcl_messages = require "st.zigbee.zcl"
local zdo_messages = require "st.zigbee.zdo"
local log = require "log"

--- A class representing the addressing information of a Zigbee message
--- @class st.zigbee.AddressHeader
---
--- @field public NAME string "AddressHeader" used for printing
--- @field public src_addr st.zigbee.data_types.Uint16 The source address of the device sending the message
--- @field public src_endpoint st.zigbee.data_types.Uint8 The source endpoint of the device sending the message
--- @field public dest_addr st.zigbee.data_types.Uint16 The destination address of the recipient of the message
--- @field public dest_endpoint st.zigbee.data_types.Uint8 The destination endpoint of the recipient of the message
--- @field public profile st.zigbee.data_types.Uint16 The profile Id of the message being sent
--- @field public cluster st.zigbee.data_types.ClusterId The cluster Id of the message
local AddressHeader = {
  NAME = "AddressHeader",
  set_child_field_names = function(self)
    local names = {
      "src_addr",
      "src_endpoint",
      "dest_addr",
      "dest_endpoint",
      "profile",
      "cluster",
    }
    for _, v in ipairs(names) do
      self[v].field_name = v
    end
  end,
}
AddressHeader.__index = AddressHeader
messages.AddressHeader = AddressHeader

--- A function to take a stream of bytes and parse a zigbee message address header
--- @param buf string The byte string starting with the beginning of the bytes representing the AddressHeader
--- @return st.zigbee.AddressHeader a new instance of the address header parsed from the bytes
function AddressHeader.deserialize(buf)
  local s = proto or {}
  local fields = {
    { name = "src_addr", type = data_types.Uint16 },
    { name = "src_endpoint", type = data_types.Uint8 },
    { name = "dest_addr", type = data_types.Uint16 },
    { name = "dest_endpoint", type = data_types.Uint8 },
    { name = "profile", type = data_types.Uint16 },
    { name = "cluster", type = data_types.ClusterId },
  }
  utils.deserialize_field_list(s, fields, buf)
  setmetatable(s, AddressHeader)
  return s
end

--- A helper function used by common code to get all the component pieces of this message frame
---@return table An array formatted table with each component field in the order their bytes should be serialized
function AddressHeader:get_fields()
  local out = {
    self.src_addr,
    self.src_endpoint,
    self.dest_addr,
    self.dest_endpoint,
    self.profile,
    self.cluster,
  }
  return out
end

--- A function to return the total length in bytes this frame uses when serialized
--- @return number the length in bytes of this frame
function AddressHeader:get_length() end
AddressHeader.get_length = utils.length_from_fields

--- Internal function for serializing this AddressHeader
--- @return string This message frame serialized
AddressHeader._serialize = utils.serialize_from_fields

--- A function for printing in a human readable format
--- @return string A human readable representation of this message frame
function AddressHeader:pretty_print() end
AddressHeader.pretty_print = utils.print_from_fields
AddressHeader.__tostring = AddressHeader.pretty_print

--- This is a function to build an address header from its individual components
--- @param orig table UNUSED This is the AddressHeader object when called with the syntax AddressHeader(...)
--- @param src_addr st.zigbee.data_types.Uint16 The source address of the device sending the message
--- @param src_endpoint st.zigbee.data_types.Uint8 The source endpoint of the device sending the message
--- @param dest_addr st.zigbee.data_types.Uint16 The destination address of the recipient of the message
--- @param dest_endpoint st.zigbee.data_types.Uint8 The destination endpoint of the recipient of the message
--- @param profile st.zigbee.data_types.Uint16 The profile Id of the message being sent
--- @param cluster st.zigbee.data_types.ClusterId The cluster Id of the message
--- @return st.zigbee.AddressHeader The constructed AddressHeader
function AddressHeader.init(orig, src_addr, src_endpoint, dest_addr, dest_endpoint, profile, cluster)
  local out = {}
  out.src_addr = data_types.Uint16(src_addr)
  out.src_endpoint = data_types.Uint8(src_endpoint)
  out.dest_addr = data_types.Uint16(dest_addr)
  out.dest_endpoint = data_types.Uint8(dest_endpoint)
  out.profile = data_types.Uint16(profile)
  out.cluster = data_types.ClusterId(cluster)
  setmetatable(out, AddressHeader)
  out:set_child_field_names()
  return out
end

setmetatable(messages.AddressHeader, {
  __call = messages.AddressHeader.init
})


--- A generic class representing an outgoing zigbee message (hub -> device).  For most cases
--- this class shouldn't be instantiated on it's own, but instead one of ZdoMessageTx or
--- ZclMessageTx should be used.  This would only be used if using a profile other than
--- those and needing a truly custom body
--- @class st.zigbee.ZigbeeMessageTx
---
--- @field public NAME string "ZigbeeMessageTx" used for printing
--- @field public tx_options st.zigbee.data_types.Uint16 Transmit options for this command
--- @field public address_header st.zigbee.AddressHeader The addressing information for this message
--- @field public body GenericBody only used for a custom body
local ZigbeeMessageTx = {
  NAME = "ZigbeeMessageTx"
}
ZigbeeMessageTx.__index = ZigbeeMessageTx
messages.ZigbeeMessageTx = ZigbeeMessageTx

--- A function to take a stream of bytes and parse a Zigbee Tx message.
--- In general this will result in either a ZclMessageTx or ZdoMessageTx, and
--- would only result in a generic ZigbeeMessageTx if the profile was unknown
--- @param buf Reader The buf positioned at the beginning of the bytes representing the message
--- @return st.zigbee.ZigbeeMessageTx one form of a Zigbee tx message
function ZigbeeMessageTx.deserialize(buf)
  local self = proto or {}
  self.tx_options = data_types.Uint16.deserialize(buf)
  self.tx_options.field_name = "tx_options"

  self.address_header = messages.AddressHeader.deserialize(buf)
  local profileId = self.address_header.profile.value
  setmetatable(self, ZigbeeMessageTx)
  if profileId == zb_const.HA_PROFILE_ID or profileId == zb_const.ZLL_PROFILE_ID or profileId == zb_const.SMARTTHINGS_PROFILE_ID then
    self.body = zcl_messages.ZclMessageBody.deserialize(self, buf)
  elseif profileId == zb_const.ZDO_PROFILE_ID then
    self.body = zdo_messages.ZdoMessageBody.deserialize(self, buf)
  else
    self.body = generic_body.GenericBody.deserialize(buf)
  end
  return self
end

function ZigbeeMessageTx:get_fields()
  return {
    self.tx_options,
    self.address_header,
    self.body
  }
end

--- Set the endpoint of the message to that supplied
---
--- This is primarily useful in simpler message construction through chaining
---
--- @param self st.zigbee.ZigbeeMessageTx the message to update the addressing for
--- @param endpoint number the endpoint to address the message to
--- @return st.zigbee.ZigbeeMessageTx self with the updated endpoint
function ZigbeeMessageTx:to_endpoint(endpoint)
  assert(type(endpoint) == "number", "endpoint must be a number")
  self.address_header.dest_endpoint = data_types.validate_or_build_type(endpoint, data_types.Uint8, "dest_endpoint")
  return self
end

--- Set the addressing of the message to match a devices component
---
--- This is primarily useful in simpler message construction through chaining
---
--- @param self st.zigbee.ZigbeeMessageTx the message to update the addressing for
--- @param device st.zigbee.Device the device this is going to
--- @param component_id string the device component this should be addressed to
--- @return st.zigbee.ZigbeeMessageTx self with the updated endpoint
function ZigbeeMessageTx:to_component(device, component_id)
  local ep = device:get_endpoint_for_component_id(component_id)
  if type(component_id) ~= "string" or ep == nil then
    error("Invalid component ID for device " .. device:pretty_print())
  end
  self.address_header.dest_endpoint = data_types.validate_or_build_type(ep, data_types.Uint8, "dest_endpoint")
  return self
end

--- A function to return the total length in bytes this frame uses when serialized
--- @return number the length in bytes of this frame
function ZigbeeMessageTx:get_length() end
ZigbeeMessageTx.get_length = utils.length_from_fields

--- A function to serialize this message
--- @return string the bytes representing this message
ZigbeeMessageTx._serialize = utils.serialize_from_fields

--- A function for printing in a human readable format
--- @return string A human readable representation of this message frame
function ZigbeeMessageTx:pretty_print() end
ZigbeeMessageTx.pretty_print = utils.print_from_fields
ZigbeeMessageTx.__tostring = ZigbeeMessageTx.pretty_print

function ZigbeeMessageTx.init(orig, data_table)
  if data_table.address_header == nil then
    error(string.format("%s requires valid address header", orig.NAME), 2)
  end
  if data_table.body == nil then
    error(string.format("%s requires valid body", orig.NAME), 2)
  end
  if data_table.tx_options == nil then
    data_table.tx_options = data_types.Uint16(0x00)
  end
  setmetatable(data_table, ZigbeeMessageTx)
  return data_table
end

setmetatable(messages.ZigbeeMessageTx, {
  __call = messages.ZigbeeMessageTx.init,
  __newindex = function(t, key, value) error("Zigbee Message class tables should not be modified.", 2) end,
})

--- @class st.zigbee.ZigbeeMessageRx
---
--- A generic class representing an incoming zigbee message (device -> hub).  For most cases
--- this class shouldn't be instantiated on it's own, but instead one of :lua:class:`ZdoMessageRx <ZdoMessageRx>` or
--- :lua:class:`ZclMessageRx <ZclMessageRx>` should be used.  This would only be used if using a profile other than
--- those and needing a truly custom body
---
--- @field public NAME string "ZigbeeMessageRx" used for printing
--- @field public type st.zigbee.data_types.Uint8 message type (internal use only)
--- @field public address_header st.zigbee.AddressHeader The addressing information for this message
--- @field public lqi st.zigbee.data_types.Uint8 The lqi of this message
--- @field public rssi st.zigbee.data_types.Int8 The rssi of this message
--- @field public body GenericBody only used for a custom body
local ZigbeeMessageRx = {
  NAME = "ZigbeeMessageRx"
}
ZigbeeMessageRx.__index = ZigbeeMessageRx
messages.ZigbeeMessageRx = ZigbeeMessageRx

--- A function to take a stream of bytes and parse a received Zigbee Rx message (device -> hub)
--- This will typically result in either a :lua:class:`ZdoMessageRx <ZdoMessageRx>` or
--- :lua:class:`ZclMessageRx <ZclMessageRx>`  but if the profile ID is unrecognized will
--- just result in this class with a
--- @param buf Reader The buf positioned at the beginning of the bytes representing the ZigbeeMessageRx
--- @param opts table Additional options for controlling deserialize
--- @return st.zigbee.ZigbeeMessageRx one form of a Zigbee rx message
function ZigbeeMessageRx.deserialize(buf, opts)
  local self = proto or {}
  self.type = data_types.Uint8.deserialize(buf)
  self.type.field_name = "type"

  self.address_header = messages.AddressHeader.deserialize(buf)

  self.lqi = data_types.Uint8.deserialize(buf)
  self.lqi.field_name = "lqi"

  self.rssi = data_types.Int8.deserialize(buf)
  self.rssi.field_name = "rssi"

  self.body_length = data_types.Uint16.deserialize(buf)
  self.body_length.field_name = "body_length"

  local profileId = self.address_header.profile.value
  setmetatable(self, ZigbeeMessageRx)
  local buf_loc = buf:tell()
  local status, value

  local additional_zcl_profiles = ((opts or {}).additional_zcl_profiles or {})

  if profileId == zb_const.HA_PROFILE_ID or profileId == zb_const.ZLL_PROFILE_ID or additional_zcl_profiles[profileId] then
    status, value = pcall(zcl_messages.ZclMessageBody.deserialize, self, buf)
  elseif profileId == zb_const.ZDO_PROFILE_ID then
    status, value = pcall(zdo_messages.ZdoMessageBody.deserialize, self, buf)
  else
    status, value = pcall(generic_body.GenericBody.deserialize, buf)
  end
  if status then
    self.body = value
  else
    log.warn_with({ hub_logs = true }, string.format("Error encountered parsing Zigbee message defaulting to generic body: %s", value))
    -- Reset the buffer to the position before it hit errors
    buf:seek(-(buf:tell() - buf_loc))
    self.body = generic_body.GenericBody.deserialize(buf)
  end
  return self
end

function ZigbeeMessageRx:get_fields()
  return {
    self.type,
    self.address_header,
    self.lqi,
    self.rssi,
    self.body_length,
    self.body
  }
end

--- Set the endpoint of the message source
---
--- This is primarily useful for building test commands
---
--- @param self st.zigbee.ZigbeeMessageRx the message to update the addressing for
--- @param endpoint number the endpoint to address the message to
--- @return st.zigbee.ZigbeeMessageRx self with the updated endpoint
function ZigbeeMessageRx:from_endpoint(endpoint)
  assert(type(endpoint) == "number", "endpoint must be a number")
  self.address_header.src_endpoint = data_types.validate_or_build_type(endpoint, data_types.Uint8, "src_endpoint")
  return self
end

--- Set the addressing of the message to match a devices component
---
--- This is primarily useful for building test commands
---
--- @param self st.zigbee.ZigbeeMessageRx the message to update the addressing for
--- @param device st.zigbee.Device the device this is going to
--- @param component_id string the device component this should be addressed to
--- @return st.zigbee.ZigbeeMessageRx self with the updated endpoint
function ZigbeeMessageRx:from_component(device, component_id)
  local ep = device:get_endpoint_for_component_id(component_id)
  if type(component_id) ~= "string" or ep == nil then
    error("Invalid component ID for device " .. device:pretty_print(), 2)
  end
  self.address_header.src_endpoint = data_types.validate_or_build_type(ep, data_types.Uint8, "src_endpoint")
  return self
end

--- A function to return the total length in bytes this frame uses when serialized
--- @return number the length in bytes of this frame
function ZigbeeMessageRx:get_length() end
ZigbeeMessageRx.get_length = utils.length_from_fields

--- A function for serializing this Zigbee Message
--- @return string the bytes representing this message
ZigbeeMessageRx._serialize = utils.serialize_from_fields

--- A function for printing in a human readable format
--- @return string A human readable representation of this message frame
function ZigbeeMessageRx:pretty_print() end
ZigbeeMessageRx.pretty_print = utils.print_from_fields
ZigbeeMessageRx.__tostring = ZigbeeMessageRx.pretty_print

function ZigbeeMessageRx.init(orig, data_table)
  if data_table.address_header == nil then
    error(string.format("%s requires valid address header", orig.NAME), 2)
  end
  if data_table.body == nil then
    error(string.format("%s requires valid body", orig.NAME), 2)
  end
  if data_table.body_length == nil then
    data_table.body_length = data_types.Uint16(data_table.body:get_length())
  end

  -- Default values
  if data_table.type == nil then
    data_table.type = data_types.Uint8(0x00)
  end
  if data_table.lqi == nil then
    data_table.lqi = data_types.Uint8(0x00)
  end
  if data_table.rssi == nil then
    data_table.rssi = data_types.Int8(0x00)
  end

  setmetatable(data_table, ZigbeeMessageRx)
  return data_table
end

setmetatable(messages.ZigbeeMessageRx, {
  __call = messages.ZigbeeMessageRx.init,
  __newindex = function(t, key, value) error("Zigbee Message class tables should not be modified.", 2) end,
})

return messages
