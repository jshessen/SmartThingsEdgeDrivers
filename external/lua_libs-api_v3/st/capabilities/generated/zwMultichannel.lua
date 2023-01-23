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

return [[{"name": "Zw Multichannel", "status": "live", "attributes": {"epEvent": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "String"}}}}, "epInfo": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "String"}}}}}, "commands": {"enableEpEvents": {"arguments": [{"name": "enabledEndpoints", "schema": {"$ref": "String"}, "optional": false}], "name": "enableEpEvents"}, "epCmd": {"arguments": [{"name": "endpoint", "schema": {"$ref": "Number"}, "optional": false}, {"name": "commands", "schema": {"$ref": "String"}, "optional": false}], "name": "epCmd"}}, "id": "zwMultichannel", "version": 1}]]
