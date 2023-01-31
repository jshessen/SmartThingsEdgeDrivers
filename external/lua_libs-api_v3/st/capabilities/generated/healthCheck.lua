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

return [[{"name": "Health Check", "status": "live", "attributes": {"checkInterval": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "integer", "minimum": 0, "maximum": 604800}, "data": {"type": "object", "additionalProperties": false, "properties": {"deviceScheme": {"type": "string", "enum": ["MIXED", "TRACKED", "UNTRACKED"]}, "hubHardwareId": {"type": "string", "pattern": "^[0-9a-fA-F]{4}$"}, "protocol": {"$ref": "DeviceHealthProtocol"}, "offlinePingable": {"type": "string", "enum": ["0", "1"]}, "badProperty": {"type": "string"}}}, "unit": {"type": "string", "enum": ["s"], "default": "s"}}, "required": ["value"]}}, "DeviceWatch-DeviceStatus": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "string", "enum": ["online", "offline"]}, "data": {"type": "object", "additionalProperties": false, "properties": {"deviceScheme": {"type": "string", "enum": ["MIXED", "TRACKED", "UNTRACKED"]}, "badProperty": {"type": "string"}}}}, "required": ["value"]}, "values": ["online", "offline"], "actedOnBy": ["ping"]}, "healthStatus": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "string", "enum": ["online", "offline"]}, "data": {"type": "object", "additionalProperties": false, "properties": {"deviceScheme": {"type": "string", "enum": ["MIXED", "TRACKED", "UNTRACKED"]}, "badProperty": {"type": "string"}}}}, "required": ["value"]}, "values": ["online", "offline"], "actedOnBy": ["ping"]}, "DeviceWatch-Enroll": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "DeviceHealthEnroll"}}, "required": ["value"]}}}, "commands": {"ping": {"arguments": [], "name": "ping"}}, "id": "healthCheck", "version": 1}]]
