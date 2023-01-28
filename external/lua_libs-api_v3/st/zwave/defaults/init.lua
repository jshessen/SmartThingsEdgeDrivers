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
--- @class st.zwave.defaults
--- @alias default_handlers st.zwave.defaults
local default_handlers = {}
--- Register for default handlers based upon the passed capabilities.
---
--- @param driver st.zwave.Driver
--- @param capabilities table capabilities for which to register defaults
function default_handlers.register_for_default_handlers(driver, capabilities)
  driver.zwave_handlers = driver.zwave_handlers or {}
  driver.capability_handlers = driver.capability_handlers or {}
  local handlers_to_add = {}
  for _, cap in ipairs(capabilities) do
    pcall(function()
      local require_path = "st.zwave.defaults." .. cap.ID
      local entry = require(require_path)
      if entry ~= nil then
        -- collect Z-Wave handlers
        for cc, commands in pairs(entry.zwave_handlers or {}) do
          for command, handler in pairs(commands) do
            handlers_to_add[cc] = handlers_to_add[cc] or {}
            handlers_to_add[cc][command] = handlers_to_add[cc][command] or {}
            table.insert(handlers_to_add[cc][command], handler)
          end
        end

        -- collect capability handlers
        for command, handler in pairs(entry.capability_handlers or {}) do
          driver.capability_handlers[cap.ID] = driver.capability_handlers[cap.ID] or {}
          driver.capability_handlers[cap.ID][command.NAME] = driver.capability_handlers[cap.ID][command.NAME] or handler
        end

        -- collect default get_refresh_commands functions
        if type(entry.get_refresh_commands) == "function" then
          local multi_component_wrapper = function(inner_driver, device)
            local refresh_cmds = {}
            -- Collect refresh commands for the devices components
            for comp_id, component in pairs(device.profile.components) do
              local endpoints = device:component_to_endpoint(comp_id)
              if #endpoints > 0 then
                for _, ep in ipairs(endpoints) do
                  local cmds = entry.get_refresh_commands(inner_driver, device, comp_id, ep)
                  for _, cmd in ipairs(cmds or {}) do
                    table.insert(refresh_cmds, cmd)
                  end
                end
              else --collect for the default endpoint
                local cmds = entry.get_refresh_commands(inner_driver, device, comp_id, nil)
                for _, cmd in ipairs(cmds or {}) do
                  table.insert(refresh_cmds, cmd)
                end
              end
            end
            -- Collect refresh commands for the devices child devices if there are any.
            local child_list = device:get_child_list()
            for _, child in pairs(child_list) do
              local cmds = entry.get_refresh_commands(inner_driver, device, "main", child:get_dst_channel()[1])
              for _, cmd in ipairs(cmds or {}) do
                table.insert(refresh_cmds, cmd)
              end
            end
            return refresh_cmds
          end

          driver.get_default_refresh_commands = driver.get_default_refresh_commands or {}
          driver.get_default_refresh_commands[cap.ID] = multi_component_wrapper
        end
      end
    end)
  end

  -- we collect all the relevant default handlers above and add them here, because we only want
  -- to add them if they're not present in the driver's own definitions
  for cc, commands in pairs(handlers_to_add) do
    for command,_ in pairs(commands) do
      driver.zwave_handlers[cc] = driver.zwave_handlers[cc] or {}
      driver.zwave_handlers[cc][command] = driver.zwave_handlers[cc][command] or handlers_to_add[cc][command]
    end
  end

end

return default_handlers
