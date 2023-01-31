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
local capabilities = require "st.capabilities"
local json = require "st.json"
local base64 = require "st.base64"
local utils = require "st.utils"
local net_utils = require "st.net_utils"
local datastore = require "datastore"
local devices = _envlibrequire("devices")
local device_lib = require "st.device"
local thread = require "st.thread"
local cosock = require "cosock"
local log = require "log"
local realsocket = require "socket"
local socket = cosock.socket
local timer = cosock.timer
local CapabilityCommandDispatcher = require "st.capabilities.dispatcher"
local DeviceLifecycleDispatcher = require "st.device_lifecycle_dispatcher"

local CONTROL_THREAD_NAME = "control"

--- @module driver_templates
local driver_templates = {}

--- @class message_channel
local message_channel = {}


--- @class SubDriver
---
--- A SubDriver is a way to bundle groups of functionality that overrides the basic behavior of a given driver by gating
--- it behind a can_handle function.
---
--- @field public can_handle fun(type: Driver, type: Device, ...):boolean whether or not this sub driver, if it has a matching handler, should handle a message
--- @field public zigbee_handlers table the same zigbee handlers that a driver would have
--- @field public zwave_handlers table the same zwave handlers that a driver would have
--- @field public capability_handlers table the same capability handlers that a driver would have
local sub_driver = {}


--- @class Driver
---
--- This is a template class to define the various parts of a driver table.  The Driver object represents all of the
--- state necessary for running and supporting the operation of this class of devices.  This can be as specific as a
--- single model of device, or if there is much shared functionality can manage several different models and
--- manufacturers.
---
--- Drivers go through initial set up on hub boot, or initial install, but after that the Drivers are considered
--- long running.  That is, they will behave as if they run forever.  As a result, they should have a main run loop
--- that continues to check for work/things to process and handles it when available.  For MOST uses the provided
--- run function should work, and there should be no reason to overwrite the existing run loop.
---
--- @field public NAME string a name used for debug and error output
--- @field public capability_channel message_channel the communication channel for capability commands/events
--- @field public lifecycle_channel message_channel the communication channel for device lifecycle events
--- @field private timer_api timer_api utils related to timer functionality
--- @field private device_api device_api utils related to device functionality
--- @field private environment_channel message_channel the communication channel for environment info updates
--- @field public timers table this will contain a list of in progress timers running for the driver
--- @field public capability_dispatcher CapabilityCommandDispatcher dispatcher for routing capability commands
--- @field public lifecycle_dispatcher DeviceLifecycleDispatcher dispatcher for routing lifecycle events
--- @field public sub_drivers SubDriver[] A list of sub_drivers that contain more specific behavior behind a can_handle function
local Driver = {}
Driver.__index = Driver

driver_templates.Driver = Driver

--------------------------------------------------------------------------------------------
-- Timer related functions
--------------------------------------------------------------------------------------------

--- A template of a callback for a timer
---
--- @param driver Driver the driver the callback was associated with
function driver_templates.timer_callback_template(driver)
end

--- Set up a one shot timer to hit the callback after delay_s seconds
---
--- @param self Driver the driver setting up the timer
--- @param delay_s number the number of seconds to wait before hitting the callback
--- @param callback function the function to call when the timer expires. @see Driver.timer_callback_template
--- @param name string an optional name for the timer
--- @return timer the created timer
function Driver:call_with_delay(delay_s, callback, name)
  if type(delay_s) ~= "number" then
    error("Timer delay must be a number", 2)
  end
  return self._driver_thread:call_with_delay(delay_s, function()
    callback(self)
  end, name)
end

--- Set up a periodic timer to hit the callback every interval_s seconds
---
--- @param self Driver the driver setting up the timer
--- @param interval_s number the number of seconds to wait between hitting the callback
--- @param callback function the function to call when the timer expires. @see Driver.timer_callback_template
--- @param name string an optional name for the timer
--- @return timer the created timer
function Driver:call_on_schedule(interval_s, callback, name)
  if type(interval_s) ~= "number" then
    error("Timer interval must be a number", 2)
  end
  return self._driver_thread:call_on_schedule(interval_s, function()
    callback(self)
  end, name)
end

