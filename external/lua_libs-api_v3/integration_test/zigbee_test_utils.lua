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
local report_attr = require "st.zigbee.zcl.global_commands.report_attribute"
local read_attr = require "st.zigbee.zcl.global_commands.read_attribute"
local config_reporting = require "st.zigbee.zcl.global_commands.configure_reporting"
local messages = require "st.zigbee.messages"
local data_types = require "st.zigbee.data_types"
local zb_const = require "st.zigbee.constants"
local FrameCtrl = require "st.zigbee.zcl.frame_ctrl"
local bind_request = require "st.zigbee.zdo.bind_request"
local mgmt_bind_request = require "st.zigbee.zdo.mgmt_bind_request"
local mgmt_bind_response = require "st.zigbee.zdo.mgmt_bind_response"
local zdo_messages = require "st.zigbee.zdo"
local zcl_messages = require "st.zigbee.zcl"
local generic_body = require "st.zigbee.generic_body"
local int_test = require "integration_test"

local zigbee_test_utils = {
  mock_hub_eui = "\x00\x01\x02\x03\x04\x05\x07\x08"
}

--- Build a ZCL received Message of a custom/manufacturer specific command
---
--- @param device integration_test.MockDevice The device to construct the message from
--- @param cluster number the cluster ID the command is from
--- @param cmd_id number the command ID of the message
--- @param mfg_code number the manufacturer code of the device
--- @param payload string the bytestring of the command payload
--- @param ep number|nil optional endpoint the message should be from, defaults to the devices fingerprinted_endpoint_id
--- @return st.zigbee.ZigbeeMessageRx the constructed message from the device
zigbee_test_utils.build_custom_command_id = function(device, cluster, cmd_id, mfg_code, payload, ep)

  local header_args = {
    frame_ctrl = FrameCtrl(0x01),
    cmd = data_types.ZCLCommandId(cmd_id)
  }

  local zclh = zcl_messages.ZclHeader(header_args)
  if mfg_code ~= nil then
    header_args.frame_ctrl = FrameCtrl(FrameCtrl.MFG_SPECIFIC)
    header_args.mfg_code = data_types.validate_or_build_type(mfg_code, data_types.Uint16, "mfg_code")
    zclh.frame_ctrl:set_cluster_specific()
  end
  local endpoint = ep ~= nil and ep or device.fingerprinted_endpoint_id
  local addrh = messages.AddressHeader(
      device:get_short_address(),
      endpoint,
      zb_const.HUB.ADDR,
      zb_const.HUB.ENDPOINT,
      zb_const.HA_PROFILE_ID,
      cluster
  )

  local payload_body = generic_body.GenericBody(payload)

  local message_body = zcl_messages.ZclMessageBody({
    zcl_header = zclh,
    zcl_body = payload_body
  })

  local send_message = messages.ZigbeeMessageRx({
    address_header = addrh,
    body = message_body
  })

  return send_message
end

--- Build a ZDO mgmt bind response coming from a device
---
--- @param device integration_test.MockDevice The device to construct the message from
--- @param response st.zigbee.zdo.MessageBody The message body
--- @return st.zigbee.ZigbeeMessageRx the constructed message from the device
zigbee_test_utils.build_zdo_mgmt_bind_response = function(device, response)
  local addr_header = messages.AddressHeader(
      zb_const.HUB.ADDR,
      zb_const.HUB.ENDPOINT,
      device:get_short_address(),
      device.fingerprinted_endpoint_id,
      zb_const.ZDO_PROFILE_ID,
      mgmt_bind_response.MGMT_BIND_RESPONSE
    )
  local message_body = zdo_messages.ZdoMessageBody({
    zdo_body = response
  })
  return messages.ZigbeeMessageRx({
    address_header = addr_header,
    body = message_body
  })
end

