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
--- @class JsonModule
local JsonModule = {configured = false}

--- @class ModuleArgs
---
--- Args for the JsonLoader to initialize the JSON module
---
--- @field public use_native boolean whether or not to use the native code implementation when on a hub instead of dkjson
--- @field public with_memtracer boolean whether or not to instrument the encode/decode functions with memtracer.
--- @field public memtracer_namespace string if `with_memtracer` is true, this string will be used to namespace the metrics collection
local ModuleArgs = {}

ModuleArgs.default = {use_native = true, with_memtracer = false, memtracer_namespace = "json"}

ModuleArgs.mt = {}
ModuleArgs.mt.__index = ModuleArgs.default

--- Load the JSON Lua module based on the given loader args
---@param loader_args LoaderArgs configuration paramters for the Lua module
function JsonModule:configure(loader_args)
  loader_args = loader_args or {}
  setmetatable(loader_args, ModuleArgs.mt)

  if loader_args.use_native and (_envlibrequire ~= nil) then
    local native_json = _envlibrequire("json")
    setmetatable(self, native_json)
    native_json.__index = native_json
  else
    local dkjson = require "dkjson"
    setmetatable(self, dkjson)
    dkjson.__index = dkjson
  end

  if loader_args.with_memtracer then
    local memtracer = require "st.memtracer"
    local metrics = memtracer.get_metrics_holder_with_namespace(loader_args.memtracer_namespace)

    local encode_wrapped, encode_metrics = memtracer.instrument_function(
                                             self.encode, string.format(
                                               "%s.json.encode", loader_args.memtracer_namespace
                                             )
                                           )
    local decode_wrapped, decode_metrics = memtracer.instrument_function(
                                             self.decode, string.format(
                                               "%s.json.decode", loader_args.memtracer_namespace
                                             )
                                           )

    metrics.add_sampler(encode_metrics)
    metrics.add_sampler(decode_metrics)

    self.encode = encode_wrapped
    self.decode = decode_wrapped
  end

  self.configured = true
end

configure_and_load = function(self, args)
  local json = {configured = false}
  JsonModule.configure(json, args)
  return json
end

lazy_index = function(json, key)
  if not json.configured then JsonModule.configure(json, {}) end

  return json[key]
end

JsonModule.mt = {__call = configure_and_load, __index = lazy_index}

setmetatable(JsonModule, JsonModule.mt)

return JsonModule
