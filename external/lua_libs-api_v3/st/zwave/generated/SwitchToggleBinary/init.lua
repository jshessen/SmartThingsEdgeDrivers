-- Copyright 2023 SmartThings
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

-- THIS CODE IS AUTOMATICALLY GENERATED BY zwave_lib_generator/gen.py.  DO NOT HAND EDIT.
--
-- Generator script revision: b'b65edec6f2fbd53d4aeed6ab08ac6f3b5ae73520'
-- Protocol definition XML version: 2.7.4

local zw = require "st.zwave"
local buf = require "st.zwave.utils.buf"
local utils = require "st.utils"

--- @class st.zwave.CommandClass.SwitchToggleBinary
--- @alias SwitchToggleBinary st.zwave.CommandClass.SwitchToggleBinary
---
--- Supported versions: 1
---
--- @field public SET number 0x01 - SWITCH_TOGGLE_BINARY_SET command id
--- @field public GET number 0x02 - SWITCH_TOGGLE_BINARY_GET command id
--- @field public REPORT number 0x03 - SWITCH_TOGGLE_BINARY_REPORT command id
local SwitchToggleBinary = {}
SwitchToggleBinary.SET = 0x01
SwitchToggleBinary.GET = 0x02
SwitchToggleBinary.REPORT = 0x03

SwitchToggleBinary._commands = {
  [SwitchToggleBinary.SET] = "SET",
  [SwitchToggleBinary.GET] = "GET",
  [SwitchToggleBinary.REPORT] = "REPORT"
}

--- Instantiate a versioned instance of the SwitchToggleBinary Command Class module, optionally setting strict to require explicit passing of all parameters to constructors.
---
--- @param params st.zwave.CommandClass.Params command class instance parameters
--- @return st.zwave.CommandClass.SwitchToggleBinary versioned command class instance
function SwitchToggleBinary:init(params)
  local version = params and params.version or nil
  if (params or {}).strict ~= nil then
  local strict = params.strict
  else
  local strict = true -- default
  end
  local strict = params and params.strict or nil
  assert(version == nil or zw._versions[zw.SWITCH_TOGGLE_BINARY][version] ~= nil, "unsupported version")
  assert(strict == nil or type(strict) == "boolean", "strict must be a boolean")
  local mt = {
    __index = self
  }
  local instance = setmetatable({}, mt)
  instance._serialization_version = version
  instance._strict = strict
  return instance
end

setmetatable(SwitchToggleBinary, {
  __call = SwitchToggleBinary.init
})

SwitchToggleBinary._serialization_version = nil
SwitchToggleBinary._strict = false
zw._deserialization_versions = zw.deserialization_versions or {}
zw._versions = zw._versions or {}
setmetatable(zw._deserialization_versions, { __index = zw._versions })
zw._versions[zw.SWITCH_TOGGLE_BINARY] = {
  [1] = true
}

--- @class st.zwave.CommandClass.SwitchToggleBinary.SetV1Args
--- @alias SetV1Args st.zwave.CommandClass.SwitchToggleBinary.SetV1Args
local SetV1Args = {}

--- @class st.zwave.CommandClass.SwitchToggleBinary.SetV1:st.zwave.Command
--- @alias SetV1 st.zwave.CommandClass.SwitchToggleBinary.SetV1
---
--- v1 SWITCH_TOGGLE_BINARY_SET
---
--- @field public cmd_class number 0x28
--- @field public cmd_id number 0x01
--- @field public version number 1
--- @field public args st.zwave.CommandClass.SwitchToggleBinary.SetV1Args command-specific arguments
local SetV1 = {}
setmetatable(SetV1, {
  __index = zw.Command,
  __call = function(cls, self, ...)
    local mt = {
      __index = function(tbl, key)
        if key == "payload" then
          return tbl:serialize()
        else
          return cls[key]
        end
      end,
      __tostring = zw.Command.pretty_print,
      __eq = zw.Command.equals
    }
    local instance = setmetatable({}, mt)
    instance:init(self, ...)
    return instance
  end,
})

--- Initialize a v1 SWITCH_TOGGLE_BINARY_SET object.
---
--- @param module st.zwave.CommandClass.SwitchToggleBinary command class module instance
--- @param args st.zwave.CommandClass.SwitchToggleBinary.SetV1Args command-specific arguments
function SetV1:init(module, args, ...)
  zw.Command._parse(self, module, zw.SWITCH_TOGGLE_BINARY, SwitchToggleBinary.SET, 1, args, ...)
