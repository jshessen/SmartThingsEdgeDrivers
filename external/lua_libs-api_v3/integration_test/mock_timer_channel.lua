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
local st_utils = require "st.utils"
local it_utils = require "integration_test.utils"

local timer_api = {
  __oneshot_timers = {},
  __interval_timers = {},
  __returned_oneshot_timers = {},
  __returned_interval_timers = {},
}

local base_timer_index_funcs = {
  cancel = function(self)
    -- TODO: what to do
  end,
  wait = function(self)
    -- TODO: what to do
  end,
  handled = function(self)
    self.__handled = true
  end,
  settimeout = function(self)
    -- TODO: what to do
  end,
  __set_channel_ordering = function(self, req)
    --noop for timers
  end,
  __receive_ready = function(self)
    -- default timer return will never fire
    return false
  end,
  __expecting_additional_send = function(self)
    -- default timer
    return false
  end,
  __is_mock_timer = function()
    return true
  end
}

local function add_timer_index_defaults(index)
  for k, v in pairs(base_timer_index_funcs) do
    index[k] = index[k] or v
  end
  return index
end

timer_api.__never_fire_timer_mt = function()
  local timer_mt = {
    __index = add_timer_index_defaults({})
  }
  return timer_mt
end

local function time_advance_timer_mt(seconds, timer_class, max_fires)
  local timer_mt = {
    __index = {},
    __start_time = os.time(),
    __timeout = seconds,
    __timer_class = timer_class,
    __complete = false,
    __max_fires = max_fires,
    __fire_count = 0
  }

  function timer_mt.__index.__receive_ready(self)
    if not timer_mt.__complete and (os.time() - timer_mt.__start_time) >= timer_mt.__timeout then
      if timer_mt.__timer_class == "oneshot" then
        self.handled = function(s)
          timer_mt.__complete = true
        end
      else
        self.handled = function(s)
          timer_mt.__start_time = os.time()
          timer_mt.__fire_count = timer_mt.__fire_count + 1
          if timer_mt.__fire_count == timer_mt.__max_fires then
            timer_mt.__complete = true
          end
        end
      end
      return true
    end
    return false
  end

  function timer_mt.__index.cancel(timer)
    -- mark timer as complete so it won't fire
    timer_mt.__complete = true
    if timer_class == "oneshot" then
      for pos, t in ipairs(timer_api.__returned_oneshot_timers) do
        if t == timer then
          table.remove(timer_api.__returned_oneshot_timers, pos)
          break
        end
      end
    else
      for pos, t in ipairs(timer_api.__returned_interval_timers) do
        if t == timer then
          table.remove(timer_api.__returned_interval_timers, pos)
          break
        end
      end
    end
  end

  add_timer_index_defaults(timer_mt.__index)

  return timer_mt
end

timer_api.__create_test_time_advance_timer = function(seconds, timer_class, max_fires)
  local new_timer = {}
  setmetatable(new_timer, time_advance_timer_mt(seconds, timer_class, max_fires))
  return new_timer
end


timer_api.__replace_queued_timer_by_name = function(timer_class, timer_name, new_timer)
  local timer_list
  if timer_class == "oneshot" then
    timer_list = timer_api.__oneshot_timers
  else
    timer_list = timer_api.__interval_timers
  end

  for i, t in ipairs(timer_list) do
    if t.name == timer_name then
      timer_list[i] = new_timer
      break
    end
  end
end

timer_api.__create_and_queue_test_time_advance_timer = function(seconds, timer_class, max_fires)
  local new_timer = timer_api.__create_test_time_advance_timer(seconds, timer_class, max_fires)
  if timer_class == "oneshot" then
    table.insert(timer_api.__oneshot_timers, new_timer)
  else
    table.insert(timer_api.__interval_timers, new_timer)
  end
  return new_timer
end

timer_api.__create_and_queue_generic_timer = function(ready_check_func, timer_class, cancel_func)
  local new_timer = {}
  setmetatable(new_timer, {
    __index = add_timer_index_defaults(
        {
          __receive_ready = ready_check_func,
          cancel = cancel_func
        }
    )
  })

  if timer_class == "oneshot" then
    table.insert(timer_api.__oneshot_timers, new_timer)
  else
    table.insert(timer_api.__interval_timers, new_timer)
  end

  return new_timer
end

timer_api.__create_and_queue_never_fire_timer = function(timer_class, name)
  local new_timer = {name = name}
  setmetatable(new_timer, timer_api.__never_fire_timer_mt())

  if timer_class == "oneshot" then
    table.insert(timer_api.__oneshot_timers, new_timer)
  else
    table.insert(timer_api.__interval_timers, new_timer)
  end

  return new_timer
end

local set_timers_to_fire = function(timer_list)
  for _, timer in ipairs(timer_list) do
    timer.__receive_ready = timer_api.__get_single_fire_function()
  end
end

function timer_api:__set_all_oneshots_to_fire()
  set_timers_to_fire(self.__returned_oneshot_timers)
end

function timer_api:__set_all_intervals_to_fire()
  set_timers_to_fire(self.__returned_interval_timers)
end

function timer_api:reset()
  self.__oneshot_timers = {}
  self.__interval_timers = {}
  self.__returned_oneshot_timers = {}
  self.__returned_interval_timers = {}
end

timer_api.create_oneshot = function(seconds)
  local next_timer
  if timer_api.__oneshot_timers[1] ~= nil then
    next_timer = timer_api.__oneshot_timers[1]
    table.remove(timer_api.__oneshot_timers, 1)
  else
    next_timer = {}
    setmetatable(next_timer, timer_api.__never_fire_timer_mt())
  end
  table.insert(timer_api.__returned_oneshot_timers, next_timer)
  return next_timer
end

timer_api.create_interval = function(seconds)
  local next_timer
  if timer_api.__interval_timers[1] ~= nil then
    next_timer = timer_api.__interval_timers[1]
    table.remove(timer_api.__interval_timers, 1)
  else
    next_timer = {}
    setmetatable(next_timer, timer_api.__never_fire_timer_mt())
  end
  table.insert(timer_api.__returned_interval_timers, next_timer)
  return next_timer
end

setmetatable(timer_api, {
  __call = function(...) return timer_api end
})

function timer_api.__get_single_fire_function()
  local should_fire = true
  local fire_func = function()
    if should_fire then
      should_fire = false
      return true
    end
    return false
  end
  return fire_func
end

return timer_api
