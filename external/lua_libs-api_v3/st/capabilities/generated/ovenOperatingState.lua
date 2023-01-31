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

return [[{"name": "Oven Operating State", "status": "proposed", "attributes": {"machineState": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "string", "enum": ["ready", "running", "paused"]}}}, "values": ["ready", "running", "paused"], "setter": "setMachineState", "actedOnBy": ["stop"]}, "supportedMachineStates": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "array", "items": {"type": "string", "enum": ["ready", "running", "paused"]}}}}}, "ovenJobState": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "string", "enum": ["cleaning", "cooking", "cooling", "draining", "preheat", "ready", "rinsing", "finished", "scheduledStart", "warming", "defrosting", "sensing", "searing", "fastPreheat", "scheduledEnd", "stoneHeating", "timeHoldPreheat"]}}}, "values": ["cleaning", "cooking", "cooling", "draining", "preheat", "ready", "rinsing", "finished", "scheduledStart", "warming", "defrosting", "sensing", "searing", "fastPreheat", "scheduledEnd", "stoneHeating", "timeHoldPreheat"]}, "completionTime": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "Iso8601Date"}}, "required": ["value"]}}, "operationTime": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "PositiveInteger"}}}, "actedOnBy": ["stop"]}, "progress": {"schema": {"$ref": "IntegerPercent"}}}, "commands": {"setMachineState": {"arguments": [{"name": "state", "schema": {"type": "string", "enum": ["stop"]}, "optional": false}], "name": "setMachineState"}, "stop": {"arguments": [], "name": "stop"}, "start": {"arguments": [{"name": "mode", "schema": {"$ref": "OvenMode"}, "optional": true}, {"name": "time", "schema": {"$ref": "PositiveInteger"}, "optional": true}, {"name": "setpoint", "schema": {"$ref": "PositiveInteger"}, "optional": true}], "name": "start"}}, "id": "ovenOperatingState", "version": 1}]]