end

--- Serialize v1 SWITCH_TOGGLE_BINARY_SET arguments.
---
--- @return string serialized payload
function SetV1:serialize()
  local writer = buf.Writer()
  return writer.buf
end

--- Deserialize a v1 SWITCH_TOGGLE_BINARY_SET payload.
---
--- @return st.zwave.CommandClass.SwitchToggleBinary.SetV1Args deserialized arguments
function SetV1:deserialize()
  local reader = buf.Reader(self.payload)
  return reader.parsed
end

--- Return a deep copy of self.args, merging defaults for unset, but required parameters.
---
--- @param self st.zwave.CommandClass.SwitchToggleBinary.SetV1
--- @return st.zwave.CommandClass.SwitchToggleBinary.SetV1Args
function SetV1._defaults(self)
  return {}
end

--- Return a deep copy of self.args, merging defaults for all unset parameters.
---
--- @param self st.zwave.CommandClass.SwitchToggleBinary.SetV1
--- @return st.zwave.CommandClass.SwitchToggleBinary.SetV1Args
function SetV1._template(self)
  return {}
end

--- Set defaults for any required, but unset arguments.
---
--- @param self st.zwave.CommandClass.SwitchToggleBinary.SetV1
function SetV1._set_defaults(self)
  local defaults = self:_defaults()
  utils.merge(self.args, defaults)
end

--- Set const reflectors to allow enum stringification.
---
--- @param self st.zwave.CommandClass.SwitchToggleBinary.SetV1
function SetV1._set_reflectors(self)
end

--- @class st.zwave.CommandClass.SwitchToggleBinary.GetV1Args
--- @alias GetV1Args st.zwave.CommandClass.SwitchToggleBinary.GetV1Args
local GetV1Args = {}

--- @class st.zwave.CommandClass.SwitchToggleBinary.GetV1:st.zwave.Command
--- @alias GetV1 st.zwave.CommandClass.SwitchToggleBinary.GetV1
---
--- v1 SWITCH_TOGGLE_BINARY_GET
---
--- @field public cmd_class number 0x28
--- @field public cmd_id number 0x02
--- @field public version number 1
--- @field public args st.zwave.CommandClass.SwitchToggleBinary.GetV1Args command-specific arguments
local GetV1 = {}
setmetatable(GetV1, {
  __index = zw.Command,
  __call = function(cls, self, ...)
    local mt = {
      __index = function(tbl, key)
        if key == "payload" then
          return tbl:serialize()
        else
          return cls[key]
        end
      end,
      __tostring = zw.Command.pretty_print,
      __eq = zw.Command.equals
    }
    local instance = setmetatable({}, mt)
    instance:init(self, ...)
    return instance
  end,
})

--- Initialize a v1 SWITCH_TOGGLE_BINARY_GET object.
---
--- @param module st.zwave.CommandClass.SwitchToggleBinary command class module instance
--- @param args st.zwave.CommandClass.SwitchToggleBinary.GetV1Args command-specific arguments
function GetV1:init(module, args, ...)
  zw.Command._parse(self, module, zw.SWITCH_TOGGLE_BINARY, SwitchToggleBinary.GET, 1, args, ...)
end

--- Serialize v1 SWITCH_TOGGLE_BINARY_GET arguments.
---
--- @return string serialized payload
function GetV1:serialize()
  local writer = buf.Writer()
  return writer.buf
end

--- Deserialize a v1 SWITCH_TOGGLE_BINARY_GET payload.
---
--- @return st.zwave.CommandClass.SwitchToggleBinary.GetV1Args deserialized arguments
function GetV1:deserialize()
  local reader = buf.Reader(self.payload)
  return reader.parsed
end

--- Return a deep copy of self.args, merging defaults for unset, but required parameters.
---
--- @param self st.zwave.CommandClass.SwitchToggleBinary.GetV1
--- @return st.zwave.CommandClass.SwitchToggleBinary.GetV1Args
function GetV1._defaults(self)
  return {}
end

--- Return a deep copy of self.args, merging defaults for all unset parameters.
---
--- @param self st.zwave.CommandClass.SwitchToggleBinary.GetV1
--- @return st.zwave.CommandClass.SwitchToggleBinary.GetV1Args
function GetV1._template(self)
  return {}
end

--- Set defaults for any required, but unset arguments.
---
--- @param self st.zwave.CommandClass.SwitchToggleBinary.GetV1
function GetV1._set_defaults(self)
  local defaults = self:_defaults()
  utils.merge(self.args, defaults)
