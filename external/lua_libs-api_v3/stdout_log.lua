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

local log_mod = {}

log_mod.LOG_LEVEL_PRINT = "print"
log_mod.LOG_LEVEL_FATAL = "fatal"
log_mod.LOG_LEVEL_ERROR = "error"
log_mod.LOG_LEVEL_WARN = "warn"
log_mod.LOG_LEVEL_INFO = "info"
log_mod.LOG_LEVEL_DEBUG = "debug"
log_mod.LOG_LEVEL_TRACE = "trace"

log_mod._level = log_mod.LOG_LEVEL_TRACE

log_mod.levels = {
  [log_mod.LOG_LEVEL_PRINT] = 700,
  [log_mod.LOG_LEVEL_FATAL] = 600,
  [log_mod.LOG_LEVEL_ERROR] = 500,
  [log_mod.LOG_LEVEL_WARN] = 400,
  [log_mod.LOG_LEVEL_INFO] = 300,
  [log_mod.LOG_LEVEL_DEBUG] = 200,
  [log_mod.LOG_LEVEL_TRACE] = 100,
}


local function get_log_wrapper(level_str)
  return function(...)
    local t = {...}
    local n = #t
    for i=1,n do t[i] = tostring(t[i]) end
    local str = table.concat(t, "\t")
    if log_mod.levels[level_str] >= log_mod.levels[log_mod._level] then
      print(string.format("%-5s || %s", string.upper(level_str), str))
    end
  end
end

log_mod.trace = get_log_wrapper(log_mod.LOG_LEVEL_TRACE)
log_mod.debug = get_log_wrapper(log_mod.LOG_LEVEL_DEBUG)
log_mod.info = get_log_wrapper(log_mod.LOG_LEVEL_INFO)
log_mod.warn = get_log_wrapper(log_mod.LOG_LEVEL_WARN)
log_mod.error = get_log_wrapper(log_mod.LOG_LEVEL_ERROR)
log_mod.fatal = get_log_wrapper(log_mod.LOG_LEVEL_FATAL)
log_mod.print = get_log_wrapper(log_mod.LOG_LEVEL_PRINT)

local function get_log_wrapper_with(level_str)
  return function(opts, ...)
    log_mod[level_str](...)
  end
end

log_mod.trace_with = get_log_wrapper_with(log_mod.LOG_LEVEL_TRACE)
log_mod.debug_with = get_log_wrapper_with(log_mod.LOG_LEVEL_DEBUG)
log_mod.info_with = get_log_wrapper_with(log_mod.LOG_LEVEL_INFO)
log_mod.warn_with = get_log_wrapper_with(log_mod.LOG_LEVEL_WARN)
log_mod.error_with = get_log_wrapper_with(log_mod.LOG_LEVEL_ERROR)
log_mod.fatal_with = get_log_wrapper_with(log_mod.LOG_LEVEL_FATAL)
log_mod.print_with = get_log_wrapper_with(log_mod.LOG_LEVEL_PRINT)

log_mod.log = function(opts, level, ...)
  log_mod[level](...)
end

log_mod.set_log_level = function(level)
  if log_mod.levels[level] ~= nil then
    log_mod._level = level
  else
    print(string.format("Unknown log level %s.  Not setting log level", level))
  end
end

return log_mod
