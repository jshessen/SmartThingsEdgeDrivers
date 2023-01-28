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
local generic_body = {}

--- This represents an unknown body of a Zigbee message and is essentially just a bytes container
--- @class GenericBody
---
local GenericBody = {
  NAME = "GenericBody",
}
GenericBody.__index = GenericBody

generic_body.GenericBody = GenericBody

--- Get the length of this body in bytes
---
--- @return number the length of the body in bytes
function GenericBody:get_length()
  return #self.body_bytes
end

--- Get the serialized version of this body
---
--- @return string the byte string of this body
function GenericBody:_serialize()
  return self.body_bytes
end

--- Get a human readable representation of this body
---
--- @return string a human readable representation of this body
function GenericBody:pretty_print()
  local out_str = self.NAME .. ": "
  for i = 1, #self.body_bytes do
    out_str = out_str .. string.format(" %02X", string.byte(self.body_bytes:sub(i,i)))
  end
  return out_str
end
GenericBody.__tostring = GenericBody.pretty_print

function GenericBody.deserialize(buf)
  local ret = {}
  setmetatable(ret, GenericBody)
  ret.body_bytes = buf:read_bytes(buf:remain())
  return ret
end

function GenericBody.init(orig, payload)
  local ret = {}
  setmetatable(ret, GenericBody)
  ret.body_bytes = payload
  return ret
end

setmetatable(GenericBody, {
  __call = GenericBody.init
})

return generic_body
