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
local capabilities = require "st.capabilities"
--- @type Device
local base_device = require "st.device"
local zw = require "st.zwave"
local utils = require "st.utils"
local constants = require "st.zwave.constants"

local CURRENT_PREFERENCES_KEY = "__curr_pref_key"
local MAIN_COMPONENT_KEY = "main"

--- @module zwave_device
local zwave_device = {}

--- @class st.zwave.Device : st.Device
--- @alias ZwaveDevice st.zwave.Device
--- @field public zwave_endpoints table store Z-Wave endpoints
local ZwaveDevice = {}
ZwaveDevice.COMPONENT_TO_ENDPOINT_FUNC = "__comp_to_ep_fn"
ZwaveDevice.ENDPOINT_TO_COMPONENT_FUNC = "__ep_to_comp_fn"

--- Add a refresh command to passed refresh_commands list.
---
--- The list is indexed on [cmd_class][cmd_id].  If an identical command is
--- already present, this is a no-op.
---
--- @param self st.zwave.Device
--- @param command st.Zwave.Command refresh command to add
local function _add_refresh_command(refresh_commands, command)
  refresh_commands[command.cmd_class] = refresh_commands[command.cmd_class] or {}
  refresh_commands[command.cmd_class][command.cmd_id] = refresh_commands[command.cmd_class][command.cmd_id] or {}
  for _, cmd in ipairs(refresh_commands[command.cmd_class][command.cmd_id]) do
    if cmd == command then
      return --identical command already present
    end
  end
  table.insert(refresh_commands[command.cmd_class][command.cmd_id], command)
end

--- Collect and return the list of refresh commands for self device as provided
--- by registered default modules, removing duplicates.
---
--- @param self st.zwave.Device
function ZwaveDevice:collect_default_refresh_commands()
  local refresh_commands = {}
  for _, refresh_cmd_getter in pairs(self.driver.get_default_refresh_commands or {}) do
    assert(type(refresh_cmd_getter) == "function")
    local commands = refresh_cmd_getter(self.driver, self)
    for _, command in ipairs(commands or {}) do
      _add_refresh_command(refresh_commands, command)
    end
  end
  return refresh_commands
end

---@alias CompToEp fun(type: ZwaveDevice, type: string):number
--- Set a function to map this devices SmartThings components to Zwave endpoints
---
--- @param comp_ep_fn CompToEp Component to Endpoint function to do the mapping for this device
function ZwaveDevice:set_component_to_endpoint_fn(comp_ep_fn)
  if self:get_field(ZwaveDevice.COMPONENT_TO_ENDPOINT_FUNC) == nil then
    self:set_field(ZwaveDevice.COMPONENT_TO_ENDPOINT_FUNC, comp_ep_fn)
  else
    log.error_with({ hub_logs = true }, "Attempt to re-set valid component-to-endpoint function.")
  end
end

---@alias EpToComp fun(type: ZwaveDevice, type: number):string

--- Set a function to map this devices Zwave endpoints to SmartThings components
---
--- @param ep_comp_fn EpToComp function to do the mapping for this device
function ZwaveDevice:set_endpoint_to_component_fn(ep_comp_fn)
  if self:get_field(ZwaveDevice.ENDPOINT_TO_COMPONENT_FUNC) == nil then
    self:set_field(ZwaveDevice.ENDPOINT_TO_COMPONENT_FUNC, ep_comp_fn)
  else
    log.error_with({ hub_logs = true }, "Attempt to re-set valid endpoint-to-component function.")
  end
end

---@alias UpdatePreference fun(type: ZwaveDevice, type: table)
--- Set a function to be called with with previous preferences when this device wakes up. Should be used to update preferences on sleepy devices.
---
--- @param update_pref_fn UpdatePreference function to update preferences when a device wakes up.
function ZwaveDevice:set_update_preferences_fn(update_pref_fn)
  self:set_field(CURRENT_PREFERENCES_KEY, utils.deep_copy(self.st_store.preferences), { persist = true })
  if self:get_field(constants.UPDATE_PREFERENCES_FUNC) == nil then
    local wrapped_fn = function(driver, device)
      local args = {
        old_st_store = {
          preferences = device:get_field(CURRENT_PREFERENCES_KEY)
        }
      }
      update_pref_fn(driver, device, args)
      device:set_field(CURRENT_PREFERENCES_KEY, utils.deep_copy(device.st_store.preferences), { persist = true })
    end
    self:set_field(constants.UPDATE_PREFERENCES_FUNC, wrapped_fn)
  else
    log.error_with({ hub_logs = true }, "Attempt to re-set valid update-preferences function.")
  end
end

--- Collect device-specific refresh commands from registered default modules
--- and send these to the associated Z-Wave device.
---
--- @param self st.zwave.Device
function ZwaveDevice:default_refresh()
  local refresh_commands = self:collect_default_refresh_commands(self.driver)
  for _, command_class in pairs(refresh_commands) do
    for _, commands in pairs(command_class) do
      for _, command in ipairs(commands) do
        self:send(command)
      end
    end
  end