end

--- Set const reflectors to allow enum stringification.
---
--- @param self st.zwave.CommandClass.SwitchToggleBinary.GetV1
function GetV1._set_reflectors(self)
end

--- @class st.zwave.CommandClass.SwitchToggleBinary.ReportV1Args
--- @alias ReportV1Args st.zwave.CommandClass.SwitchToggleBinary.ReportV1Args
--- @field public value integer see :lua:class:`SwitchToggleBinary.value <st.zwave.CommandClass.SwitchToggleBinary.value>`
local ReportV1Args = {}

--- @class st.zwave.CommandClass.SwitchToggleBinary.ReportV1:st.zwave.Command
--- @alias ReportV1 st.zwave.CommandClass.SwitchToggleBinary.ReportV1
---
--- v1 SWITCH_TOGGLE_BINARY_REPORT
---
--- @field public cmd_class number 0x28
--- @field public cmd_id number 0x03
--- @field public version number 1
--- @field public args st.zwave.CommandClass.SwitchToggleBinary.ReportV1Args command-specific arguments
local ReportV1 = {}
setmetatable(ReportV1, {
  __index = zw.Command,
  __call = function(cls, self, ...)
    local mt = {
      __index = function(tbl, key)
        if key == "payload" then
          return tbl:serialize()
        else
          return cls[key]
        end
      end,
      __tostring = zw.Command.pretty_print,
      __eq = zw.Command.equals
    }
    local instance = setmetatable({}, mt)
    instance:init(self, ...)
    return instance
  end,
})

--- Initialize a v1 SWITCH_TOGGLE_BINARY_REPORT object.
---
--- @param module st.zwave.CommandClass.SwitchToggleBinary command class module instance
--- @param args st.zwave.CommandClass.SwitchToggleBinary.ReportV1Args command-specific arguments
function ReportV1:init(module, args, ...)
  zw.Command._parse(self, module, zw.SWITCH_TOGGLE_BINARY, SwitchToggleBinary.REPORT, 1, args, ...)
end

--- Serialize v1 SWITCH_TOGGLE_BINARY_REPORT arguments.
---
--- @return string serialized payload
function ReportV1:serialize()
  local writer = buf.Writer()
  local args = self.args
  writer:write_u8(args.value)
  return writer.buf
end

--- Deserialize a v1 SWITCH_TOGGLE_BINARY_REPORT payload.
---
--- @return st.zwave.CommandClass.SwitchToggleBinary.ReportV1Args deserialized arguments
function ReportV1:deserialize()
  local reader = buf.Reader(self.payload)
  reader:read_u8("value")
  return reader.parsed
end

--- Return a deep copy of self.args, merging defaults for unset, but required parameters.
---
--- @param self st.zwave.CommandClass.SwitchToggleBinary.ReportV1
--- @return st.zwave.CommandClass.SwitchToggleBinary.ReportV1Args
function ReportV1._defaults(self)
  local args = {}
  args.value = self.args.value or 0
  return args
end

--- Return a deep copy of self.args, merging defaults for all unset parameters.
---
--- @param self st.zwave.CommandClass.SwitchToggleBinary.ReportV1
--- @return st.zwave.CommandClass.SwitchToggleBinary.ReportV1Args
function ReportV1._template(self)
  local args = self:_defaults()
  return args
end

--- Set defaults for any required, but unset arguments.
---
--- @param self st.zwave.CommandClass.SwitchToggleBinary.ReportV1
function ReportV1._set_defaults(self)
  local defaults = self:_defaults()
  utils.merge(self.args, defaults)
end

--- Set const reflectors to allow enum stringification.
---
--- @param self st.zwave.CommandClass.SwitchToggleBinary.ReportV1
function ReportV1._set_reflectors(self)
  local args = self.args
  args._reflect = args._reflect or {}
  args._reflect.value = function()
    return zw._reflect(
      SwitchToggleBinary._reflect_value,
      args.value
    )
  end
end

--- @class st.zwave.CommandClass.SwitchToggleBinary.Set
--- @alias _Set st.zwave.CommandClass.SwitchToggleBinary.Set
---
--- Dynamically versioned SWITCH_TOGGLE_BINARY_SET
---
--- Supported versions: 1; unique base versions: 1
---
--- @field public cmd_class number 0x28
--- @field public cmd_id number 0x01
--- @field public version number 1
--- @field public args st.zwave.CommandClass.SwitchToggleBinary.SetV1Args
local _Set = {}
setmetatable(_Set, {
  __call = function(cls, self, ...)
    return cls:construct(self, ...)
  end,
})