--- Cancel a timer set up on this driver
---
--- @param self Driver the driver with the timer
--- @param t Timer the timer to cancel
function Driver:cancel_timer(t)
  self._driver_thread:cancel_timer(t)
end

--------------------------------------------------------------------------------------------
-- Default capability command handling
--------------------------------------------------------------------------------------------

--- Default handler that can be registered for the capability message channel
---
--- @param self Driver the driver to handle the capability commands
--- @param capability_channel message_channel the capability message channel with data to be read
function Driver:capability_message_handler(capability_channel)
  local device_uuid, cap_data = capability_channel:receive()
  local cap_table = json.decode(cap_data)
  local device = self:get_device_info(device_uuid)
  if device ~= nil and cap_table ~= nil then
    device.thread:queue_event(self.handle_capability_command, self, device, cap_table)
  end
end

--- Default capability command handler.  This takes the parsed command and will look up the command handler and call it
---
--- @param self Driver the driver to handle the capability commands
--- @param device st.Device the device that this command was sent to
--- @param cap_command table the capability command table including the capability, command, component and args
--- @param quiet boolean if true, suppress logging; useful if the driver is injecting a capability command itself
function Driver:handle_capability_command(device, cap_command, quiet)
  local capability = cap_command.capability
  local command = cap_command.command
  if not capabilities[capability].commands[command]:validate_and_normalize_command(cap_command) then
    error(
      string.format("Invalid capability command: %s.%s (%s)", capability, command, utils.stringify_table(command.args))
    )
  else
    if device:supports_capability_by_id(capability) then
      local _ = quiet or device.log.info_with({ hub_logs = true }, string.format("received command: %s", json.encode(cap_command)))
      self.capability_dispatcher:dispatch(self, device, cap_command)
    else
      local _ = quiet or device.log.warn_with({ hub_logs = true }, string.format("received command for unsupported capability: %s", json.encode(cap_command)))
    end
  end
end

--- Inject a capability command into the capability command dispatcher.
---
--- @param self Driver the driver to handle the capability command
--- @param device st.Device the device for which this command is injected
--- @param cap_command table the capability command table including the capability, command, component and args
function Driver:inject_capability_command(device, cap_command)
  local quiet = true -- quiet so we do not mistake this for a message received from an external entity
  self:handle_capability_command(device, cap_command, quiet)
end

--------------------------------------------------------------------------------------------
-- Default message channel handling
--------------------------------------------------------------------------------------------

--- Default handler that can be registered for the device lifecycle events
---
--- @param self Driver the driver to handle the device lifecycle events
--- @param lifecycle_channel message_channel the lifecycle message channel with data to be read
function Driver:lifecycle_message_handler(lifecycle_channel)
  local device_uuid, event, data = lifecycle_channel:receive()

  -- temporary workaround to prevent double initing until "added" message behavior is changed
  local device_already_existed = self.device_cache and self.device_cache[device_uuid]

  local device = self:get_device_info(device_uuid)
  local args = {}
  if event == "infoChanged" then
    local old_device_st_store = self:get_device_info(device_uuid).st_store
    args["old_st_store"] = old_device_st_store
    local raw_device = json.decode(data)
    self.device_cache[device_uuid]:load_updated_data(raw_device)
    device = self.device_cache[device_uuid]
  end

  device.log.info_with({ hub_logs = true }, string.format("received lifecycle event: %s", event, utils.stringify_table(args)))
  device.thread:queue_event(self.lifecycle_dispatcher.dispatch, self.lifecycle_dispatcher, self, device, event, args)

  -- Do event cleanup that needs to happen regardless
  if event == "doConfigure" then
    -- After the configuration, mark the device as being provisioned
    device.thread:queue_event(device.try_update_metadata, device, { provisioning_state = "PROVISIONED" })
  elseif event == "added" then
    if not device_already_existed then
      device.thread:queue_event(self.lifecycle_dispatcher.dispatch, self.lifecycle_dispatcher, self, device, "init")
    end
  elseif event == "removed" then
    if self.device_cache ~= nil then
      self.device_cache[device_uuid] = nil
    end
    device.thread:queue_event(device.deleted, device)
  end
end

