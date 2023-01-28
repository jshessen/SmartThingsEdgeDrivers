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

return [[{"name": "Alarm", "status": "live", "attributes": {"alarm": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "AlertState"}}, "required": ["value"]}, "values": ["both", "off", "siren", "strobe"], "enumCommands": [{"command": "both", "value": "both"}, {"command": "off", "value": "off"}, {"command": "siren", "value": "siren"}, {"command": "strobe", "value": "strobe"}]}}, "commands": {"both": {"arguments": [], "name": "both"}, "off": {"arguments": [], "name": "off"}, "siren": {"arguments": [], "name": "siren"}, "strobe": {"arguments": [], "name": "strobe"}}, "id": "alarm", "version": 1}]]
