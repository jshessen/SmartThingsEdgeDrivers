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

return [[{"name": "Vehicle Information", "status": "proposed", "attributes": {"vehicleColor": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "String"}}}}, "vehicleMake": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "String"}}}}, "vehicleModel": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "String"}}}}, "vehicleTrim": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "String"}}}}, "vehicleYear": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "integer", "minimum": 0, "maximum": 9999}}}}, "vehicleId": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "String"}}}}, "vehiclePlate": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "String"}}}}, "vehicleImage": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "URL"}}}}}, "commands": {}, "id": "vehicleInformation", "version": 1}]]