--- Default handler that can be registered for the driver lifecycle events
---
--- @param self Driver the driver to handle the device lifecycle events
--- @param ch message_channel the lifecycle message channel with data to be read
function Driver:driver_lifecycle_message_handler(ch)
  local event = ch:receive()
  if self.driver_lifecycle ~= nil then
    self._driver_thread:queue_event(self.driver_lifecycle, self, event)
  end
end

--- Default handler that can be registered for the device discovery events
---
--- @param self Driver the driver to handle the device discovery events
--- @param discovery_channel message_channel the discovery message channel with data to be read
function Driver:discovery_message_handler(discovery_channel)
  local event, opts = discovery_channel:receive()

  if event == "start" then
    if self.discovery ~= nil then
      -- lazily create discovery thread, only needed in some drivers
      if not self.discovery_state.thread then
        self.discovery_state.thread = thread.Thread(self, "discovery")
      end

      if not self.discovery_state.is_running then
	local should_continue = function() return self.discovery_state.is_running or false end

        self.discovery_state.is_running = true
        self.discovery_state.thread:queue_event(self.discovery, self, opts, should_continue)
      end
   end
  elseif event == "stop" then
    self.discovery_state.is_running = nil
    if self.discovery_state.thread then
      self.discovery_state.thread:close()
      self.discovery_state.thread = nil
    end
  end
end

--- Default handler that can be registered for the environment info messages
---
--- @param self Driver the driver to handle the device lifecycle events
--- @param environment_channel message_channel the environment update message channel
function Driver:environment_info_handler(environment_channel)
  local msg_type, msg_val = environment_channel:receive()
  self.environment_info = self.environment_info or {}
  if msg_type == "zigbee" then
    self.environment_info.hub_zigbee_eui = base64.decode(msg_val.hub_zigbee_id)
  elseif msg_type == "lan" then
    if msg_val.hub_ipv4 ~= nil then
      self.environment_info.hub_ipv4 = msg_val.hub_ipv4
      if self.lan_info_changed_handler ~= nil then
        self:lan_info_changed_handler(self.environment_info.hub_ipv4)
      end
    end
  elseif msg_type == "zwave" then
    log.debug_with({ hub_logs = true }, "Z-Wave hub node ID environment changed.")
    self.environment_info.hub_zwave_id = msg_val.hub_node_id
    if self.zwave_hub_node_id_changed_handler ~= nil then
      self:zwave_hub_node_id_changed_handler(self.environment_info.hub_zwave_id)
    end
  end
end

--- @function Driver:get_devices()
--- Get a list of all devices known to this driver.
---
--- @return List of Device objects
function Driver:get_devices()
  local devices = {}

  local device_uuid_list = self.device_api.get_device_list()
  for i, uuid in ipairs(device_uuid_list) do
    table.insert(devices, self:get_device_info(uuid))
  end

  return devices
end

function Driver:build_child_device(raw_device_table)
  return device_lib.Device(self, raw_device_table)
end

--------------------------------------------------------------------------------------------
-- Default get device info handling
--------------------------------------------------------------------------------------------

---  Default function for getting and caching device info on a driver
---
--- By default this will use the devices api to request information about the device id provided
--- it will then cache that information on the driver.  The information will be stored as a table
--- after being decoded from the JSON sent across.
---
--- @param self Driver the driver running
--- @param device_uuid string the uuid of the device to get info for
--- @param force_refresh boolean if true, re-request from the driver api instead of returning cached value
function Driver:get_device_info(device_uuid, force_refresh)

  -- check if device__uuid is a string
  if type(device_uuid) ~= "string" then
    return nil, "device_uuid is required to be a string"
  end

  if self.device_cache == nil then
    self.device_cache = {}
  end

  -- We don't have any information for this device
  if self.device_cache[device_uuid] == nil then
    local unknown_device_info = self.device_api.get_device_info(device_uuid)
    if unknown_device_info == nil then
      return nil, "device_uuid is invalid string or non-corresponding uuid"
    end

    local raw_device = json.decode(unknown_device_info)
    local new_device
    if raw_device.network_type == device_lib.NETWORK_TYPE_ZIGBEE then
      local zigbee_device = require "st.zigbee.device"
      new_device = zigbee_device.ZigbeeDevice(self, raw_device)
    elseif raw_device.network_type == device_lib.NETWORK_TYPE_ZWAVE then
      local zwave_device = require "st.zwave.device"
      new_device = zwave_device.ZwaveDevice(self, raw_device)
    elseif raw_device.network_type == device_lib.NETWORK_TYPE_MATTER then
      local matter_device = require "st.matter.device"
      new_device = matter_device.MatterDevice(self, raw_device)
    elseif raw_device.network_type == device_lib.NETWORK_TYPE_CHILD then
      new_device = self:build_child_device(raw_device)
    else
      new_device = device_lib.Device(self, raw_device)
    end

    self.device_cache[new_device.id] = new_device
  elseif force_refresh == true then
    -- We have a device record, but we want to force refresh the data
    local raw_device = json.decode(self.device_api.get_device_info(device_uuid))
    self.device_cache[device_uuid]:load_updated_data(raw_device)
  end
  return self.device_cache[device_uuid]
