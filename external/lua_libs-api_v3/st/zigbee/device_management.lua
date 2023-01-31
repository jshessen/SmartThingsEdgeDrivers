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
local log = require "log"
local constants = require "st.zigbee.constants"
local data_types = require "st.zigbee.data_types"
local zcl_clusters = require "st.zigbee.zcl.clusters"
local bind_request = require "st.zigbee.zdo.bind_request"
local zcl_commands = require "st.zigbee.zcl.global_commands"
local messages = require "st.zigbee.messages"
local zcl_messages = require "st.zigbee.zcl"
local zdo_messages = require "st.zigbee.zdo"
local capabilities = require "st.capabilities"

--- @module device_management
local device_management = {}

--- Build a read attribute command
---
--- @param device st.zigbee.Device the device to address the read attribute to
--- @param cluster number the cluster id of the attribute to read
--- @param attribute number the attribute id to read
--- @param mfg_code number Optional: the mfg code if the attribute is mfg specific
--- @return st.zigbee.zcl.ReadAttribute the constructed read attribute ZigbeeTx command
function device_management.attr_refresh(device, cluster, attribute, mfg_code)
  local attr_read = zcl_commands.ReadAttribute(
      { data_types.AttributeId(attribute) }
  )
  local addr_header = messages.AddressHeader(
    constants.HUB.ADDR,
    constants.HUB.ENDPOINT,
    device:get_short_address(),
    device:get_endpoint(cluster),
    constants.HA_PROFILE_ID, cluster
  )
  local zcl_header = zcl_messages.ZclHeader(
      {
        cmd = data_types.ZCLCommandId(attr_read.ID)
      }
  )
  if mfg_code ~= nil then
    zcl_header.frame_ctrl:set_mfg_specific()
    zcl_header.mfg_code = data_types.Uint16(mfg_code)
    zcl_header:set_child_field_names()
  end
  local message_body = zcl_messages.ZclMessageBody({
    zcl_header = zcl_header,
    zcl_body = attr_read
  })
  return messages.ZigbeeMessageTx(
      {
        address_header = addr_header,
        body = message_body
      }
  )
end

--- Build a ZDO bind request
---
--- @param device st.Device the device to address the bind request to
--- @param cluster number the cluster id of the attribute to read
--- @param hub_zigbee_eui string the byte string for the hub's zigbee eui for binding
--- @param ep_id number|nil the endpoint to bind
--- @return st.zigbee.zdo.BindRequest the constructed bind request ZigbeeTx command
function device_management.build_bind_request(device, cluster, hub_zigbee_eui, ep_id)
  local addr_header = messages.AddressHeader(constants.HUB.ADDR, constants.HUB.ENDPOINT, device:get_short_address(), device.fingerprinted_endpoint_id, constants.ZDO_PROFILE_ID, bind_request.BindRequest.ID)
  local bind_req = bind_request.BindRequest(device.zigbee_eui, ep_id or device:get_endpoint(cluster), cluster, bind_request.ADDRESS_MODE_64_BIT, hub_zigbee_eui, constants.HUB.ENDPOINT)
  local message_body = zdo_messages.ZdoMessageBody({
    zdo_body = bind_req
  })
  local bind_cmd = messages.ZigbeeMessageTx({
    address_header = addr_header,
    body = message_body
  })
  return bind_cmd
end

--- Configure an attribute for reporting
---
--- This will not include the ZDO bind request for the cluster, which will need to be sent
--- separately.
---
--- @param device st.Device the device to configure for reporting
--- @param attr_config st.zigbee.AttributeConfiguration the attribute configuration to set up
--- @return st.zigbee.zcl.ConfigureReporting the constructed configure reporting ZigbeeTx command
function device_management.attr_config(device, attr_config)
  local conf_record = zcl_commands.ConfigureReporting.AttributeReportingConfiguration(
      {
        direction = data_types.Uint8(0),
        attr_id = data_types.AttributeId(attr_config.attribute),
        minimum_reporting_interval = data_types.Uint16(attr_config.minimum_interval),
        maximum_reporting_interval = data_types.Uint16(attr_config.maximum_interval),
        data_type = data_types.ZigbeeDataType(attr_config.data_type.ID),
        reportable_change = attr_config.reportable_change
      }
  )
  local config_rep_body = zcl_commands.ConfigureReporting({ conf_record })
  local addr_header = messages.AddressHeader(constants.HUB.ADDR, constants.HUB.ENDPOINT, device:get_short_address(), device:get_endpoint(attr_config.cluster), constants.HA_PROFILE_ID, attr_config.cluster)
  local zcl_header = zcl_messages.ZclHeader(
      {
        cmd = data_types.ZCLCommandId(config_rep_body.ID)
      }
  )
  if attr_config.mfg_code ~= nil then
    zcl_header.frame_ctrl:set_mfg_specific()
    zcl_header.mfg_code = data_types.Uint16(attr_config.mfg_code)
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

