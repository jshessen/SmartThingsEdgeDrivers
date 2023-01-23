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

--- @class st.zwave.CommandClass.MultiInstance
--- @alias MultiInstance st.zwave.CommandClass.MultiInstance
---
--- Supported versions: 1
---
--- @field public MULTI_INSTANCE_GET number 0x04 - MULTI_INSTANCE_GET command id
--- @field public MULTI_INSTANCE_REPORT number 0x05 - MULTI_INSTANCE_REPORT command id
--- @field public MULTI_INSTANCE_CMD_ENCAP number 0x06 - MULTI_INSTANCE_CMD_ENCAP command id
local MultiInstance = {}
MultiInstance.MULTI_INSTANCE_GET = 0x04
MultiInstance.MULTI_INSTANCE_REPORT = 0x05
MultiInstance.MULTI_INSTANCE_CMD_ENCAP = 0x06

MultiInstance._commands = {
  [MultiInstance.MULTI_INSTANCE_GET] = "MULTI_INSTANCE_GET",
  [MultiInstance.MULTI_INSTANCE_REPORT] = "MULTI_INSTANCE_REPORT",
  [MultiInstance.MULTI_INSTANCE_CMD_ENCAP] = "MULTI_INSTANCE_CMD_ENCAP"
}

--- Instantiate a versioned instance of the MultiInstance Command Class module, optionally setting strict to require explicit passing of all parameters to constructors.
---
--- @param params st.zwave.CommandClass.Params command class instance parameters
--- @return st.zwave.CommandClass.MultiInstance versioned command class instance
function MultiInstance:init(params)
  local version = params and params.version or nil
  if (params or {}).strict ~= nil then
  local strict = params.strict
  else
  local strict = true -- default
  end
  local strict = params and params.strict or nil
  assert(version == nil or zw._versions[zw.MULTI_INSTANCE][version] ~= nil, "unsupported version")
  assert(strict == nil or type(strict) == "boolean", "strict must be a boolean")
  local mt = {
    __index = self
  }
  local instance = setmetatable({}, mt)
  instance._serialization_version = version
  instance._strict = strict
  return instance
end

setmetatable(MultiInstance, {
  __call = MultiInstance.init
})

MultiInstance._serialization_version = nil
MultiInstance._strict = false
zw._deserialization_versions = zw.deserialization_versions or {}
zw._versions = zw._versions or {}
setmetatable(zw._deserialization_versions, { __index = zw._versions })
zw._versions[zw.MULTI_INSTANCE] = {
  [1] = true
}

--- @class st.zwave.CommandClass.MultiInstance.MultiInstanceGetV1Args
--- @alias MultiInstanceGetV1Args st.zwave.CommandClass.MultiInstance.MultiInstanceGetV1Args
--- @field public command_class integer
local MultiInstanceGetV1Args = {}