end

--- @function Driver:try_create_device
--- Send a request to create a new device.
---
--- .. note::
--- 	At this time, only LAN type devices can be created via this api.
---
--- Example usage::
---
--- 	local metadata = {
--- 	  type = "LAN",
--- 	  device_network_id = "24FD5B0001044502",
--- 	  label = "Kitchen Smart Bulb",
--- 	  profile = "bulb.rgb.v1",
--- 	  manufacturer = "WiFi Smart Bulb Co.",
--- 	  model = "WiFi Bulb 9000",
--- 	  vendor_provided_label = "Kitchen Smart Bulb"
--- 	})
---
--- 	driver:try_create_device(metadata))
---
--- All metadata fields are type string. Valid metadata fields are:
---
--- * **type** - network type of the device. Must be "LAN". (required)
--- * **device_network_id** - unique identifier specific for this device (required)
--- * **label** - label for the device (required)
--- * **profile** - profile name defined in the profile .yaml file (required)
--- * **parent_device_id** - device id of a parent device
--- * **manufacturer** - device manufacturer
--- * **model** - model name of the device
--- * **vendor_provided_label** - device label provided by the manufacturer/vendor (typically the same as label during device creation)
---
--- @param device_metadata table A table of device metadata
function Driver:try_create_device(device_metadata)
  assert(type(device_metadata) == "table")

  -- extract only keys we know are valid to prevent sending a bunch of garbage over the rpc
  local normalized_metadata = {
    deviceNetworkId = device_metadata.device_network_id,
    label = device_metadata.label,
    profileReference = device_metadata.profile,
    parentDeviceId = device_metadata.parent_device_id,
    manufacturer = device_metadata.manufacturer,
    model = device_metadata.model,
  }

  -- currently only LAN is allowed. ZIGBEE/ZWAVE disabled.
  local network_type = string.upper(device_metadata.type)
  if network_type == "LAN" then
    normalized_metadata["vendorProvidedLabel"] = device_metadata.vendor_provided_label
  elseif network_type == "EDGE_CHILD" then
    assert(normalized_metadata.parentDeviceId, "Parent Device ID must be set for EDGE_CHILD device")
    if type(device_metadata.parent_assigned_child_key) == "string" then
      normalized_metadata["parentAssignedChildKey"] = device_metadata.parent_assigned_child_key
    else
      error("EDGE_CHILD device must provide string type parent_assigned_child_key")
    end

    if normalized_metadata.deviceNetworkId ~= nil then
      normalized_metadata.deviceNetworkId = nil
      log.warn("EDGE_CHILD can not explicitly set the device_network_id, use \"parent_assigned_child_key\" for identification")
    end
  else
    error("unsupported network type: " .. network_type, 2)
  end
  normalized_metadata["type"] = network_type

  local metadata_json = json.encode(normalized_metadata)
  if metadata_json == nil then
    error("error parsing device info", 2)
  end

  return devices.create_device(metadata_json)
end

--------------------------------------------------------------------------------------------
-- Message stream handling registration
--------------------------------------------------------------------------------------------

--- Template function for a message handler
---
--- @param driver Driver the driver to handle the message channel
--- @param message_channel message_channel the channel that has the data to read.  A receive should be called on the channel to get the data
function driver_templates.message_handler_callback(driver, message_channel)
end

