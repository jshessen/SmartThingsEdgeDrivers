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

return [[{"id": "cameraPreset", "version": 1, "status": "proposed", "name": "Camera Preset", "attributes": {"presets": {"schema": {"type": "object", "properties": {"value": {"type": "array", "items": {"title": "Camera Preset", "type": "object", "additionalProperties": false, "properties": {"name": {"type": "string"}, "id": {"type": "string"}, "data": {"$ref": "JsonObject"}}, "required": ["name", "id", "data"]}}}, "additionalProperties": false, "required": ["value"]}, "enumCommands": []}}, "commands": {"execute": {"arguments": [{"name": "id", "schema": {"type": "string"}, "optional": false}], "name": "execute"}, "create": {"arguments": [{"name": "name", "schema": {"title": "String", "type": "string", "maxLength": 255}, "optional": false}, {"name": "id", "schema": {"title": "String", "type": "string", "maxLength": 255}, "optional": true}, {"name": "data", "schema": {"$ref": "JsonObject"}, "optional": true}], "name": "create"}, "delete": {"arguments": [{"name": "id", "schema": {"type": "string"}, "optional": false}], "name": "delete"}, "update": {"arguments": [{"name": "id", "schema": {"title": "String", "type": "string", "maxLength": 255}, "optional": false}, {"name": "name", "schema": {"title": "String", "type": "string", "maxLength": 255}, "optional": true}, {"name": "data", "schema": {"$ref": "JsonObject"}, "optional": true}], "name": "update"}}}]]
