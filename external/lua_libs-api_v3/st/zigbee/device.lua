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
local base_device = require "st.device"
local constants = require "st.zigbee.constants"
local zcl_commands = require "st.zigbee.zcl.global_commands"
local zcl_clusters = require "st.zigbee.zcl.clusters"
local Status = (require "st.zigbee.zcl.types").ZclStatus
local device_management = require "st.zigbee.device_management"
local zigbee_messages = require "st.zigbee.messages"

local CONFIGURED_ATTRIBUTES_KEY = "__configured_attributes"
local MONITORED_ATTRIBUTES_KEY = "__monitored_attributes"
local IAS_CONFIGURE_TYPE = "__ias_configure_type"

--- @module zigbee_device
local zigbee_device = {}

--- @class st.zigbee.Device : st.Device
local ZigbeeDevice = {}
ZigbeeDevice.COMPONENT_TO_ENDPOINT_FUNC = "__comp_to_ep_fn"
ZigbeeDevice.ENDPOINT_TO_COMPONENT_FUNC = "__ep_to_comp_fn"

--- Find the endpoint of the device that supports the given cluster
---
--- @param cluster number The cluster ID to find the endpoint for on the device
--- @return number the first endpoint with the cluster listed in its server clusters, or the
--- fingerprinted_endpoint_id if none include the cluster
function ZigbeeDevice:get_endpoint(cluster)
  --Always check the fingerprinted endpoint first.
  local fingerprinted_ep = self.zigbee_endpoints[self.fingerprinted_endpoint_id]
  if fingerprinted_ep then
    for _, clus in ipairs(fingerprinted_ep.server_clusters) do
      if clus == cluster then
        return fingerprinted_ep.id
      end
    end
  end
  for _, ep in pairs(self.zigbee_endpoints) do
    for _, clus in ipairs(ep.server_clusters) do
      if clus == cluster then
        return ep.id
      end
    end
  end
  return self.fingerprinted_endpoint_id
end

--- Find the manufacturer of this device
---
--- @return string The manufacturer of this device, nil if none present
function ZigbeeDevice:get_manufacturer()
  local fingerprinted_endpoint = self.zigbee_endpoints[self.fingerprinted_endpoint_id]
  if fingerprinted_endpoint ~= nil and fingerprinted_endpoint.manufacturer ~= nil then
    return fingerprinted_endpoint.manufacturer
  end
  for _, ep in pairs(self.zigbee_endpoints) do
    if ep.manufacturer ~= nil then
      return ep.manufacturer
    end
  end
  return nil
end

--- Find the model of this device
---
--- @return string The model of this device, nil if none present
function ZigbeeDevice:get_model()
  local fingerprinted_endpoint = self.zigbee_endpoints[self.fingerprinted_endpoint_id]
  if fingerprinted_endpoint ~= nil and fingerprinted_endpoint.model ~= nil then
    return fingerprinted_endpoint.model
  end
  for _, ep in pairs(self.zigbee_endpoints) do
    if ep.model ~= nil then
      return ep.model
    end
  end
  return nil
end

--- Get the numeric zigbee short address for this device
---
--- @return number The 2 byte Zigbee short address of this device
function ZigbeeDevice:get_short_address()
  return tonumber(self.device_network_id, 16)
end