--- Function to register a message_channel handler
---
--- @param self Driver the driver to handle message events
--- @param message_channel message_channel the message channel to listen to input on
--- @param callback function the callback function to call when there is data on the message channel
--- @param name string Optional name for the channel handler, used for logging
function Driver:register_channel_handler(message_channel, callback, name)
  self._driver_thread:register_socket(message_channel, function()
      callback(self, message_channel)
    end, name)
end

--- Private method for registering work on the main thread
--- @param self Driver the driver to handle message events
--- @param message_channel message_channel the message channel to listen to input on
--- @param callback function the callback function to call when there is data on the message channel
--- @param name string Optional name for the channel handler, used for logging
function Driver:_register_channel_handler(message_channel, callback, name)
  self.message_handlers[message_channel] = {
    callback = callback,
    name = (name or "unnamed")
  }

  -- We have to wake the control thread as there is a new channel to select on
  if self._resync then
    self._resync:send()
  end
end

--- Function to unregister a message_channel handler
---
--- @param self Driver the driver to handle the message events
--- @param message_channel message_channel the message channel to stop listening for input on
function Driver:unregister_channel_handler(message_channel)
  self._driver_thread:unregister_socket(message_channel)
end

--------------------------------------------------------------------------------------------
-- Helper function for building drivers
--------------------------------------------------------------------------------------------

--- Standardize the structure of the sub driver structure of this driver
---
--- The handlers registered as a part of the base driver file (or capability defaults) are
--- assumed to be the default behavior of the driver.  However, if there is need for a subset
--- of devices to override the base behavior for one reason or another (e.g. manufacturer or
--- model specific behavior), a value can be added to the "sub_drivers".  Each sub_driver must
--- contain a `can_handle` function of the signature `can_handle(opts, driver, device, ...)`
--- where opts can be used to provide context specific information necessary to determine if
--- the sub_driver should be responsible for some type of work.  The most common use for the
--- sub drivers will be to provide capabiltiy/zigbee/zwave/matter handlers that need to override the
--- default for the driver.  It may optionally also contain its own `sub_drivers` containing
--- further subservient sets.
---
--- @param driver Driver the driver
function Driver.standardize_sub_drivers(driver)
  local handler_sets = {}
  for i, handler_set_list in pairs(driver.sub_drivers or {}) do
    local unwrapped_list = {table.unpack(handler_set_list)}
    if #unwrapped_list ~= 0 then
      for j, list in ipairs(unwrapped_list) do
        -- If there isn't a can_handle, it is a useless handler_set and should be ignored
        if list.can_handle ~= nil then
          table.insert(handler_sets, utils.deep_copy(list))
        end
      end
    else
      if handler_set_list.can_handle ~= nil then
        table.insert(handler_sets, utils.deep_copy(handler_set_list))
      end
    end
  end
  driver.sub_drivers = handler_sets
  for i, s_d in ipairs(driver.sub_drivers) do
    Driver.standardize_sub_drivers(s_d)
  end
end

--- Recursively build the capability dispatcher structure from sub_drivers
---
--- This will recursively follow the `sub_drivers` defined on the driver and build
--- a structure that will correctly find and execute a handler that matches.  It should be
--- noted that a child handler will always be preferred over a handler at the same level,
--- but that if multiple child handlers report that they can handle a message, it will be
--- sent to each handler that reports it can handle the message.
---
--- @param driver Driver the driver
function Driver.populate_capability_dispatcher_from_sub_drivers(driver)
  for _, sub_driver in ipairs(driver.sub_drivers) do
    sub_driver.capability_handlers = sub_driver.capability_handlers or {}
    sub_driver.capability_dispatcher =
      CapabilityCommandDispatcher(sub_driver.NAME, sub_driver.can_handle, sub_driver.capability_handlers)
    driver.capability_dispatcher:register_child_dispatcher(sub_driver.capability_dispatcher)
    Driver.populate_capability_dispatcher_from_sub_drivers(sub_driver)
  end
end

--- Recursively build the lifecycle dispatcher structure from sub_drivers