--- Check all devices managed by this driver and send reads for stale attributes
---
--- This will call the check_for_health function for each device managed by this driver
--- @param driver Driver the driver context
function device_management.check_all_devices_for_health(driver)
  for uuid, device in pairs(driver.device_cache) do
    device:check_monitored_attributes()
  end
end

--- Write the hubs Zigbee EUI as the CIE address for the IAS Zone device
---
--- @param device st.Device the device to write the CIE address to
--- @param cie_address string the 8 byte address to write to the cie address for the IAS zone cluster
function device_management.write_ias_cie_address(device, cie_address)
  local IASZone = zcl_clusters.IASZone
  local cie_attr_write = zcl_commands.WriteAttribute.AttributeRecord(data_types.AttributeId(IASZone.attributes.IASCIEAddress.ID), data_types.ZigbeeDataType(data_types.IeeeAddress.ID), data_types.IeeeAddress(cie_address))
  local write_body = zcl_commands.WriteAttribute({ cie_attr_write })
  local addr_header = messages.AddressHeader(constants.HUB.ADDR, constants.HUB.ENDPOINT, device:get_short_address(), device:get_endpoint(IASZone.ID), constants.HA_PROFILE_ID, IASZone.ID)
  local zcl_header = zcl_messages.ZclHeader(
      {
        cmd = data_types.ZCLCommandId(write_body.ID)
      }
  )
  local message_body = zcl_messages.ZclMessageBody({
    zcl_header = zcl_header,
    zcl_body = write_body
  })
  device:send(
      messages.ZigbeeMessageTx(
          {
            address_header = addr_header,
            body = message_body
          }
      )
  )
end

--- Configure IAS Zone for the given device using the given ias_zone_configuration_method
---
--- @param device st.Device the device to configure IAS Zone for
--- @param ias_zone_configuration_method number One of the defined IAS Zone configuration methods
--- @param cie_address string the 8 byte address to write to the cie address for the IAS zone cluster
function device_management.configure_ias_zone(device, ias_zone_configuration_method, cie_address)
  local IASZone = zcl_clusters.IASZone
  if ias_zone_configuration_method == constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE then
    device_management.write_ias_cie_address(device, cie_address)
    local enroll_resp = IASZone.server.commands.ZoneEnrollResponse(device, 0x00, 0x00)
    device:send(enroll_resp)
  elseif ias_zone_configuration_method == constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_REQUEST then
    device_management.write_ias_cie_address(device, cie_address)
  elseif ias_zone_configuration_method == constants.IAS_ZONE_CONFIGURE_TYPE.TRIP_TO_PAIR then
    device_management.write_ias_cie_address(device, cie_address)
  elseif ias_zone_configuration_method == constants.IAS_ZONE_CONFIGURE_TYPE.CUSTOM then
    log.info_with({ hub_logs = true }, "IAS Zone configuration method set to custom, not automatically configuring.")
  end
end

--- Configure all of the necessary attributes for a given device
---
--- This will look at all the attribute_configurations defined for a driver and attempt to configure each of those
--- attributes for the given device
---
--- @param driver Driver the driver context
--- @param device st.Device the device to configure
function device_management.configure(driver, device)
  if driver.environment_info.hub_zigbee_eui == nil then
    log.warn_with({ hub_logs = true }, "Can't configure Zigbee device without hub Zigbee EUI information")
    return
  end
  driver:inject_capability_command(device,
                                   {
                                     capability = capabilities.refresh.ID,
                                     command = capabilities.refresh.commands.refresh.NAME,
                                     args = {}
                                   }
  )
  device:configure()
end

--- Refresh all of the configured attributes for a given device
---
--- This will look at all the attribute_configurations defined for a driver and attempt to read the value
--- of each of them for the given device
---
--- @param driver Driver the driver context
--- @param device st.Device the device to configure
function device_management.refresh(driver, device)
  device:refresh()
end

--- Set up a driver to have attribute health checking enabled
---
--- @param driver Driver the driver to configure health checks for
function device_management.init_device_health(driver)
  driver:call_on_schedule(30, device_management.check_all_devices_for_health, "zigbee health poll")
end

return device_management
