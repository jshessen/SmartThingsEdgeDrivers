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

return [[{"name": "Image Capture", "status": "live", "attributes": {"image": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "URL"}}, "required": ["value"]}, "setter": "take"}, "captureTime": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "Iso8601Date"}}, "required": ["value"]}}, "encrypted": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "boolean"}}, "required": ["value"]}}}, "commands": {"take": {"arguments": [{"name": "correlationId", "schema": {"$ref": "String"}, "optional": true}, {"name": "reason", "schema": {"$ref": "String"}, "optional": true}], "name": "take"}}, "id": "imageCapture", "version": 1}]]