---
--- @param driver Driver the driver
function Driver.populate_lifecycle_dispatcher_from_sub_drivers(driver)
  for _, sub_driver in ipairs(driver.sub_drivers) do
    sub_driver.lifecycle_handlers = sub_driver.lifecycle_handlers or {}
    sub_driver.lifecycle_dispatcher = DeviceLifecycleDispatcher(
        sub_driver.NAME,
        sub_driver.can_handle,
        sub_driver.lifecycle_handlers
    )
    driver.lifecycle_dispatcher:register_child_dispatcher(sub_driver.lifecycle_dispatcher)
    Driver.populate_lifecycle_dispatcher_from_sub_drivers(sub_driver)
  end
end

local function default_lifecycle_event_handler(driver, device, event)
  device.log.trace_with({ hub_logs = true }, string.format("received unhandled lifecycle event: %s", event))
end

function Driver.default_nonfunctional_driverSwitched_hander(driver, device, event, args)
  -- If a device was switched to this driver and there was no overriding behavior mark it as non-functional
  device.thread:queue_event(device.try_update_metadata, device, { provisioning_state = "NONFUNCTIONAL" })
end

function Driver.default_capability_match_driverSwitched_handler(driver, device, event, args)
  -- This is just a best guess that will allow us to let a device run in this
  -- driver if we think it will function here.  However, it is still possible that we may think
  -- a device will function when it won't.  In these cases a driver should implement a custom
  -- handler for this event to properly handle the switched case
  for comp_id, comp in pairs(device.profile.components) do
    for _, component_cap in pairs(comp.capabilities) do
      local cap_matched = false
      for _, driver_cap in ipairs(driver.supported_capabilities) do
        if driver_cap.ID == component_cap.id or component_cap.id == "refresh" then
          cap_matched = true
          break
        end
      end
      if not cap_matched then
        -- This device profile includes a capability not supported by this driver
        device.thread:queue_event(device.try_update_metadata, device, { provisioning_state = "NONFUNCTIONAL" })
        return
      end
    end
  end
  -- Every capability in the device profile is supported by this driver
  device.thread:queue_event(device.try_update_metadata, device, { provisioning_state = "PROVISIONED" })
end


---Given a driver template and name initialize the context
---
--- This is used to build the driver context that will be passed around to provide access to various state necessary
--- for operation
---
--- @param cls Driver class to be instantiated
--- @param name string the name of the driver used for logging
--- @param template table a template with any override or necessary driver information
--- @return Driver the constructed driver context
function Driver.init(cls, name, template)
  local out_driver = template or {}
  out_driver.NAME = name
  out_driver.capability_handlers = out_driver.capability_handlers or {}
  out_driver.lifecycle_handlers = out_driver.lifecycle_handlers or {}
  out_driver.message_handlers = out_driver.message_handlers or {}

  out_driver.capability_channel = socket.capability()
  out_driver.discovery_channel = socket.discovery()
  out_driver.environment_channel = socket.environment_update()
  out_driver.lifecycle_channel = socket.device_lifecycle()
  out_driver.driver_lifecycle_channel = socket.driver_lifecycle()
  out_driver.timer_api = timer
  out_driver.device_api = devices
  out_driver.environment_info = {}
  out_driver.device_cache = {}
  out_driver.datastore = datastore.init()
  out_driver.discovery_state = {}
  setmetatable(out_driver, cls)
  out_driver._driver_thread = thread.Thread(out_driver, "driver")

  Driver.standardize_sub_drivers(out_driver)

  utils.merge(
      out_driver.lifecycle_handlers,
      {
        fallback = default_lifecycle_event_handler,
        driverSwitched = Driver.default_nonfunctional_driverSwitched_hander,
      }
  )
  out_driver.lifecycle_dispatcher =
  DeviceLifecycleDispatcher(
      name,
      function(...)
        return true
      end,
      out_driver.lifecycle_handlers
  )
  out_driver.populate_lifecycle_dispatcher_from_sub_drivers(out_driver)
  log.trace_with({ hub_logs = true }, string.format("Setup driver %s with lifecycle handlers:\n%s", out_driver.NAME, out_driver.lifecycle_dispatcher))

  out_driver.capability_dispatcher =
  CapabilityCommandDispatcher(
      name,
      function(...)
        return true
      end,
      out_driver.capability_handlers
  )
  out_driver.populate_capability_dispatcher_from_sub_drivers(out_driver)
  log.trace_with({ hub_logs = true }, string.format("Setup driver %s with Capability handlers:\n%s", out_driver.NAME, out_driver.capability_dispatcher))

  out_driver:_register_channel_handler(
    out_driver.capability_channel,
    template.capability_message_handler or Driver.capability_message_handler,
    "capability"
  )
  out_driver:_register_channel_handler(
    out_driver.lifecycle_channel,
    template.lifecycle_message_handler or Driver.lifecycle_message_handler,
    "device_lifecycle"
  )
  out_driver:_register_channel_handler(
    out_driver.driver_lifecycle_channel,
    template.driver_lifecycle_message_handler or Driver.driver_lifecycle_message_handler,
    "driver_lifecycle"
  )
  out_driver:_register_channel_handler(
    out_driver.discovery_channel,
    template.discovery_message_handler or Driver.discovery_message_handler,
    "discovery"
  )
  out_driver:_register_channel_handler(
    out_driver.environment_channel,
    template.environment_info_handler or Driver.environment_info_handler,
    "environment_info"
  )

  -- This handler allows us to force the control thread to turn. This is used to re-process the list of message handlers
  -- after one has been added or removed so that it can be added or removed from the list passed to select.
  local resyncsender, resyncreceiver = cosock.channel.new()
  resyncreceiver:settimeout(0)
  out_driver:_register_channel_handler(
    resyncreceiver,
    function(_, resync) resync:receive() end,
    "_resync"
  )
  out_driver._resync = resyncsender

  return out_driver
