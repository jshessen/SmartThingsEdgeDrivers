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

return [[{"name": "Demand Response Load Control", "status": "proposed", "attributes": {"drlcStatus": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "DemandResponseLoadControlStatus"}}, "required": ["value"]}}}, "commands": {"requestDrlcAction": {"arguments": [{"name": "drlcType", "schema": {"$ref": "DrlcType"}, "optional": false}, {"name": "drlcLevel", "schema": {"$ref": "DrlcLevel"}, "optional": false}, {"name": "start", "schema": {"$ref": "Iso8601Date"}, "optional": false}, {"name": "duration", "schema": {"$ref": "PositiveInteger"}, "optional": false}, {"name": "reportingPeriod", "schema": {"$ref": "PositiveInteger"}, "optional": true}], "name": "requestDrlcAction"}, "overrideDrlcAction": {"arguments": [{"name": "value", "schema": {"type": "boolean"}, "optional": false}], "name": "overrideDrlcAction"}}, "id": "demandResponseLoadControl", "version": 1}]]