end

--- Use the capability dispatcher to execute refresh as appropriate for
--- the particular device instance.
---
--- @param self st.zwave.Device
function ZwaveDevice:refresh()
  self.driver:inject_capability_command(self,
    {
      capability = capabilities.refresh.ID,
      command = capabilities.refresh.commands.refresh.NAME,
      args = {}
    }
  )
end

--- Default device configure function.  Execute refresh to bootstrap state
--- for all capability event listeners.
---
--- @param self st.zwave.Device
function ZwaveDevice:default_configure()
  self:refresh()
end

--- Emit event for Z-Wave endpoint(channel), mapped to component.
---
--- @param endpoint number the endpoint(Z-Wave channel) ID to find the component for
--- @param event table the endpoint(Z-Wave channel) ID to find the component for
function ZwaveDevice:emit_event_for_endpoint(endpoint, event)
  local find_child_fn = self:get_field(base_device.FIND_CHILD_KEY)
  if find_child_fn ~= nil then
    local child = find_child_fn(self, endpoint)
    if child ~= nil then
      child:emit_event(event)
      return
    end
  end
  -- If no child was found, emit the event for this device
  local component_id = self:endpoint_to_component(endpoint)
  self:emit_component_event(self.profile.components[component_id], event)
end


--- Send a Z-Wave command to the associated Z-Wave device.
--- The command will be logged in the live logs when it is sent from the driver.
--- There will also be logs to trace when the command is queued in the hub,
--- and when the transmission has completed on the radio.
---
--- @param cmd st.zwave.Command
function ZwaveDevice:send(cmd)
  self.log.info_with({ hub_logs = true }, string.format("sending Z-Wave command: %s", cmd))
  self.zwave_channel:send(self.id, cmd.encap, cmd.cmd_class, cmd.cmd_id, cmd.payload, cmd.src_channel, cmd.dst_channels)
end

--- Send a Z-Wave command to the specific component of associated Z-Wave device.
--- The command will be logged in the live logs when it is sent from the driver.
--- There will also be logs to trace when the command is queued in the hub,
--- and when the transmission has completed on the radio.
---
--- @param cmd st.zwave.Command
--- @param component_id string
function ZwaveDevice:send_to_component(cmd, component_id)
  cmd.encap = cmd.encap or zw.ENCAP.AUTO
  cmd.src_channel = cmd.src_channel or 0
  cmd.dst_channels = self:component_to_endpoint(component_id)
  self:send(cmd)
end

--- Map component to end_points(channels)
--- e.g.
--- {} - map component to un-encapsulated
--- {2} - map to specific Z-Wave endpoint(channel)
--- {1,2,3} - map to more then one Z-Wave endpoint (channels)
---
--- @param component_id string ID
--- @return table dst_channels destination channels
--- e.g. {2} for Z-Wave channel 2 or {} for unencapsulated
function ZwaveDevice:component_to_endpoint(component_id)
  local comp_to_ep = self:get_field(ZwaveDevice.COMPONENT_TO_ENDPOINT_FUNC)
  if comp_to_ep ~= nil and component_id ~= nil then
    return comp_to_ep(self, component_id) or {}
  end
  return {} -- unencapsulated
end

--- Map end_point(channel) to Z-Wave endpoint(channel)
---
--- @param endpoint number the endpoint(Z-Wave channel) ID to find the component for
--- @return string the component ID the endpoint matches to
function ZwaveDevice:endpoint_to_component(endpoint)
  local component_id
  local ep_to_comp = self:get_field(ZwaveDevice.ENDPOINT_TO_COMPONENT_FUNC)
  if ep_to_comp ~= nil and endpoint ~= nil then
    component_id = ep_to_comp(self, endpoint)
  end
  if self:component_exists(component_id) then
    return component_id
  end
  if self:component_count() == 1 then
    next(self.st_store.profile.components, nil)
  end
  if self:component_exists(MAIN_COMPONENT_KEY) then
    return MAIN_COMPONENT_KEY
  end
  error("Error mapping entpoint to component for" .. self:pretty_print())
end