end

-- Allow for test mocking of the select call
function Driver:_internal_select(recv, sendt, timeout)
   return socket.select(recv, sendt, timeout)
end

--------------------------------------------------------------------------------------------
-- Default run loop for drivers
--------------------------------------------------------------------------------------------

--- Function to run a driver
---
--- This will run an "infinite" loop for this driver.  It will wait for input on any message channel that has a handler
--- registered for it through the register_channel_handler function.  In addition it will wait for any registered timers
--- to expire and trigger as well.  Whenever data becomes available on one of the message channels the callback will
--- be called and then it will go back to waiting for input.
---
--- @param self Driver the driver to run
function Driver:run(fail_on_error)
  -- Do a collectgarbage when a driver is first started as there is a lot of memory bloat as a part of startup
  collectgarbage()
  self._fail_on_error = fail_on_error ~= nil and fail_on_error or self._fail_on_error

  local function inner_run()
    local existing_devices = self.device_api.get_device_list()
    for _, deviceid in pairs(existing_devices) do
      local device = self:get_device_info(deviceid)
      device.thread:queue_event(self.lifecycle_dispatcher.dispatch, self.lifecycle_dispatcher, self, device, "init")
    end

    while true do
      local sock_list = {}
      for sock, cb in pairs(self.message_handlers) do
        sock_list[#sock_list + 1] = sock
      end
      local read_socks, _, err = self:_internal_select(sock_list, nil, 10)
      if err and err ~= "timeout" then
        log.warn("Error from message handlers:", err)
      end
      for i, sock in ipairs(read_socks or {}) do
        local handler = self.message_handlers[sock]
        if handler then
          log.trace_with({ hub_logs = true }, string.format("Received event with handler %s", handler.name))
          assert(type(handler.callback) == "function", "not a function")
          local status, err = pcall(handler.callback, self, sock)
          if not status then
            if self._fail_on_error == true then
              error(err, 2)
            else
              log.warn_with({ hub_logs = true }, string.format("%s encountered error: %s", self.NAME, tostring(err)))
            end
          end
        end
      end
      if self.datastore ~= nil then
        if self.datastore:is_dirty() then
          self.datastore:save()
        end
      end

      -- Process callbacks for sockets that need to be closed in this context
      while realsocket._socket_close_queue ~= nil and #realsocket._socket_close_queue > 0 do
        local cb = table.remove(realsocket._socket_close_queue)
        cb()
      end
    end
  end

  socket = cosock.socket
  cosock.spawn(inner_run, CONTROL_THREAD_NAME)

  cosock.run()
end

setmetatable(Driver, {
  __call = Driver.init
})

return Driver