--- Construct a SWITCH_TOGGLE_BINARY_SET object at the module instance serialization version.
---
--- @param module st.zwave.CommandClass.SwitchToggleBinary command class module instance
--- @param args st.zwave.CommandClass.SwitchToggleBinary.SetV1Args command-specific arguments
--- @return st.zwave.CommandClass.SwitchToggleBinary.Set
function _Set:construct(module, args, ...)
  return zw.Command._construct(module, SwitchToggleBinary.SET, module._serialization_version, args, ...)
end

--- @class st.zwave.CommandClass.SwitchToggleBinary.Get
--- @alias _Get st.zwave.CommandClass.SwitchToggleBinary.Get
---
--- Dynamically versioned SWITCH_TOGGLE_BINARY_GET
---
--- Supported versions: 1; unique base versions: 1
---
--- @field public cmd_class number 0x28
--- @field public cmd_id number 0x02
--- @field public version number 1
--- @field public args st.zwave.CommandClass.SwitchToggleBinary.GetV1Args
local _Get = {}
setmetatable(_Get, {
  __call = function(cls, self, ...)
    return cls:construct(self, ...)
  end,
})

--- Construct a SWITCH_TOGGLE_BINARY_GET object at the module instance serialization version.
---
--- @param module st.zwave.CommandClass.SwitchToggleBinary command class module instance
--- @param args st.zwave.CommandClass.SwitchToggleBinary.GetV1Args command-specific arguments
--- @return st.zwave.CommandClass.SwitchToggleBinary.Get
function _Get:construct(module, args, ...)
  return zw.Command._construct(module, SwitchToggleBinary.GET, module._serialization_version, args, ...)
end

--- @class st.zwave.CommandClass.SwitchToggleBinary.Report
--- @alias _Report st.zwave.CommandClass.SwitchToggleBinary.Report
---
--- Dynamically versioned SWITCH_TOGGLE_BINARY_REPORT
---
--- Supported versions: 1; unique base versions: 1
---
--- @field public cmd_class number 0x28
--- @field public cmd_id number 0x03
--- @field public version number 1
--- @field public args st.zwave.CommandClass.SwitchToggleBinary.ReportV1Args
local _Report = {}
setmetatable(_Report, {
  __call = function(cls, self, ...)
    return cls:construct(self, ...)
  end,
})

--- Construct a SWITCH_TOGGLE_BINARY_REPORT object at the module instance serialization version.
---
--- @param module st.zwave.CommandClass.SwitchToggleBinary command class module instance
--- @param args st.zwave.CommandClass.SwitchToggleBinary.ReportV1Args command-specific arguments
--- @return st.zwave.CommandClass.SwitchToggleBinary.Report
function _Report:construct(module, args, ...)
  return zw.Command._construct(module, SwitchToggleBinary.REPORT, module._serialization_version, args, ...)
end

SwitchToggleBinary.SetV1 = SetV1
SwitchToggleBinary.GetV1 = GetV1
SwitchToggleBinary.ReportV1 = ReportV1
SwitchToggleBinary.Set = _Set
SwitchToggleBinary.Get = _Get
SwitchToggleBinary.Report = _Report

SwitchToggleBinary._lut = {
  [0] = { -- dynamically versioned constructors
    [SwitchToggleBinary.SET] = SwitchToggleBinary.Set,
    [SwitchToggleBinary.GET] = SwitchToggleBinary.Get,
    [SwitchToggleBinary.REPORT] = SwitchToggleBinary.Report
  },
  [1] = { -- version 1
    [SwitchToggleBinary.SET] = SwitchToggleBinary.SetV1,
    [SwitchToggleBinary.GET] = SwitchToggleBinary.GetV1,
    [SwitchToggleBinary.REPORT] = SwitchToggleBinary.ReportV1
  }
}
--- @class st.zwave.CommandClass.SwitchToggleBinary.value
--- @alias value st.zwave.CommandClass.SwitchToggleBinary.value
--- @field public OFF number 0x00
--- @field public ON number 0xFF
local value = {
  OFF = 0x00,
  ON = 0xFF
}
SwitchToggleBinary.value = value
SwitchToggleBinary._reflect_value = zw._reflection_builder(SwitchToggleBinary.value)


return SwitchToggleBinary