--- @class st.zwave.CommandClass.MultiInstance.MultiInstanceGetV1:st.zwave.Command
--- @alias MultiInstanceGetV1 st.zwave.CommandClass.MultiInstance.MultiInstanceGetV1
---
--- v1 and forward-compatible v2,v3,v4 MULTI_INSTANCE_GET
---
--- @field public cmd_class number 0x60
--- @field public cmd_id number 0x04
--- @field public version number 1
--- @field public args st.zwave.CommandClass.MultiInstance.MultiInstanceGetV1Args command-specific arguments
local MultiInstanceGetV1 = {}
setmetatable(MultiInstanceGetV1, {
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

--- Initialize a v1 and forward-compatible v2,v3,v4 MULTI_INSTANCE_GET object.
---
--- @param module st.zwave.CommandClass.MultiInstance command class module instance
--- @param args st.zwave.CommandClass.MultiInstance.MultiInstanceGetV1Args command-specific arguments
function MultiInstanceGetV1:init(module, args, ...)
  zw.Command._parse(self, module, zw.MULTI_INSTANCE, MultiInstance.MULTI_INSTANCE_GET, 1, args, ...)
end

--- Serialize v1 or forward-compatible v2,v3,v4 MULTI_INSTANCE_GET arguments.
---
--- @return string serialized payload
function MultiInstanceGetV1:serialize()
  local writer = buf.Writer()
  local args = self.args
  writer:write_cmd_class(args.command_class)
  return writer.buf
end

--- Deserialize a v1 or forward-compatible v2,v3,v4 MULTI_INSTANCE_GET payload.
---
--- @return st.zwave.CommandClass.MultiInstance.MultiInstanceGetV1Args deserialized arguments
function MultiInstanceGetV1:deserialize()
  local reader = buf.Reader(self.payload)
  reader:read_cmd_class("command_class")
  return reader.parsed
end

--- Return a deep copy of self.args, merging defaults for unset, but required parameters.
---
--- @param self st.zwave.CommandClass.MultiInstance.MultiInstanceGetV1
--- @return st.zwave.CommandClass.MultiInstance.MultiInstanceGetV1Args
function MultiInstanceGetV1._defaults(self)
  local args = {}
  args.command_class = self.args.command_class or 0
  return args
end

--- Return a deep copy of self.args, merging defaults for all unset parameters.
---
--- @param self st.zwave.CommandClass.MultiInstance.MultiInstanceGetV1
--- @return st.zwave.CommandClass.MultiInstance.MultiInstanceGetV1Args
function MultiInstanceGetV1._template(self)
  local args = self:_defaults()
  return args
end

--- Set defaults for any required, but unset arguments.
---
--- @param self st.zwave.CommandClass.MultiInstance.MultiInstanceGetV1
function MultiInstanceGetV1._set_defaults(self)
  local defaults = self:_defaults()
  utils.merge(self.args, defaults)
end

--- Set const reflectors to allow enum stringification.
---
--- @param self st.zwave.CommandClass.MultiInstance.MultiInstanceGetV1
function MultiInstanceGetV1._set_reflectors(self)
end

--- @class st.zwave.CommandClass.MultiInstance.MultiInstanceReportV1Args
--- @alias MultiInstanceReportV1Args st.zwave.CommandClass.MultiInstance.MultiInstanceReportV1Args
--- @field public command_class integer
--- @field public instances integer [0,255]
local MultiInstanceReportV1Args = {}

--- @class st.zwave.CommandClass.MultiInstance.MultiInstanceReportV1:st.zwave.Command
--- @alias MultiInstanceReportV1 st.zwave.CommandClass.MultiInstance.MultiInstanceReportV1
---
--- v1 MULTI_INSTANCE_REPORT
---
--- @field public cmd_class number 0x60
--- @field public cmd_id number 0x05
--- @field public version number 1
--- @field public args st.zwave.CommandClass.MultiInstance.MultiInstanceReportV1Args command-specific arguments
local MultiInstanceReportV1 = {}
setmetatable(MultiInstanceReportV1, {
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

--- Initialize a v1 MULTI_INSTANCE_REPORT object.
---
--- @param module st.zwave.CommandClass.MultiInstance command class module instance
--- @param args st.zwave.CommandClass.MultiInstance.MultiInstanceReportV1Args command-specific arguments
function MultiInstanceReportV1:init(module, args, ...)
  zw.Command._parse(self, module, zw.MULTI_INSTANCE, MultiInstance.MULTI_INSTANCE_REPORT, 1, args, ...)
end

--- Serialize v1 MULTI_INSTANCE_REPORT arguments.
---
--- @return string serialized payload
function MultiInstanceReportV1:serialize()
  local writer = buf.Writer()
  local args = self.args
  writer:write_cmd_class(args.command_class)
  writer:write_u8(args.instances)
  return writer.buf
end

--- Deserialize a v1 MULTI_INSTANCE_REPORT payload.
---
--- @return st.zwave.CommandClass.MultiInstance.MultiInstanceReportV1Args deserialized arguments
function MultiInstanceReportV1:deserialize()
  local reader = buf.Reader(self.payload)
  reader:read_cmd_class("command_class")
  reader:read_u8("instances")
  return reader.parsed
end

--- Return a deep copy of self.args, merging defaults for unset, but required parameters.
---
--- @param self st.zwave.CommandClass.MultiInstance.MultiInstanceReportV1
--- @return st.zwave.CommandClass.MultiInstance.MultiInstanceReportV1Args
function MultiInstanceReportV1._defaults(self)
  local args = {}
  args.command_class = self.args.command_class or 0
  args.instances = self.args.instances or 0
  return args
end

--- Return a deep copy of self.args, merging defaults for all unset parameters.
---
--- @param self st.zwave.CommandClass.MultiInstance.MultiInstanceReportV1
--- @return st.zwave.CommandClass.MultiInstance.MultiInstanceReportV1Args
function MultiInstanceReportV1._template(self)
  local args = self:_defaults()
  return args
end

--- Set defaults for any required, but unset arguments.
---
--- @param self st.zwave.CommandClass.MultiInstance.MultiInstanceReportV1
function MultiInstanceReportV1._set_defaults(self)
  local defaults = self:_defaults()
  utils.merge(self.args, defaults)
end

--- Set const reflectors to allow enum stringification.
---
--- @param self st.zwave.CommandClass.MultiInstance.MultiInstanceReportV1
function MultiInstanceReportV1._set_reflectors(self)
end

--- @class st.zwave.CommandClass.MultiInstance.MultiInstanceCmdEncapV1Args
--- @alias MultiInstanceCmdEncapV1Args st.zwave.CommandClass.MultiInstance.MultiInstanceCmdEncapV1Args
--- @field public instance integer [0,255]
--- @field public command_class integer
--- @field public command integer [0,255]
--- @field public parameter string
local MultiInstanceCmdEncapV1Args = {}

--- @class st.zwave.CommandClass.MultiInstance.MultiInstanceCmdEncapV1:st.zwave.Command
--- @alias MultiInstanceCmdEncapV1 st.zwave.CommandClass.MultiInstance.MultiInstanceCmdEncapV1
---
--- v1 MULTI_INSTANCE_CMD_ENCAP
---
--- @field public cmd_class number 0x60
--- @field public cmd_id number 0x06
--- @field public version number 1
--- @field public args st.zwave.CommandClass.MultiInstance.MultiInstanceCmdEncapV1Args command-specific arguments
local MultiInstanceCmdEncapV1 = {}
setmetatable(MultiInstanceCmdEncapV1, {
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

--- Initialize a v1 MULTI_INSTANCE_CMD_ENCAP object.
---
--- @param module st.zwave.CommandClass.MultiInstance command class module instance
--- @param args st.zwave.CommandClass.MultiInstance.MultiInstanceCmdEncapV1Args command-specific arguments
function MultiInstanceCmdEncapV1:init(module, args, ...)
  zw.Command._parse(self, module, zw.MULTI_INSTANCE, MultiInstance.MULTI_INSTANCE_CMD_ENCAP, 1, args, ...)
end

--- Serialize v1 MULTI_INSTANCE_CMD_ENCAP arguments.
---
--- @return string serialized payload
function MultiInstanceCmdEncapV1:serialize()
  local writer = buf.Writer()
  local args = self.args
  writer:write_u8(args.instance)
  writer:write_cmd_class(args.command_class)
  writer:write_u8(args.command)
  writer:write_bytes(args.parameter)
  return writer.buf
end

--- Deserialize a v1 MULTI_INSTANCE_CMD_ENCAP payload.
---
--- @return st.zwave.CommandClass.MultiInstance.MultiInstanceCmdEncapV1Args deserialized arguments
function MultiInstanceCmdEncapV1:deserialize()
  local reader = buf.Reader(self.payload)
  reader:read_u8("instance")
  reader:read_cmd_class("command_class")
  reader:read_u8("command")
  reader:read_bytes(reader:remain(), "parameter")
  return reader.parsed
end

--- Return a deep copy of self.args, merging defaults for unset, but required parameters.
---
--- @param self st.zwave.CommandClass.MultiInstance.MultiInstanceCmdEncapV1
--- @return st.zwave.CommandClass.MultiInstance.MultiInstanceCmdEncapV1Args
function MultiInstanceCmdEncapV1._defaults(self)
  local args = {}
  args.instance = self.args.instance or 0
  args.command_class = self.args.command_class or 0
  args.command = self.args.command or 0
  args.parameter = self.args.parameter or ""
  return args
end

--- Return a deep copy of self.args, merging defaults for all unset parameters.
---
--- @param self st.zwave.CommandClass.MultiInstance.MultiInstanceCmdEncapV1
--- @return st.zwave.CommandClass.MultiInstance.MultiInstanceCmdEncapV1Args
function MultiInstanceCmdEncapV1._template(self)
  local args = self:_defaults()
  return args
end

--- Set defaults for any required, but unset arguments.
---
--- @param self st.zwave.CommandClass.MultiInstance.MultiInstanceCmdEncapV1
function MultiInstanceCmdEncapV1._set_defaults(self)
  local defaults = self:_defaults()
  utils.merge(self.args, defaults)
end

--- Set const reflectors to allow enum stringification.
---
--- @param self st.zwave.CommandClass.MultiInstance.MultiInstanceCmdEncapV1
function MultiInstanceCmdEncapV1._set_reflectors(self)
end

--- @class st.zwave.CommandClass.MultiInstance.MultiInstanceGet
--- @alias _MultiInstanceGet st.zwave.CommandClass.MultiInstance.MultiInstanceGet
---
--- Dynamically versioned MULTI_INSTANCE_GET
---
--- Supported versions: 1; unique base versions: 1
---
--- @field public cmd_class number 0x60
--- @field public cmd_id number 0x04
--- @field public version number 1
--- @field public args st.zwave.CommandClass.MultiInstance.MultiInstanceGetV1Args
local _MultiInstanceGet = {}
setmetatable(_MultiInstanceGet, {
  __call = function(cls, self, ...)
    return cls:construct(self, ...)
  end,
})

--- Construct a MULTI_INSTANCE_GET object at the module instance serialization version.
---
--- @param module st.zwave.CommandClass.MultiInstance command class module instance
--- @param args st.zwave.CommandClass.MultiInstance.MultiInstanceGetV1Args command-specific arguments
--- @return st.zwave.CommandClass.MultiInstance.MultiInstanceGet
function _MultiInstanceGet:construct(module, args, ...)
  return zw.Command._construct(module, MultiInstance.MULTI_INSTANCE_GET, module._serialization_version, args, ...)
end

--- @class st.zwave.CommandClass.MultiInstance.MultiInstanceReport
--- @alias _MultiInstanceReport st.zwave.CommandClass.MultiInstance.MultiInstanceReport
---
--- Dynamically versioned MULTI_INSTANCE_REPORT
---
--- Supported versions: 1; unique base versions: 1
---
--- @field public cmd_class number 0x60
--- @field public cmd_id number 0x05
--- @field public version number 1
--- @field public args st.zwave.CommandClass.MultiInstance.MultiInstanceReportV1Args
local _MultiInstanceReport = {}
setmetatable(_MultiInstanceReport, {
  __call = function(cls, self, ...)
    return cls:construct(self, ...)
  end,
})

--- Construct a MULTI_INSTANCE_REPORT object at the module instance serialization version.
---
--- @param module st.zwave.CommandClass.MultiInstance command class module instance
--- @param args st.zwave.CommandClass.MultiInstance.MultiInstanceReportV1Args command-specific arguments
--- @return st.zwave.CommandClass.MultiInstance.MultiInstanceReport
function _MultiInstanceReport:construct(module, args, ...)
  return zw.Command._construct(module, MultiInstance.MULTI_INSTANCE_REPORT, module._serialization_version, args, ...)
end

--- @class st.zwave.CommandClass.MultiInstance.MultiInstanceCmdEncap
--- @alias _MultiInstanceCmdEncap st.zwave.CommandClass.MultiInstance.MultiInstanceCmdEncap
---
--- Dynamically versioned MULTI_INSTANCE_CMD_ENCAP
---
--- Supported versions: 1; unique base versions: 1
---
--- @field public cmd_class number 0x60
--- @field public cmd_id number 0x06
--- @field public version number 1
--- @field public args st.zwave.CommandClass.MultiInstance.MultiInstanceCmdEncapV1Args
local _MultiInstanceCmdEncap = {}
setmetatable(_MultiInstanceCmdEncap, {
  __call = function(cls, self, ...)
    return cls:construct(self, ...)
  end,
})

--- Construct a MULTI_INSTANCE_CMD_ENCAP object at the module instance serialization version.
---
--- @param module st.zwave.CommandClass.MultiInstance command class module instance
--- @param args st.zwave.CommandClass.MultiInstance.MultiInstanceCmdEncapV1Args command-specific arguments
--- @return st.zwave.CommandClass.MultiInstance.MultiInstanceCmdEncap
function _MultiInstanceCmdEncap:construct(module, args, ...)
  return zw.Command._construct(module, MultiInstance.MULTI_INSTANCE_CMD_ENCAP, module._serialization_version, args, ...)
end

MultiInstance.MultiInstanceGetV1 = MultiInstanceGetV1
MultiInstance.MultiInstanceReportV1 = MultiInstanceReportV1
MultiInstance.MultiInstanceCmdEncapV1 = MultiInstanceCmdEncapV1
MultiInstance.MultiInstanceGet = _MultiInstanceGet
MultiInstance.MultiInstanceReport = _MultiInstanceReport
MultiInstance.MultiInstanceCmdEncap = _MultiInstanceCmdEncap

MultiInstance._lut = {
  [0] = { -- dynamically versioned constructors
    [MultiInstance.MULTI_INSTANCE_GET] = MultiInstance.MultiInstanceGet,
    [MultiInstance.MULTI_INSTANCE_REPORT] = MultiInstance.MultiInstanceReport,
    [MultiInstance.MULTI_INSTANCE_CMD_ENCAP] = MultiInstance.MultiInstanceCmdEncap
  },
  [1] = { -- version 1
    [MultiInstance.MULTI_INSTANCE_GET] = MultiInstance.MultiInstanceGetV1,
    [MultiInstance.MULTI_INSTANCE_REPORT] = MultiInstance.MultiInstanceReportV1,
    [MultiInstance.MULTI_INSTANCE_CMD_ENCAP] = MultiInstance.MultiInstanceCmdEncapV1
  }
}

return MultiInstance
