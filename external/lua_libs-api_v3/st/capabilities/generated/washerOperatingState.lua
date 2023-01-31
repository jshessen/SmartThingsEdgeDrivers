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

return [[{"name": "Washer Operating State", "status": "live", "attributes": {"machineState": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "MachineState"}}, "required": ["value"]}, "values": ["pause", "run", "stop"], "setter": "setMachineState"}, "supportedMachineStates": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "array", "items": {"$ref": "MachineState"}}}}}, "washerJobState": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "string", "enum": ["airWash", "aIRinse", "aISpin", "aIWash", "cooling", "delayWash", "drying", "finish", "none", "preWash", "rinse", "spin", "wash", "weightSensing", "wrinklePrevent", "freezeProtection"]}}, "required": ["value"]}, "values": ["airWash", "aIRinse", "aISpin", "aIWash", "cooling", "delayWash", "drying", "finish", "none", "preWash", "rinse", "spin", "wash", "weightSensing", "wrinklePrevent", "freezeProtection"]}, "completionTime": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "Iso8601Date"}}, "required": ["value"]}}}, "commands": {"setMachineState": {"arguments": [{"name": "state", "schema": {"$ref": "MachineState"}, "optional": false}], "name": "setMachineState"}}, "id": "washerOperatingState", "version": 1}]]
