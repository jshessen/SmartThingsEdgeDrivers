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
local utils = require "st.utils"
local cc = require "st.zwave.generated.cc"

--- @class st.zwave
--- @alias zw st.zwave
--- @field public ENCAP st.zwave.ENCAP
local zw = {}

-- For convenience, also make our command class codes accessible from st.zwave.
setmetatable(zw, {
  __index = require "st.zwave.generated.cc"
})

--- Build a reflection of a table of defined constants, where in the simple case
--- with no nesting, input table is of form:
---
--- constants = {
---   A = 1,
---   B = 2
--- }
---
--- The reflected table will then be:
---
--- reflected_constants = {
---   [1] = "A",
---   [2] = "B"
--- }
---
--- We may also have nested constants tables of form:
---
--- top_level_constants = {
---   A = 1,
---   B = 2
--- }
---
--- nested_constants = {
---   a = {
---     C = 3,
---     D = 4
---   },
---   b = {
---     E = 3,
---     F = 5
---   }
--- }
---
--- If we wish to reflect nested_constants, we must pass nested constants and
--- top_level_constants as the precursor.  This will produce an output
--- reflection table of form:
---
--- reflected_nested_constants = {
---   [1] = {
---     [3] = "C",
---     [4] = "D"
---   },
---   [2] = {
---     [3] = "E",
---     [5] = "F"
---   }
--- }
---
--- To then transform nested_constants into a string, we index into
--- nested_constants as follows:
---
--- stringified_nested_constant = reflected_nested_constants[TOP_LEVEL_VALUE][NESTED_VALUE]
---
--- @param tbl table constants table to reflect
--- @param precursor table top-level precursor table for nested constants
--- @vararg table 0 or more intermediate precursor tables for nested constants
--- @return table reflected constants tables indexed numerically and containing stringified constant monikers
function zw._reflection_builder(tbl, precursor, ...)
  local reflected = {}
  for k,v in pairs(tbl) do
    if type(v) == "number" then
      reflected[v] = k
    else
      local precursor_index = utils.screaming_snake_case(k)
      local dereference_index = utils.snake_case(k)
      local precursors = {}
      for _,p in ipairs{...} do
        precursors[#precursors + 1] = p[dereference_index]
        -- march precursors one level up
      end
      reflected[precursor[precursor_index]] = zw._reflection_builder(v, (unpack or table.unpack)(precursors))
    end
  end
  return reflected
end

--- @class st.zwave.ENCAP
--- @alias ENCAP st.zwave.ENCAP
--- @field public AUTO number
--- @field public NONE number
--- @field public CRC16 number
--- @field public S0 number
--- @field public S2_UNAUTH number
--- @field public S2_AUTH number
--- @field public S2_ACCESS_CONTROL number
--- @field public UNKNOWN number
local ENCAP = {
  AUTO = 0,
  NONE = 1,
  CRC16 = 2,
  S0 = 3,
  S2_UNAUTH = 4,
  S2_AUTH = 5,
  S2_ACCESS_CONTROL = 6,
  UNKNOWN = 255,
}
zw.ENCAP = ENCAP
local _reflect_encap = zw._reflection_builder(zw.ENCAP)

--- Reflect a constant value or a heirarchy of nested constant values into a
--- stringified constant moniker by indexing into the passed reflector table.
---
--- @param reflector table numerically indexed reflector table containing stringified constant monikers
--- @vararg number 1 or more numerical indices into the reflector ordered from top level to most deeply-nested value
function zw._reflect(reflector, ...)
  local dereference = reflector
  for _,p in ipairs{...} do
    dereference = dereference[p]
    if dereference == nil then
      return nil
    end
  end
  return type(dereference) == "string" and dereference or nil
end

--- Convert a versioned Z-Wave command class to string.
---
--- @param cmd_class number numerical Z-Wave command class designation
--- @return string stringified command class, or numerical representations on conversion failure
function zw.cc_to_string(cmd_class)
  return cc._classes[cmd_class] or cmd_class
end

--- Convert a Z-Wave command to a command ID string.
---
--- @param cmd_class number numerical Z-Wave command class designation
--- @param cmd_id number numerical Z-Wave command ID
--- @return string stringified command ID, or numerical representations on conversion failure
function zw.cmd_to_string(cmd_class, cmd_id)
  local module = zw.load_cc(cmd_class)
  if module == nil then
    return cmd_id
  end
  return module._commands[cmd_id] or cmd_id
end

--- Locate and dynamically load the module associated with cmd_class.
---
--- @param cmd_class number numerical Z-Wave command class designation
--- @return table dynamically loaded module for cmd_class
function zw.load_cc(cmd_class)
  local module = nil
  pcall(function()
    local require_path = "st.zwave.CommandClass." .. utils.pascal_case(zw.cc_to_string(cmd_class))
    module = require(require_path)
  end)
  return module
end

--- Initialize common fields of a passed Command object.
---
--- @param self table Z-Wave command instance
--- @param module table command class module instance
--- @param cmd_class number Z-Wave command class
--- @param cmd_id number Z-wave command ID
--- @param version table
--- @param transport_encap table Z-Wave security / integrity and multichannel encapsulation parameters
local function zw_cmd_init(self, module, cmd_class, cmd_id, version, transport_encap)
  self._module = module
  self.cmd_class = cmd_class or self.cmd_class
  self.cmd_id = cmd_id or self.cmd_id
  self.version = version or self.version
  assert(type(self.cmd_class) == "number", "command class must be a number")
  assert(type(self.cmd_id) == "number", "command code must be a number")
  -- it is permissible for version, encap, src_channel or dst_channels to be nil
  assert(self.version == nil or type(self.version) == "number", "version must be a number or nil")
  -- Capture encapsulation parameters, or populate defaults.
  self.encap = (transport_encap or {}).encap or self.encap or zw.ENCAP.AUTO
  self.src_channel = (transport_encap or {}).src_channel or self.src_channel or 0
  self.dst_channels = (transport_encap or {}).dst_channels or self.dst_channels or {}
  assert(type(self.encap) == "number", "encapsulation must be a number")
  assert(type(self.src_channel) == "number", "source channel must be a number")
  assert(type(self.dst_channels) == "table", "destination channels must be a table")
  self._reflect = {
    cmd_class = function() return zw.cc_to_string(self.cmd_class) end,
    cmd_id = function() return zw.cmd_to_string(self.cmd_class, self.cmd_id) end,
    encap = function() return _reflect_encap[self.encap] or self.encap end
  }
end

--- Dynamically load the st.zwave.CommandClass module associated with
--- caller-specified cmd_class and return the module's constructors for the
--- caller-specified cmd_id.
---
--- Note that some Z-Wave commands do not change from one command class version
--- to the next.  This method accounts for that, returning only the set of
--- unique constructors supporting the version set.
---
--- @param cmd_class number numerical Z-Wave command class designation
--- @param cmd_id number numerical Z-Wave command ID
--- @param versions table versions at which supporting serializers should be returned
--- @return table constructors:version table
--- @return table command class module
--- @return string optional error string
function zw._constructors(cmd_class, cmd_id, versions)
  assert(type(cmd_class) == "number", "command class must be a number")
  assert(type(cmd_id) == "number", "commadn ID must be a number")
  local module = zw.load_cc(cmd_class)
  if module == nil then
    return {},nil,"unsupported command class"
  end
  -- Associate available constructors with specified versions.
  local constructors = {}
  versions = versions or zw._deserialization_versions[cmd_class]
  for v,enabled in pairs(versions) do -- order of traversal does not matter
    if enabled and module._lut[v] and module._lut[v][cmd_id] then
      constructors[module._lut[v][cmd_id]] = v
    end
  end
  if #constructors == 0 then
    err = "unsupported command"
  end
  -- Now we have the set of constructors that can support the passed versions
  -- or the module's defaults.  Return these.
  return constructors,module,err
end

-- xpcall handler for construction errors.
local function serdes_err(err)
  if debug ~= nil then
    err = err .. "\n" .. debug.traceback()
  end
  return err
end

--- Factory-pattern constructor for Z-Wave commands.
---
--- Attempt to instantiate a versioned and decoded Command by dynamically
--- loading the module associated with cmd_class and calling the appropriate
--- command-specific constructor.  Additionally, merge in parsed command
--- arguments at all lower versions for backward compatibility.
---
--- If decode fails, self.err will be set.  If decode succeeds, named
--- arguments and version will be set and self.err will be nil.
---
--- @param cls table Command reference from __call
--- @param cmd_class number Z-Wave command class
--- @param cmd_id number Z-wave command ID
--- @param payload string Z-Wave command payload
--- @return Command constructed command instance
local function zw_cmd_factory(cls, cmd_class, cmd_id, payload, ...)
  local constructors,module,err = zw._constructors(cmd_class, cmd_id)
  local self = nil
  for constructor,_ in utils.rvalues(constructors) do -- descending order
    local success,rv = xpcall(constructor, serdes_err, module, payload, ...)
    if success then
      self = self and utils.merge(self, rv) or rv
    else
      err = rv
    end
  end
  if self == nil then
    -- Command-specific construction / decode failed.  Construct a command
    -- with raw payload.  If err is non-nil, reflect this as well.
    local mt = {
      __index = cls,
      __tostring = cls.pretty_print,
      __eq = cls.equals
    }
    self = setmetatable({}, mt)
    zw_cmd_init(self, module, cmd_class, cmd_id, nil, ...)
    self.payload = payload
    self.err = err
  end
  return self
end

--- @class st.zwave.Command
--- @alias Command st.zwave.Command
--- @field public cmd_class number numerical Z-Wave command class designation
--- @field public cmd_id number numerical Z-Wave command ID
--- @field public version number numerical Z-Wave command version
--- @field public args table command-specific arguments
--- @field public payload string Z-Wave command payload
--- @field public encap number Z-Wave security / integrity encapsulation, see :lua:class:`st.zwave.ENCAP <st.zwave.ENCAP>`
--- @field public src_channel number multichannel encapsulation source
--- @field public dst_channels table multichannel encapsulation destinations
local Command = {}
setmetatable(Command, {
  __call = function (...)
    return zw_cmd_factory(...)
  end
})

--- Determine whether the passed field is a hidden or private field of a command
--- that should be ignored in the validate, strip and reflect methods.
---
--- @param key any
--- @param value any
--- @return boolean true if the field is hidden, else false
local function hidden(key, value)
  if   key == "_reflect"
    or key == "_module"
    or type(value) == "function"
    or type(value) == "thread"
    or type(value) == "userdata"
  then
    return true
  else
    return false
  end
end

--- Recursive validation helper function.  Recurse through the passed tbl and
--- template verifying that tbl contains no table or primitive-type children
--- not present in template.  Throw an error if any extra arguments ar found.
---
--- @param tbl table table to validate
--- @param template table template against which to validate table
local function recursive_validate(tbl, template)
  for k,v in pairs(tbl) do
    if not hidden(k, v) then
      if template[k] == nil then
        error("unrecognized argument '" .. tostring(k) .. "'")
      end
      if type(v) == "table" then
        recursive_validate(v, template[k])
      end
    end
  end
end

--- Validate that command self contains no extra arguments.  Throw an error if
--- any extra arguments are found.
---
--- @param self st.zwave.Command command to validate
local function validate(self)
  recursive_validate(self.args, self:_template())
end

--- Recursive arguments-stripping helper function.  Recurse through the passed
--- tbl and template, removing all table or primitive-type children of tbl
--- not present in template.
---
--- @param tbl table table to strip
--- @param template table template of entries to retain in tbl
local function recursive_strip(tbl, template)
  for k,v in pairs(tbl) do
    if not hidden(k, v) then
      if template[k] == nil then
        tbl[k] = nil
      elseif type(v) == "table" then
        recursive_strip(v, template[k])
      end
    end
  end
end

--- Strip all arguments from self not contained in self:_template().
---
--- @param self st.zwave.Command command from which to strip extra arguments
local function strip(self)
  utils.stringify_table(self:_template())
  recursive_strip(self.args, self:_template())
end

--- Recusrive reflection helper function.  Recurse through the passed table,
--- returning a deep copy with all table and primitive-type children enclosed.
--- If a primitive-type child has a corresponding _reflect[key] niece/nephew,
--- call this to popuate a reflected version of the field.
---
--- @param tbl table table to reflect
--- @return table reflected deep-copy of tbl
local function recursive_reflect(tbl)
  local reflected = {}
  for k,v in pairs(tbl) do
    if not hidden(k, v) then
      if type(v) == "table" then
        reflected[k] = recursive_reflect(tbl[k])
      elseif tbl._reflect ~= nil and tbl._reflect[k] ~= nil then
        reflected[k] = tbl._reflect[k]() or tbl[k]
      else
        reflected[k] = tbl[k]
      end
    end
  end
  return reflected
end

--- Reflect all constants within command self into stringified monikers.
---
--- @return table table representation of self command with all constants reflected to strings
function Command:reflect()
  if self._set_reflectors then self:_set_reflectors() end
  local reflected = recursive_reflect(self)
  -- Payload may be dynamically created from the metatable __index.
  -- If so, we must manually write into ihe raw reflected table.
  reflected.payload = self.payload
  return reflected
end

--- __tostring helper for st.zwave.Command objects.
---
--- @return string stringified cmd self
function Command:pretty_print()
  return utils.stringify_table(self:reflect())
end

--- Compare two commands for equality.
---
--- @param command st.zwave.Command command for comparison with self
--- @return boolean true if commands' data are equal
function Command:equals(command)
  return self.cmd_class == command.cmd_class and
    self.cmd_id == command.cmd_id and
    self.version == command.version and
    self.encap == command.encap and
    self.src_channel == command.src_channel and
    self.payload == command.payload and
    utils.stringify_table(self.dst_channels) == utils.stringify_table(command.dst_channels)
end

--- Build a version of this command as if it is being sent to the device
---
--- @param number device_id test device id
--- @return table list of Z-Wave command positional parameters as are passed to
--- runner/src/envlib/socket.lua st_zwave_socket:send.
function Command:build_test_tx(device_id)
  return {
    device_id,
    self.encap,
    self.cmd_class,
    self.cmd_id,
    self.payload,
    self.src_channel,
    self.dst_channels
  }
end

--- Parse arguments from a named, version-specific command constructor.
---
--- Arguments may be a command payload literal, a table of named arguments, or
--- may be a previously constructed command.  This is a construction helper
--- method for objects inheriting Command.  Invoking objects must implement
--- serialize, deserialize and _template methods.
---
--- @param self table command derived from Command
--- @param module table command class module instance
--- @param cmd_class number numerical Z-Wave command class designation
--- @param cmd_id number numerical Z-Wave command ID
--- @param version number numerical Z-Wave command version
--- @param args string|table payload literal, command arguments, or a previously constructed Command
function Command._parse(self, module, cmd_class, cmd_id, version, args, ...)
  assert(self.serialize ~= nil, "self must implement serialize method")
  assert(self.deserialize ~= nil, "self must implement deserialize method")
  zw_cmd_init(self, module, cmd_class, cmd_id, version, ...)
  if type(args) == "string" then
    -- Arguments are a serialized payload literal.
    self.payload = args
    self.args = self:deserialize()
    strip(self)
    self:_set_reflectors()
  elseif rawget(args, "payload") or args.args then
    -- Arguments are a previously constructed command.
    self.payload = args.payload
    self.args = self:deserialize()
    strip(self)
    self:_set_reflectors()
  else
    -- Arguments are a table of command-specific key=value pairs.
    self.args = utils.deep_copy(args)
    if not self._module._strict then
      self:_set_defaults()
    end
    validate(self)
    self:serialize()
    utils.update(self.args, self:deserialize())
    self:_set_reflectors()
  end
end

--- Construct a command from the specified cmd_class, cmd_id and arguments at
--- the specified version, performing dynamic constructor lookup.
---
--- Arguments may be a command payload literal, a table of named arguments, or
--- may be a previously constructed command.
---
--- @param module table command class module instance
--- @param cmd_id number numerical Z-Wave command ID
--- @param version number numerical Z-Wave command version
--- @param args string|table payload literal, command arguments, or a previously constructed Command
function Command._construct(module, cmd_id, version, args, ...)
  assert(type(version) == "number",
    "module must be instantiated with version set to use implicitly versioned constructors")
  local constructor = module._lut[version] and module._lut[version][cmd_id]
  if constructor then
    return constructor(module, args, ...)
  end
  error ("constructor lookup failed")
end

zw.Command = Command
return zw
