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

return [[{"name": "Stateless Scenes", "id": "statelessScenes", "version": 1, "status": "proposed", "attributes": {"supportedScenes": {"schema": {"type": "object", "properties": {"value": {"type": "array", "items": {"type": "string"}}}, "additionalProperties": false, "required": ["value"]}}}, "commands": {"setScene": {"name": "setScene", "arguments": [{"name": "scene", "schema": {"type": "string"}, "optional": false}]}}}]]
