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
local path = require "path"
local yaml = require "yaml"
local json = require("dkjson")
local stutils = require "st.utils"

--- @module integration_test.utils
local utils = {}

-- TODO: is there a way to handle this that isn't hardcoded?
-- TODO: handle this at the same time we are handling capability defs after
--       inventory is added
local canonical_preference_definitions = {
  humidityOffset = {
    title = "Humidity Offset",
    description = "Enter a percentage to adjust the humidity.",
    preferenceType = "integer",
    definition = {
      minimum = -10,
      maximum = 10,
      default = 0
    }
  },
  motionSensitivity = {
    definition={
      default="2",
      options={
        [0] = "disabled",
        [1] = "low",
        [2] = "medium",
        [3] = "high",
      },
    },
    description="Motion Sensitivity",
    preferenceType="enumeration",
    title="Motion Sensitivity",
  },
  password = {
    definition={
      stringType="password",
    },
    description="Password",
    preferenceType="string",
    title="Password",
  },
  presetPosition={
    definition={
      default=50,
      maximum=100,
      minimum=0,
    },
    description="Preset Position",
    preferenceType="integer",
    title="Preset Position",
  },
  reportingInterval={
    definition={
      default=12,
      maximum=1440,
      minimum=5,
    },
    description="Reporting interval (in minutes)",
    preferenceType="integer",
    title="Reporting Interval",
  },
  tempOffset={
    definition={
      default=0.0,
      maximum=10.0,
      minimum=-10.0,
    },
    description="Temperature Offset",
    preferenceType="number",
    title="TempOffset",
  },
  username={
    definition={
      stringType="text",
    },
    description="Username",
    preferenceType="string",
    title="Username",
  }
}

utils.UNIT_TEST_FAILURE = function() end
utils.END_OF_TESTS = function() end

--- Load the definition of a profile from a <profile_name>.yaml file in the driver package
---
--- @param profile_file_name string the filename of the profile definition to load (expected in driver_package/profiles/<profile_file_name>)
--- @return table The table representation of the expected profile to be included in the creation of a MockDevice
function utils.get_profile_definition(profile_file_name)
  local caller_path = path.Path(debug.getinfo(2, "S").source:sub(2))
  local src_path = caller_path:get_dir_pos("src") and caller_path:to_dir("src") or path.Path("")
  local profile_path = src_path:parent():append("profiles"):append(profile_file_name):to_string()
  local profile_file, message = io.open(profile_path)
  assert(profile_file, message)
  local raw_profile_table = yaml.eval(profile_file:read("a"))
  io.close(profile_file)
  local output_profile = { components = {}, preferences = {} }
  for _, comp in ipairs(raw_profile_table.components) do
    output_profile.components[comp.id] = comp
  end
  if (raw_profile_table.preferences ~= nil) then
    for _, pref in ipairs(raw_profile_table.preferences) do
      -- Inline preference
      if pref.name ~= nil then
        output_profile.preferences[pref.name] = pref
      elseif pref.title ~= nil then
        output_profile.preferences[stutils.camel_case(pref.title)] = pref
      end
      -- Canonical preference
      if pref.id ~= nil then
        output_profile.preferences[pref.id] = canonical_preference_definitions[pref.id]
      end
    end
  end
  return output_profile
end

--- Load a capability definition using the SmartThings CLI
---
--- This will use the CLI to load this capability definition, and thus requires `smartthings` to
--- be an executable available on your path.  Further, because retrieving the capability can be a
--- bit slow, you can set an environment variable `ST_CAPABILITY_CACHE` with a path to a directory
--- where the retrieved capability definitions will be stored and will be referenced on future runs
--- to avoid requesting the definitions for every run.
---
--- @param capability_id string The capabiity ID to read
--- @param capability_version number The version of the capability to load the definition of
--- @return table,string The first value is the Lua table version of the capability definition, the second is the string JSON of the definition
function utils.load_capability_definition_from_cli(capability_id, capability_version)
  local cap_cache = os.getenv("ST_CAPABILITY_CACHE")
  local cap_filepath, succ, cap_table, cap_json

  if cap_cache ~= nil then
    local cap_cache_path = path.Path(cap_cache)
    local cap_cache_dir, message
    cap_cache_dir, message = io.open(cap_cache_path:to_string())
    assert(cap_cache_dir, message)
    local contents
    contents, message = cap_cache_dir:read()
    if contents ~= nil then
      cap_cache_dir:close()
    end
    if message ~= "Is a directory" then
      error("ST_CAPABILITY_CACHE should be a directory", 2)
    end
    local cap_filename = string.format("%s__%d.json", capability_id, capability_version)
    cap_filepath = cap_cache_path:append(cap_filename):to_string()
    local cap_def_file
    cap_def_file, message = io.open(cap_filepath)
    if cap_def_file == nil then
      local cmd = string.format("smartthings capabilities %s %d -j -o %s", capability_id, capability_version, cap_filepath)
      succ = os.execute(cmd)
      if not succ then
        error("Failed to use smartthings CLI to get capability definition, do you have everything setup?")
      end
    else
      io.close(cap_def_file)
    end
  else
    print("Consider setting the env variable ST_CAPABILITY_CACHE to speed up tests in the future")
    cap_filepath = os.tmpname() .. ".json"
    local cmd = string.format("smartthings capabilities %s %d -j -o %s", capability_id, capability_version, cap_filepath)
    succ = os.execute(cmd)
    if not succ then
      error("Failed to use smartthings CLI to get capability definition, do you have everything setup?")
    end
  end
  succ, cap_table, cap_json = pcall(utils.load_capability_definition_from_file, cap_filepath)
  if not succ then
    local err_msg = cap_table
    error(err_msg, 2)
  end
  if cap_cache == nil then
    os.remove(cap_filepath)
  end
  return cap_table, cap_json
end

--- Load a capability definition from a JSON or yaml file
---
--- @param path_to_cap string A path to the capability definition file
--- @return table,string The first value is the Lua table version of the capability definition, the second is the string JSON of the definition
function utils.load_capability_definition_from_file(path_to_cap)
  local cap_path = path.Path(path_to_cap)
  local cap_file, message = io.open(cap_path:to_string())
  assert(cap_file, message)
  local cap_json = cap_file:read("a")
  local cap_table
  if cap_path:has_extension("yml") or cap_path:has_extension("yaml") then
    cap_table = yaml.eval(cap_json)
    cap_json = json.encode(cap_table)
  elseif cap_path:has_extension("json") then
    cap_table = json.decode(cap_json)
  else
    error("Unexpected file type for capability file", 2)
  end
  io.close(cap_file)
  if cap_table.id == nil then
    error("Capability definition must include ID", 2)
  end
  if cap_table.version == nil then
    error("Capability definition must include version", 2)
  end
  return cap_table, cap_json
end


--- Load a capability definition from a JSON or yaml definition file within the driver package
---
--- This expects to find a driver_package/capabilities directory with the given filename inside
---
--- @param capability_filename string the filename containing the capability definition
--- @return table,string The first value is the Lua table version of the capability definition, the second is the string JSON of the definition
function utils.load_capability_definition_from_package(capability_filename)
  local caller_path = path.Path(debug.getinfo(2, "S").source:sub(2))
  local src_path = caller_path:get_dir_pos("src") and caller_path:to_dir("src") or path.Path("")
  local cap_path = src_path:parent():append("capabilities"):append(capability_filename)
  return utils.load_capability_definition_from_file(cap_path:to_string())
end

return utils