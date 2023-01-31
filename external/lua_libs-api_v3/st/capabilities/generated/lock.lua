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

return [[{"name": "Lock", "status": "live", "attributes": {"lock": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "LockState"}, "data": {"type": "object", "additionalProperties": false, "properties": {"method": {"type": "string", "enum": ["manual", "keypad", "auto", "command", "rfid", "fingerprint", "bluetooth"]}, "codeId": {"type": "string"}, "codeName": {"type": "string"}, "timeout": {"$ref": "Iso8601Date"}}}}, "required": ["value"]}, "values": ["locked", "unknown", "unlocked", "unlocked with timeout"], "enumCommands": [{"command": "lock", "value": "locked"}, {"command": "unlock", "value": "unlocked"}]}}, "commands": {"lock": {"arguments": [], "name": "lock"}, "unlock": {"arguments": [], "name": "unlock"}}, "id": "lock", "version": 1}]]