--- Build a ZCL sent message of a custom/manufacturer specific command
---
--- @param device integration_test.MockDevice The device to construct the message from
--- @param cluster_id number the cluster ID the command is from
--- @param cmd_id number the command ID of the message
--- @param mfg_code number the manufacturer code of the device
--- @param payload string the bytestring of the command payload
--- @return st.zigbee.ZigbeeMessageTx the constructed message to the device
zigbee_test_utils.build_tx_custom_command_id = function(device, cluster_id, cmd_id, mfg_code, payload)
  local header_args = {
    cmd = data_types.ZCLCommandId(cmd_id)
  }
  local zclh = zcl_messages.ZclHeader(header_args)
  if mfg_code ~= nil then
    header_args.mfg_code = data_types.validate_or_build_type(mfg_code, data_types.Uint16, "mfg_code")
    zclh.frame_ctrl:set_cluster_specific()
    zclh.frame_ctrl:set_mfg_specific()
  end

  local addrh = messages.AddressHeader(
    zb_const.HUB.ADDR,
    zb_const.HUB.ENDPOINT,
    device:get_short_address(),
    device.fingerprinted_endpoint_id,
    zb_const.HA_PROFILE_ID,
    cluster_id
  )

  local payload_body = generic_body.GenericBody(payload)

  local message_body = zcl_messages.ZclMessageBody({
    zcl_header = zclh,
    zcl_body = payload_body
  })

  local send_message = messages.ZigbeeMessageTx({
    address_header = addrh,
    body = message_body
  })

  return send_message
end

