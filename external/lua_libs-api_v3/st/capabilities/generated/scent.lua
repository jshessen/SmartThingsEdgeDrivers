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

return [[{"name": "Scent", "status": "proposed", "attributes": {"scentName": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "String"}}}}, "scentIntensity": {"schema": {"$ref": "IntegerPercent"}, "setter": "setScentIntensity"}}, "commands": {"setScentIntensity": {"arguments": [{"name": "intensity", "schema": {"type": "integer", "minimum": 0, "maximum": 100}, "optional": false}], "name": "setScentIntensity"}}, "id": "scent", "version": 1}]]
