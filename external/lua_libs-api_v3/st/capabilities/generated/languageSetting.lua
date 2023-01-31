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

return [[{"name": "Language Setting", "status": "proposed", "attributes": {"supportedLanguages": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "array", "items": {"type": "string"}}}}}, "language": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "string"}}}, "setter": "setLanguage"}}, "commands": {"setLanguage": {"arguments": [{"name": "language", "schema": {"$ref": "String"}, "optional": false}], "name": "setLanguage"}}, "id": "languageSetting", "version": 1}]]
