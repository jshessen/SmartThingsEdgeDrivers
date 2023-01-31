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

return [[{"name": "Log Trigger", "status": "proposed", "attributes": {"logState": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "string", "enum": ["idle", "inProgress"]}}}, "values": ["idle", "inProgress"]}, "logRequestState": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "string", "enum": ["idle", "triggerRequired"]}}}, "values": ["idle", "triggerRequired"]}, "logInfo": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "JsonObject"}}, "required": ["value"]}}}, "commands": {"triggerLog": {"arguments": [], "name": "triggerLog"}, "triggerLogWithLogInfo": {"arguments": [{"name": "logInfo", "schema": {"$ref": "JsonObject"}, "optional": false}], "name": "triggerLogWithLogInfo"}, "triggerLogWithUrl": {"arguments": [{"name": "url", "schema": {"$ref": "URL"}, "optional": true}], "name": "triggerLogWithUrl"}}, "id": "logTrigger", "version": 1}]]