--- Build a ZCL attribute report of a custom/manufacturer specific attribute
---
--- @param device integration_test.MockDevice The device to construct the message from
--- @param cluster number the cluster ID the command is from
--- @param attr_list table a list of attribute constructions (attr_id:number, data_type:number, value:any)
--- @param mfg_code number the manufacturer code of the device
--- @return st.zigbee.ZigbeeMessageRx the constructed message from the device
zigbee_test_utils.build_attribute_report = function(device, cluster, attr_list, mfg_code)
  local attr_records = {}
  for i, args in ipairs(attr_list) do
    attr_records[#attr_records + 1] = report_attr.ReportAttributeAttributeRecord(table.unpack(args))
  end
  local report_body = report_attr.ReportAttribute(attr_records)

  local header_args = { cmd = data_types.ZCLCommandId(report_body.ID) }
  if mfg_code ~= nil then
    header_args.frame_ctrl = FrameCtrl(FrameCtrl.MFG_SPECIFIC)
    header_args.mfg_code = data_types.validate_or_build_type(mfg_code, data_types.Uint16, "mfg_code")
  end
  local zclh = zcl_messages.ZclHeader(header_args)
  local addrh = messages.AddressHeader(
      device:get_short_address(),
      device.fingerprinted_endpoint_id,
      zb_const.HUB.ADDR,
      zb_const.HUB.ENDPOINT,
      zb_const.HA_PROFILE_ID,
      cluster
  )
  local message_body = zcl_messages.ZclMessageBody({
    zcl_header = zclh,
    zcl_body = report_body
  })
  local report = messages.ZigbeeMessageRx({
    address_header = addrh,
    body = message_body
  })
  return report
end

--- Build a ZCL attribute read of a custom/manufacturer specific attribute
---
--- @param device integration_test.MockDevice The device to construct the message from
--- @param cluster number the cluster ID the command is from
--- @param attr_list number[] a list of attribute ids
--- @param mfg_code number the manufacturer code of the device
--- @return st.zigbee.ZigbeeMessageTx the constructed message to the device
zigbee_test_utils.build_attribute_read = function(device, cluster_id, attr_list, mfg_code)
  local read_body = read_attr.ReadAttribute(attr_list)

  local header_args = {
    cmd = data_types.ZCLCommandId(read_body.ID)
  }
  if mfg_code ~= nil then
    header_args.frame_ctrl = FrameCtrl(FrameCtrl.MFG_SPECIFIC)
    header_args.mfg_code = data_types.validate_or_build_type(mfg_code, data_types.Uint16, "mfg_code")
  end
  local zclh = zcl_messages.ZclHeader(header_args)
  local addrh = messages.AddressHeader(
      zb_const.HUB.ADDR,
      zb_const.HUB.ENDPOINT,
      device:get_short_address(),
      device.fingerprinted_endpoint_id,
      zb_const.HA_PROFILE_ID,
      cluster_id
  )
  local message_body = zcl_messages.ZclMessageBody({
    zcl_header = zclh,
    zcl_body = read_body
  })
  return messages.ZigbeeMessageTx({
    address_header = addrh,
    body = message_body
  })
end

--- Build a ZDO bind request for a device
---
--- @param device integration_test.MockDevice The device to construct the message from
--- @param hub_eui string the bytestring of the hub's Zigbee EUI
--- @param cluster number the cluster to bind
--- @param ep_id number|nil the endpoint to bind
--- @return st.zigbee.ZigbeeMessageTx the constructed message to the device
function zigbee_test_utils.build_bind_request(device, hub_eui, cluster, ep_id)
  local addr_header = messages.AddressHeader(zb_const.HUB.ADDR, zb_const.HUB.ENDPOINT, device:get_short_address(), device.fingerprinted_endpoint_id, zb_const.ZDO_PROFILE_ID, bind_request.BindRequest.ID)
  local bind_req = bind_request.BindRequest(device.zigbee_eui, ep_id or device.fingerprinted_endpoint_id, cluster, bind_request.ADDRESS_MODE_64_BIT, hub_eui, zb_const.HUB.ENDPOINT)
  local message_body = zdo_messages.ZdoMessageBody({
    zdo_body = bind_req
  })
  return messages.ZigbeeMessageTx({
    address_header = addr_header,
    body = message_body
  })
end

--- Build a ZDO mgmt bind request for a device
---
--- @param device integration_test.MockDevice The device to construct the message from
--- @return st.zigbee.ZigbeeMessageTx the constructed message to the device
function zigbee_test_utils.build_mgmt_bind_request(device)
  local addr_header = messages.AddressHeader(
    zb_const.HUB.ADDR,
    zb_const.HUB.ENDPOINT,
    device:get_short_address(),
    device.fingerprinted_endpoint_id,
    zb_const.ZDO_PROFILE_ID,
    mgmt_bind_request.BINDING_TABLE_REQUEST_CLUSTER_ID
  )
  local request = mgmt_bind_request.MgmtBindRequest(0) -- Single argument of the start index to query the table
  local message_body = zdo_messages.ZdoMessageBody({
    zdo_body = request
  })
  return messages.ZigbeeMessageTx({
    address_header = addr_header,
    body = message_body
  })
end


--- Build a ZCL attribute configuration of a custom/manufacturer specific attribute
---
--- @param device integration_test.MockDevice The device to construct the message from
--- @param cluster number the cluster ID the command is from
--- @param attr number the attribute ID to build a configuration for
--- @param min_int number the minimum reporting interval for this configuration
--- @param max_int number the maximum reporting interval for this configuration
--- @param data_type number the data type of the attribute for this configuration
--- @param rep_change any the reportable change for this configuration
--- @param mfg_code number the manufacturer code of the device
--- @return st.zigbee.ZigbeeMessageTx the constructed message to the device
function zigbee_test_utils.build_attr_config(device, cluster, attr, min_int, max_int, data_type, rep_change, mfg_code)
  local conf_record = config_reporting.ConfigureReporting.AttributeReportingConfiguration(
      {
        direction = data_types.Uint8(0),
        attr_id = data_types.AttributeId(attr),
        minimum_reporting_interval = data_types.Uint16(min_int),
        maximum_reporting_interval = data_types.Uint16(max_int),
        data_type = data_types.ZigbeeDataType(data_type.ID),
        reportable_change = rep_change
      }
  )
  local config_rep_body = config_reporting.ConfigureReporting({ conf_record })
  local addr_header = messages.AddressHeader(zb_const.HUB.ADDR, zb_const.HUB.ENDPOINT, device:get_short_address(), device.fingerprinted_endpoint_id, zb_const.HA_PROFILE_ID, cluster)
  local zcl_header = zcl_messages.ZclHeader(
      {
        cmd = data_types.ZCLCommandId(config_rep_body.ID)
      }
  )
  if mfg_code ~= nil then
    zcl_header.frame_ctrl:set_mfg_specific()
    zcl_header.mfg_code = data_types.validate_or_build_type(mfg_code, data_types.Uint16, "mfg_code")
  end
  local message_body = zcl_messages.ZclMessageBody({
    zcl_header = zcl_header,
    zcl_body = config_rep_body
  })
  return messages.ZigbeeMessageTx(
      {
        address_header = addr_header,
        body = message_body
      }
  )
end

--- Set up all tests within this file to have the zigbee env info (hub eui) pre populated in the driver under test
function zigbee_test_utils.prepare_zigbee_env_info()
  local driver_added = function(d)
    d.environment_info.hub_zigbee_eui = zigbee_test_utils.mock_hub_eui
  end
  int_test.add_test_env_setup_func(driver_added)
end

--- Set up an expected return timer that will never fire for the Zigbee driver's periodic health check
---
--- Because the ZigbeeDriver will automatically set up a periodic timer to monitor when we last heard from an attribute
--- and try to read an updated value if we haven't in a while, it can be beneficial in a test environment to suppress
--- this timer from ever firing to only test what you want.
function zigbee_test_utils.init_noop_health_check_timer()
  int_test.timer.__create_and_queue_never_fire_timer("interval", "health_check")
end

return zigbee_test_utils
