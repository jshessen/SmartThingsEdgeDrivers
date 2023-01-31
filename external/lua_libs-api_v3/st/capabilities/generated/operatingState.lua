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

return [[{"name": "Operating State", "status": "proposed", "attributes": {"machineState": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "OperatingState"}}, "required": ["value"]}, "values": ["paused", "running", "ready"], "setter": "setMachineState"}, "supportedMachineStates": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "array", "items": {"$ref": "OperatingState"}}}, "required": ["value"]}}}, "commands": {"setMachineState": {"arguments": [{"name": "state", "schema": {"$ref": "OperatingState"}, "optional": false}], "name": "setMachineState"}}, "id": "operatingState", "version": 1}]]
