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

return [[{"name": "Geofence", "status": "proposed", "attributes": {"name": {"schema": {"type": "object", "properties": {"value": {"type": "string"}}, "additionalProperties": false, "required": ["value"]}, "setter": "setName"}, "geofence": {"schema": {"type": "object", "properties": {"value": {"$ref": "GeofenceRadiusData"}}, "additionalProperties": false, "required": ["value"]}, "setter": "setGeofence"}, "enableState": {"schema": {"type": "object", "properties": {"value": {"$ref": "EnableState"}}, "additionalProperties": false, "required": ["value"]}, "setter": "setEnableState", "values": ["enabled", "disabled"]}}, "commands": {"setName": {"arguments": [{"name": "name", "schema": {"type": "string"}, "optional": false}], "name": "setName"}, "setGeofence": {"arguments": [{"name": "geofence", "schema": {"$ref": "GeofenceRadiusData"}, "optional": false}], "name": "setGeofence"}, "setEnableState": {"arguments": [{"name": "enableState", "schema": {"$ref": "EnableState"}, "optional": false}], "name": "setEnableState"}}, "id": "geofence", "version": 1}]]
