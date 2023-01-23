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

return [[{"name": "Gas Meter", "status": "live", "attributes": {"gasMeterVolume": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "number"}, "unit": {"type": "string", "enum": ["m^3"], "default": "m^3"}}, "required": ["value"]}}, "gasMeter": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "number"}, "unit": {"type": "string", "enum": ["kWh"], "default": "kWh"}}, "required": ["value"]}}, "gasMeterCalorific": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "number"}}, "required": ["value"]}}, "gasMeterConversion": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "number"}}, "required": ["value"]}}, "gasMeterPrecision": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "GasMeterPrecision"}}, "required": ["value"]}}, "gasMeterTime": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "Iso8601Date"}}, "required": ["value"]}}}, "commands": {}, "id": "gasMeter", "version": 1}]]