--- Interrogate the device's profile to determine whether a particular command class is supported.
---
--- @param cc_value number the command class id as defined in cc.lua, e.g cc.SWITCH_BINARY = 0x25
--- @param endpoint number of the endpoint to check, if nil we check the first endpoint
--- @return boolean true if the command class is supported, false if not
function ZwaveDevice:is_cc_supported(cc_value, endpoint)
  if self.zwave_endpoints == nil then
    log.error_with({ hub_logs = true }, "ZwaveDevice.zwave_endpoints is nil.")
    return false
  end

  -- the basic command class does not appear in the NIF (and consequently in the device object),
  -- but it is always supported
  local BASIC = (require "st.zwave.CommandClass.Basic")({version=1,strict=true})
  if cc_value == BASIC.ID then
    return true
  end

  local endpoint_idx = 1
  --[[
  --  Currently there is only ever one zwave_endpoint that exists on zwave devices even though at join
  --  time we discover all endpoints and include the endpoint count in the join message to the cloud.
  --  Ideally we want to be able to check what command classes an individual endpoint supports.
  --  For now we will only check the root endpoint. See HCS-1996 for more details on how we will move
  --  toward the ideal solution of having endpoint command class information accurate for all zwave endpoints
  --  on a device.
  --
  --  Without this logic activated, we are making the assumption that all zwave endpoints support the same
  --  command classes as the main endpoint. The completion of HCS-1996 will allow us to reactivate this logic.
  if not endpoint then
    endpoint_idx = 1
  else
    endpoint_idx = 1 + endpoint
  end
  ]]--
  if self.zwave_endpoints[endpoint_idx] == nil then
    log.error_with({ hub_logs = true }, "ZwaveDevice.zwave_endpoints[", endpoint_idx, "] is nil.")
    return false
  end

  if self.zwave_endpoints[endpoint_idx].command_classes == nil then
    log.error_with({ hub_logs = true }, "ZwaveDevice.zwave_endpoints[", endpoint_idx, "].command_classes is nil")
    return false
  end

  for _, cc in ipairs(self.zwave_endpoints[endpoint_idx].command_classes) do
    if cc.value == cc_value then
      return true
    end
  end
  return false
end

--- Determine whether device self is a match to the passed manufacturer ID(s),
--- product ID(s) and product type(s).  Filter arguments can be numerical
--- literals or arrays of numerical literals.
---
--- In the case that a filter argument is an array, matching uses OR logic.
--- Match against any single array item is considered a device match.
---
--- @param mfr_id number|table numerical manufacturer ID or array of IDs
--- @param product_type number|table numerical product type ( aka product in DTH namespace) or array of types.
--- @param product_id number|table numerical product ID ( aka model in DTH namespace) or array of IDs
--- @return boolean true if device self matches the passed all filter arguments
function ZwaveDevice:id_match(mfr_id, product_type, product_id)
  local match
  local matrix = {
    {
      filter = mfr_id,
      devattr = self.zwave_manufacturer_id
    },
    {
      filter = product_id,
      devattr = self.zwave_product_id
    },
    {
      filter = product_type,
      devattr = self.zwave_product_type
    },
  }
  for _,m in pairs(matrix) do
    match = false
    if type(m.filter) == "number" then
      if m.devattr == m.filter then
        match = true
      end
    elseif type(m.filter) == "table" then
      for _,filter in pairs(m.filter) do
        if m.devattr == filter then
          match = true
          break
        end
      end
    elseif type(m.filter) == "nil" then
      match = true
    else
      error("unsupported filter type " .. type(m.filter))
    end
    if match == false then
      return match
    end
  end
  return match
end

--- Initialize an st.zwave.Device instance
---
--- @param cls st.zwave.Device st.zwave.Device class definition table
--- @param driver st.zwave.Driver
--- @param raw_device table cloud-published device instance data
function ZwaveDevice.init(cls, driver, raw_device)
  local out_device = base_device.Device.init(cls, driver, raw_device)
  out_device.zwave_channel = driver.zwave_channel
  base_device.Device._protect(cls, out_device)
  out_device:load_updated_data(raw_device)
  log.trace_with({ hub_logs = true }, out_device:debug_pretty_print())
  return out_device
end

--- Return a string representation of device model and supported command class information
---
--- @return A string containing the device model and supported command class information
function ZwaveDevice:debug_pretty_print()
  outputString = "Z-Wave Device: " .. self.id .. "\n"
  if (self.zwave_manufacturer_id ~= nil and self.zwave_product_type ~= nil and self.zwave_product_id ~= nil) then
    outputString = outputString .. string.format("Manufacturer: 0x%04X Product Type: 0x%04X Product ID: 0x%04X",
      self.zwave_manufacturer_id, self.zwave_product_type, self.zwave_product_id) .. "\n"
    if(self.zwave_endpoints ~= nil) then
      for index, endpoint in pairs(self.zwave_endpoints) do
        command_classes = ""
        for _, cc in ipairs(endpoint.command_classes) do
          command_classes = command_classes .. string.format("%s, ", zw.cc_to_string(cc.value))
        end
        outputString = outputString .. string.format("\t[%d]: %s",index-1, command_classes:sub(1, -3))
      end
    end
  end
  return outputString
end

ZwaveDevice.CLASS_NAME = "ZwaveDevice"

--- Get a string with the ID, DNI and label of the device.
---
--- @return string a short string representation of the device
function ZwaveDevice:pretty_print()
  local label_str = ""
  if self.label ~= nil then
    label_str = string.format(" (%s)", self.label)
  end
  return string.format("<%s: %s [%s]%s>", self.CLASS_NAME, self.id, self.device_network_id, label_str)
end

ZwaveDevice.__tostring = ZwaveDevice.pretty_print

zwave_device.ZwaveDevice = ZwaveDevice

setmetatable(ZwaveDevice, {
  __index = base_device.Device,
  __call = ZwaveDevice.init
})

return zwave_device
