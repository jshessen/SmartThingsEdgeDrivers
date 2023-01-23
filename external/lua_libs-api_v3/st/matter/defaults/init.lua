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
local default_handlers = {}

function default_handlers.register_for_default_handlers(driver, capabilities)
  driver.matter_handlers = driver.matter_handlers or {}
  driver.matter_handlers.attr = driver.matter_handlers.attr or {}
  driver.matter_handlers.global = driver.matter_handlers.global or {}
  driver.matter_handlers.cluster = driver.matter_handlers.cluster or {}
  driver.subscribed_attributes = driver.subscribed_attributes or {}
  driver.subscribed_events = driver.subscribed_events or {}
  driver.capability_handlers = driver.capability_handlers or {}

  -- populate lookup table for pre-existing driver subscribed_attributes
  local existing_subscribed_attrs = {}
  for _cap_id, attrs in pairs(driver.subscribed_attributes) do
    for _, attr in ipairs(attrs) do
      existing_subscribed_attrs[attr.cluster or attr._cluster.ID] =
        existing_subscribed_attrs[attr.cluster or attr._cluster.ID] or {}
      existing_subscribed_attrs[attr.cluster or attr._cluster.ID][attr.attribute or attr.ID] = true
    end
  end
  --populate lookup table for pre-existing driver subscribed_events
  local existing_subscribed_events = {}
  for _cap_id, events in pairs(driver.subscribed_events) do
    for _, evnt in ipairs(events) do
      existing_subscribed_events[evnt.cluster or evnt._cluster.ID] = existing_subscribed_attrs[evnt.cluster or evnt._cluster.ID] or {}
      existing_subscribed_events[evnt.cluster or evnt._cluster.ID][evnt.event or evnt.ID] = true
    end
  end

  for _, cap in ipairs(capabilities) do
    pcall(
      function()
        local require_path = "st.matter.defaults." .. cap.ID
        local entry = require(require_path)
        if entry ~= nil then
          -- merge attr handlers
          for cluster, attrs in pairs(((entry.matter_handlers or {})["attr"] or {})) do
            for attr, handler in pairs(attrs) do
              local cid = (type(cluster) == "table") and cluster.ID or cluster
              local aid = (type(attr) == "table") and attr.ID or attr
              driver.matter_handlers.attr[cid] = driver.matter_handlers.attr[cid] or {}
              driver.matter_handlers.attr[cid][aid] = driver.matter_handlers.attr[cid][aid]
                                                        or handler
            end
          end

          -- merge command response handlers
          for cluster, commands in pairs(((entry.matter_handlers or {})["cmd_response"] or {})) do
            for cmd, handler in pairs(commands) do
              local cid = (type(cluster) == "table") and cluster.ID or cluster
              local cmdid = (type(cmd) == "table") and cmd.ID or cmd
              driver.matter_handlers.cluster[cid] = driver.matter_handlers.cluster[cid] or {}
              driver.matter_handlers.cluster[cid][cmdid] = driver.matter_handlers.cluster[cid][cmdid]
                                                             or handler
            end
          end

          -- merge cap command handlers
          for cap_command, handler in pairs(entry.capability_handlers or {}) do
            driver.capability_handlers[cap.ID] = driver.capability_handlers[cap.ID] or {}
            driver.capability_handlers[cap.ID][cap_command.NAME] = driver.capability_handlers[cap.ID][cap_command.NAME]
                                                                     or handler
          end

          -- merge subscribed attributes
          for _, attr in ipairs(entry.subscribed_attributes or {}) do
            -- Only add a subscribed attribute if that attribute isnt already included
            -- Note it is expected that all cap default files will be using cluster library objects
            existing_subscribed_attrs[attr._cluster.ID] = existing_subscribed_attrs[attr._cluster.ID]
                                                            or {}
            if not existing_subscribed_attrs[attr._cluster.ID][attr.ID] then
              driver.subscribed_attributes[cap.ID] = driver.subscribed_attributes[cap.ID] or {}
              table.insert(driver.subscribed_attributes[cap.ID], attr)
              existing_subscribed_attrs[attr._cluster.ID][attr.ID] = true
            end
          end
        end

        -- merge subscribed events
        for _, evnt in ipairs(entry.subscribed_events or {}) do
          -- Only add a subscribed attribute if that attribute isnt already included
          -- Note it is expected that all cap default files will be using cluster library objects
          existing_subscribed_events[evnt._cluster.ID] = existing_subscribed_events[evnt._cluster.ID] or {}
          if not existing_subscribed_events[evnt._cluster.ID][evnt.ID] then
            driver.subscribed_events[cap.ID] = driver.subscribed_events[cap.ID] or {}
            table.insert(driver.subscribed_events[cap.ID], evnt)
            existing_subscribed_events[evnt._cluster.ID][evnt.ID] = true
          end
        end
      end
    )
  end
end

return default_handlers