--- Add a series of attribute configurations to this device
---
--- These devices will be added as configured and/or monitored attributes based
--- on the config flags configurable and monitored.  These flags are assumed to
--- be true.  That is, any value (or non value if they aren't set) is treated as
--- being set true, and only if it is explicitly set to false will a attribute in
--- the list not be added.
---
--- A configured attribute will generate a configure reporting and bind request
--- messages when `configure` is called on the device.  A monitored attribute will
--- monitor responses from the device for the corresponding attributes and send
--- periodic reads if the value isn't updated in too long.
---
--- @param attr_config_list st.zigbee.AttributeConfiguration[] the list of attribute
---  configurations to add
function ZigbeeDevice:add_attributes_from_driver_template(attr_config_list)
  for cap, conf_list in pairs(attr_config_list or {}) do
    if self:supports_capability_by_id(cap) then
      for _, config in ipairs(conf_list) do
        -- Allow for a conf to be marked as non-configurable if it wants to be monitored, but
        -- not configured (ZLL for example)
        if config.configurable ~= false then
          self:add_configured_attribute(config)
        end
        if config.monitored ~= false then
          self:add_monitored_attribute(config)
        end
      end
    end
  end
end

--- Set the configuration type for IAS Zone on this device
---
--- If unset it is assumed that this device does not need IAS Zone configuration
--- @param ias_zone_config_type IAS_ZONE_CONFIGURE_TYPE The type of configuration this device needs
function ZigbeeDevice:set_ias_zone_config_method(ias_zone_config_type)
  self:set_field(IAS_CONFIGURE_TYPE, ias_zone_config_type)
end

--- Check if this devices supports a specific cluster as a server
---
--- @param cluster_id number the cluster ID to check for
--- @param endpoint_id number|nil the endpoint to check cluster support
--- @return bool
function ZigbeeDevice:supports_server_cluster(cluster_id, endpoint_id)
  --helper to check a single endpoint for cluster support
  local ep_supports_server_cluster = function(ep)
    if not ep then return false end
    for _, cluster in ipairs(ep.server_clusters) do
      if cluster == cluster_id then
        return true
      end
    end
    return false
  end

  local ep_idx
  if endpoint_id then
    for key, ep in pairs(self.zigbee_endpoints) do
      if ep.id == endpoint_id then
        ep_idx = key
        break
      end
    end
    return ep_supports_server_cluster(self.zigbee_endpoints[ep_idx])
  end

  for _, ep in pairs(self.zigbee_endpoints) do
    if ep_supports_server_cluster(ep) then
      return true
    end
  end
  return false
end

--- Add a configured attribute for this device
---
--- A configured attribute will generate a configure reporting and bind request
--- messages when `configure` is called on the device.
---
--- @param config st.zigbee.AttributeConfiguration the attribute configuration to add
function ZigbeeDevice:add_configured_attribute(config, opts)
  if not self:supports_server_cluster(config.cluster) and not (opts or {}).force then
    log.warn_with({ hub_logs = true }, string.format("Device does not support cluster 0x%04X not adding configured attribute", config.cluster))
    return
  end
  local configured_attrs = self:get_field(CONFIGURED_ATTRIBUTES_KEY) or {}
  configured_attrs[config.cluster] = configured_attrs[config.cluster] or {}
  configured_attrs[config.cluster][config.attribute] = config
  self:set_field(CONFIGURED_ATTRIBUTES_KEY, configured_attrs)
end

--- Add a monitored attribute for this device
---
--- A monitored attribute will monitor responses from the device for the corresponding attributes and send periodic reads if the value isn't updated in too long.  That length is determined by config.maximum_interval * 1.5
---
--- @param config st.zigbee.AttributeConfiguration the attribute configuration to add
function ZigbeeDevice:add_monitored_attribute(config, opts)
  if not self:supports_server_cluster(config.cluster) and not (opts or {}).force then
    log.info_with({ hub_logs = true }, string.format("Device does not support cluster 0x%04X not adding monitored attribute", config.cluster))
    return
  end
  local monitored_conf = {
    expected_interval = config.maximum_interval * 1.5,
    mfg_code = config.mfg_code,
    last_read_time = os.time() - (math.random(config.maximum_interval - 120, config.maximum_interval)),
    last_heard_time = nil
  }
  local monitored_attrs = self:get_field(MONITORED_ATTRIBUTES_KEY) or {}
  monitored_attrs[config.cluster] = monitored_attrs[config.cluster] or {}
  monitored_attrs[config.cluster][config.attribute] = monitored_conf
  self:set_field(MONITORED_ATTRIBUTES_KEY, monitored_attrs)
end

--- Check all monitored attributes for this device and send a read where necessary
---
--- This will look through all monitored attributes that have been added to this device
--- and if we have not heard from or sent a read in above the expected interval, we will
--- send a read attribute to update our status.
function ZigbeeDevice:check_monitored_attributes()
  local monitored_attrs = self:get_field(MONITORED_ATTRIBUTES_KEY) or {}
  local cur_time = os.time()
  for cluster, attrs in pairs(monitored_attrs) do
    for attr, config in pairs(attrs) do
      if (cur_time - (config.last_heard_time or 0) > config.expected_interval) and
          (cur_time - config.last_read_time > config.expected_interval)
      then
        config.last_read_time = cur_time
        log.info_with({ hub_logs = true }, string.format("Doing health check read for [%s]:%04X:%04X", self.device_network_id, cluster, attr))
        self:send(device_management.attr_refresh(self, cluster, attr, config.mfg_code))
      end
    end
  end
end

--- Check a ZigbeeRx message against our monitored attributes and update the status
---
--- This message is expected to be called with all messages that are received from
--- this device.  If this is a read or report for a monitored attribute the timestamps
--- are updated.  If there is a status involving an unsupported attribute, or a read
--- attribute failure, the offending attribute is removed from the monitored attributes
--- for this device to avoid spurious monitor reads
---
--- @param zb_rx st.zigbee.ZigbeeMessageRx A received Zigbee message from this device
function ZigbeeDevice:attribute_monitor(zb_rx)
  local monitored_attrs = self:get_field(MONITORED_ATTRIBUTES_KEY) or {}
  if (zb_rx.address_header.profile.value == constants.HA_PROFILE_ID and -- is HA
      zb_rx.body.zcl_header ~= nil and -- has a zcl_body
      (not zb_rx.body.zcl_header.frame_ctrl:is_cluster_specific_set())) then -- is global
    local cluster_int = zb_rx.address_header.cluster.value
    -- Make sure everything is inited for this device/cluster
    -- Is an attribute value of some sort
    if (zb_rx.body.zcl_header.cmd.value == zcl_commands.READ_ATTRIBUTE_RESPONSE_ID or zb_rx.body.zcl_header.cmd.value == zcl_commands.REPORT_ATTRIBUTE_ID) then
      for _, v in ipairs(zb_rx.body.zcl_body.attr_records) do
        if (v.status == nil or v.status.value == Status.SUCCESS) then
          if monitored_attrs[cluster_int] ~= nil and monitored_attrs[cluster_int][v.attr_id.value] ~= nil then
            monitored_attrs[cluster_int][v.attr_id.value].last_heard_time = os.time()
            -- If this attribute has reported that it is unsupported, we can stop periodically monitoring it
          elseif v.status == Status.UNSUPPORTED_ATTRIBUTE then
            self:remove_monitored_attribute(cluster_int, v.attr_id.value)
          end
        end
      end
    elseif (zb_rx.body.zcl_header.cmd.value == zcl_commands.CONFIGURE_REPORTING_RESPONSE_ID) then
      -- This means that there are individual attr config responses
      -- It should only happen when there was a non-success status
      if zb_rx.body.zcl_body.global_status == nil then
        for _, conf_record in ipairs(zb_rx.body.zcl_body.config_records) do
          -- If this attribute has reported that it is unsupported, we can stop periodically monitoring it
          if conf_record.status.value == Status.UNSUPPORTED_ATTRIBUTE then
            self:remove_monitored_attribute(cluster_int, conf_record.attr_id.value)
          end
        end
      end
    elseif (zb_rx.body.zcl_header.cmd.value == zcl_commands.DEFAULT_RESPONSE_ID) then
      -- If our read attribute failed, we mark the attributes on that cluster as unsupported to avoid spurious health check reads
      if (zb_rx.body.zcl_body.status.value == Status.FAILURE or zb_rx.body.zcl_body.status.value == Status.UNSUP_GENERAL_COMMAND) and zb_rx.body.zcl_header.cmd.value == zcl_commands.READ_ATTRIBUTE_ID then
        for cluster, attrs in pairs(monitored_attrs) do
          if cluster.cluster == zb_rx.address_header.cluster.value then
            for attr, _ in pairs(attrs) do
              self:remove_monitored_attribute(cluster, attr)
            end
          end
        end
      end
    end
  end
  self:set_field(MONITORED_ATTRIBUTES_KEY, monitored_attrs)
end

--- Remove a monitored attribute on this device
---
--- This will prevent future monitoring of this attribute.
---
--- @param cluster number The id of the cluster of the attribute to remove
--- @param attribute number The id of the attribute to remove
function ZigbeeDevice:remove_monitored_attribute(cluster, attribute)
  local monitored_attrs = self:get_field(MONITORED_ATTRIBUTES_KEY) or {}
  if monitored_attrs[cluster] ~= nil then
    monitored_attrs[cluster][attribute] = nil
  end
  local remove_cluster = true
  for _, _ in pairs(monitored_attrs[cluster] or {}) do
    remove_cluster = false
    break
  end
  if remove_cluster then
    monitored_attrs[cluster] = nil
  end
  self:set_field(MONITORED_ATTRIBUTES_KEY, monitored_attrs)
end

--- Remove a configured attribute on this device.
---
--- This will prevent configuration of this attribute. This must be done before
--- device:configure() is called or it will have no effect.
---
--- @param cluster number The id of the cluster of the attribute to remove
--- @param attribute number The id of the attribute to remove
function ZigbeeDevice:remove_configured_attribute(cluster, attribute)
  local configured_attrs = self:get_field(CONFIGURED_ATTRIBUTES_KEY) or {}
  if configured_attrs[cluster] ~= nil then
    configured_attrs[cluster][attribute] = nil
  end
  local remove_cluster = true
  for _, _ in pairs(configured_attrs[cluster] or {}) do
    remove_cluster = false
    break
  end
  if remove_cluster then
    configured_attrs[cluster] = nil
  end
  self:set_field(CONFIGURED_ATTRIBUTES_KEY, configured_attrs)
end

--- Send the necessary bind requests and reporting configurations to this device
---
--- For each configured attribute on this device send the necessary configure
--- reporting and bind requests to have the device send attribute updates.
--- Attributes are configured for all zigbee endpoints that support the clusters.
function ZigbeeDevice:configure()
  local configured_attrs = self:get_field(CONFIGURED_ATTRIBUTES_KEY) or {}
  for cluster, attrs in pairs(configured_attrs) do
    for _, ep in pairs(self.zigbee_endpoints) do
      if self:supports_server_cluster(cluster, ep.id) then
        self:send(device_management.build_bind_request(self, cluster, self.driver.environment_info.hub_zigbee_eui, ep.id):to_endpoint(ep.id))
        for _, config in pairs(attrs) do
          self:send(device_management.attr_config(self, config):to_endpoint(ep.id))
        end
      end
    end
  end

  local ias_configure_method = self:get_field(IAS_CONFIGURE_TYPE)
  if ias_configure_method ~= nil and self:supports_server_cluster(zcl_clusters.ias_zone_id) then
    device_management.configure_ias_zone(self, ias_configure_method, self.driver.environment_info.hub_zigbee_eui)
  end

end

---@alias CompToEp fun(type: st.zigbee.Device, type: string):number

--- Set a function to map this devices SmartThings components to Zigbee endpoints
---
--- @param comp_ep_fn CompToEp function to do the mapping for this device
function ZigbeeDevice:set_component_to_endpoint_fn(comp_ep_fn)
  self:set_field(ZigbeeDevice.COMPONENT_TO_ENDPOINT_FUNC, comp_ep_fn)
end

---@alias EpToComp fun(type: st.zigbee.Device, type: number):string

--- Set a function to map this devices Zigbee endpoints to SmartThings components
---
--- @param ep_comp_fn EpToComp function to do the mapping for this device
function ZigbeeDevice:set_endpoint_to_component_fn(ep_comp_fn)
  self:set_field(ZigbeeDevice.ENDPOINT_TO_COMPONENT_FUNC, ep_comp_fn)
end

--- Given the component ID find the corresponding endpoint for this device
---
--- This will use the function set by st.zigbee.Device:set_component_to_endpoint_fn to
--- return the appropriate endpoint given the component.  If the function is unset
--- it defaults to the devices "fingerprinted_endpoint_id"
---
--- @param comp_id string the component ID to find the endpoint for
--- @return number the endpoint this component matches to
function ZigbeeDevice:get_endpoint_for_component_id(comp_id)
  local comp_to_ep = self:get_field(ZigbeeDevice.COMPONENT_TO_ENDPOINT_FUNC)
  if comp_to_ep ~= nil then
    return comp_to_ep(self, comp_id)
  else
    return self:get_endpoint()
  end
end

--- Given the endpoint ID find the corresponding component for this device
---
--- This will use the function set by st.zigbee.Device:set_endpoint_to_component_fn to
--- return the appropriate component given the endpoint.  If the function is unset
--- it defaults to "main"
---
--- @param ep number the endpoint ID to find the component for
--- @return string the component ID the endpoint matches to
function ZigbeeDevice:get_component_id_for_endpoint(ep)
  local ep_to_comp = self:get_field(ZigbeeDevice.ENDPOINT_TO_COMPONENT_FUNC)
  if ep_to_comp ~= nil then
    return ep_to_comp(self, ep)
  else
    return "main"
  end
end

--- Emit a capability event for this device coming from the given endpoint
---
--- This uses st.zigbee.Device:get_component_id_for_endpoint to find the appropriate component
--- and emit the event for that component
---
--- @param endpoint number the endpoint ID a message was received from
--- @param event table the capability event to generate
function ZigbeeDevice:emit_event_for_endpoint(endpoint, event)
  local find_child_fn = self:get_field(base_device.FIND_CHILD_KEY)
  if find_child_fn ~= nil then
    local child = find_child_fn(self, endpoint)
    if child ~= nil then
      child:emit_event(event)
      return
    end
  end
  -- If no child was found, emit the event for this device
  local comp_id = self:get_component_id_for_endpoint(endpoint)
  local comp = self.profile.components[comp_id]
  return self:emit_component_event(comp, event)
end

--- Send a read attribute command for all configured attributes on this device
function ZigbeeDevice:refresh(endpoint)
  local configured_attrs = self:get_field(CONFIGURED_ATTRIBUTES_KEY) or {}
  local has_zone_status = false
  for cluster, attrs in pairs(configured_attrs) do
    for attr, config in pairs(attrs) do
      if not has_zone_status and cluster == zcl_clusters.ias_zone_id then
        local IASZone = zcl_clusters.IASZone
        if attr == IASZone.attributes.ZoneStatus.ID then
          has_zone_status = true
        end
      end
      for _, ep in pairs(self.zigbee_endpoints) do
        if endpoint == nil or ep.id == endpoint then
          if self:supports_server_cluster(cluster, ep.id) then
            self:send(device_management.attr_refresh(self, cluster, attr, config.mfg_code):to_endpoint(ep.id))
          end
        end
      end
    end
  end
  local ias_configure_method = self:get_field(IAS_CONFIGURE_TYPE)
  if not has_zone_status and ias_configure_method ~= nil and self:supports_server_cluster(zcl_clusters.ias_zone_id) then
    local IASZone = zcl_clusters.IASZone
    self:send(IASZone.attributes.ZoneStatus:read(self))
  end
end

--- Send a ZigbeeMessageTx to this device
---
--- @param zb_tx st.zigbee.ZigbeeMessageTx the message to send to this device
function ZigbeeDevice:send(zb_tx)
  if type(zb_tx) == "table" and getmetatable(zb_tx) == zigbee_messages.ZigbeeMessageTx then
    self.log.info_with({ hub_logs = true }, string.format("sending Zigbee message: %s", zb_tx))
    self.zigbee_channel:send(self.id, zb_tx)
  else
    error(string.format("[%s] You can only send a ZigbeeMessageTx to a ZigbeeDevice", self.id), 2)
  end
end

--- Send a ZigbeeMessageTx to this device and component
---
--- @param component_id string the component id to send this message to
--- @param zb_tx st.zigbee.ZigbeeMessageTx the message to send to this device
function ZigbeeDevice:send_to_component(component_id, zb_tx)
  if type(zb_tx) == "table" and getmetatable(zb_tx) == zigbee_messages.ZigbeeMessageTx then
    self.zigbee_channel:send(self.id, zb_tx:to_component(self, component_id))
  else
    error(string.format("[%s] You can only send a ZigbeeMessageTx to a ZigbeeDevice", self.id), 2)
  end
end

function ZigbeeDevice.init(cls, driver, raw_device)
  -- Convert zigbee_endpoints table keys from strings to numbers.
  -- dkjson doesn't do this when the json keys start at "0" because lua lists are 1 indexed.
  local corrected_eps = {}
  for key, ep in pairs(raw_device.zigbee_endpoints) do
    corrected_eps[tonumber(key)] = ep
  end
  raw_device.zigbee_endpoints = corrected_eps

  local out_device = base_device.Device.init(cls, driver, raw_device)
  out_device.zigbee_channel = driver.zigbee_channel
  base_device.Device._protect(cls, out_device)
  out_device:load_updated_data(raw_device)
  -- Populate the devices information from the driver
  ZigbeeDevice.add_attributes_from_driver_template(out_device, driver.cluster_configurations)
  if driver.ias_zone_configuration_method ~= nil then
    ZigbeeDevice.set_ias_zone_config_method(out_device, driver.ias_zone_configuration_method)
  end
  log.trace_with({ hub_logs = true }, out_device:debug_pretty_print())

  return out_device
end

--- Return a string representation of device model and supported cluster information
---
--- @return string A string containing the device model and supported cluster information
function ZigbeeDevice:debug_pretty_print()
  outputString = "Zigbee Device: " .. self.id .. "\n"
  if (self:get_manufacturer() ~= nil and self:get_model() ~= nil) then
    outputString = outputString .. string.format("Manufacturer: %s Model: %s", self:get_manufacturer(), self:get_model()) .. "\n"
    for _, ep in pairs(self.zigbee_endpoints) do
      clusters = ""
      for _, cluster in ipairs(ep.server_clusters) do
        local cluster_string = string.format("0x%04X", cluster)
        clusters = clusters .. string.format("%s", zcl_clusters.id_to_name_map[cluster] or cluster_string) .. ", "
      end
      outputString = outputString .. "\t[".. ep.id .. "]: " .. clusters:sub(1,-3)
    end
  end
  return outputString
end

ZigbeeDevice.CLASS_NAME = "ZigbeeDevice"

--- @function Device:pretty_print
--- Get a string with the ID and label of the device
---
--- @return string a short string representation of the device
function ZigbeeDevice:pretty_print()
  local label_str = ""
  if self.label ~= nil then
    label_str = string.format(" (%s)", self.label)
  end
  return string.format("<%s: %s [0x%04X]%s>", self.CLASS_NAME, self.id, self:get_short_address(), label_str)
end
ZigbeeDevice.__tostring = ZigbeeDevice.pretty_print

zigbee_device.ZigbeeDevice = ZigbeeDevice

setmetatable(ZigbeeDevice, {
  __index = base_device.Device,
  __call = ZigbeeDevice.init
})

return zigbee_device
