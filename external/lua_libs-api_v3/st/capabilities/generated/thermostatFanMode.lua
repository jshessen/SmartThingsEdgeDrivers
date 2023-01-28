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

return [[{"name": "Thermostat Fan Mode", "status": "live", "attributes": {"thermostatFanMode": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "ThermostatFanMode"}, "data": {"type": "object", "additionalProperties": false, "properties": {"supportedThermostatFanModes": {"type": "array", "items": {"$ref": "ThermostatFanMode"}}}}}, "required": ["value"]}, "values": ["auto", "circulate", "followschedule", "on"], "setter": "setThermostatFanMode", "enumCommands": [{"command": "fanAuto", "value": "auto"}, {"command": "fanCirculate", "value": "circulate"}, {"command": "fanOn", "value": "on"}]}, "supportedThermostatFanModes": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "array", "items": {"$ref": "ThermostatFanMode"}}}}}}, "commands": {"fanAuto": {"arguments": [], "name": "fanAuto"}, "fanCirculate": {"arguments": [], "name": "fanCirculate"}, "fanOn": {"arguments": [], "name": "fanOn"}, "setThermostatFanMode": {"arguments": [{"name": "mode", "schema": {"$ref": "ThermostatFanMode"}, "optional": false}], "name": "setThermostatFanMode"}}, "id": "thermostatFanMode", "version": 1}]]
