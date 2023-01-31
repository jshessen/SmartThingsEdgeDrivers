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

return [[{"name": "Air Purifier Fan Mode", "status": "proposed", "attributes": {"airPurifierFanMode": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "AirPurifierFanMode"}}}, "values": ["auto", "sleep", "low", "medium", "high", "quiet", "windFree"]}, "supportedAirPurifierFanModes": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "array", "items": {"type": "string", "enum": ["auto", "sleep", "low", "medium", "high", "quiet", "windFree"]}}}}}}, "commands": {"setAirPurifierFanMode": {"arguments": [{"name": "airPurifierFanMode", "schema": {"$ref": "AirPurifierFanMode"}, "optional": false}], "name": "setAirPurifierFanMode"}}, "id": "airPurifierFanMode", "version": 1}]]
