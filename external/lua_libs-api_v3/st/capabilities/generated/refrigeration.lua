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

return [[{"name": "Refrigeration", "status": "live", "attributes": {"rapidCooling": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "string", "enum": ["off", "on"]}}}, "values": ["off", "on"], "setter": "setRapidCooling"}, "rapidFreezing": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "string", "enum": ["off", "on"]}}}, "values": ["off", "on"], "setter": "setRapidFreezing"}, "defrost": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "string", "enum": ["off", "on"]}}}, "values": ["off", "on"], "setter": "setDefrost"}}, "commands": {"setRapidCooling": {"arguments": [{"name": "rapidCooling", "schema": {"type": "string", "enum": ["off", "on"]}, "optional": false}], "name": "setRapidCooling"}, "setRapidFreezing": {"arguments": [{"name": "rapidCooling", "schema": {"type": "string", "enum": ["off", "on"]}, "optional": false}], "name": "setRapidFreezing"}, "setDefrost": {"arguments": [{"name": "rapidCooling", "schema": {"type": "string", "enum": ["off", "on"]}, "optional": false}], "name": "setDefrost"}}, "id": "refrigeration", "version": 1}]]
