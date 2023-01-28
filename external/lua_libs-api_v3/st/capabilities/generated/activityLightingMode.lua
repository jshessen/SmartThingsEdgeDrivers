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

return [[{"name": "Activity Lighting Mode", "status": "proposed", "attributes": {"lightingMode": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "string", "enum": ["reading", "writing", "computer", "night", "sleepPreparation", "day", "cozy", "soft"]}}, "required": ["value"]}, "values": ["reading", "writing", "computer", "night", "sleepPreparation", "day", "cozy", "soft"], "setter": "setLightingMode"}}, "commands": {"setLightingMode": {"arguments": [{"name": "lightingMode", "schema": {"type": "string", "enum": ["reading", "writing", "computer", "night", "sleepPreparation", "day", "cozy", "soft"]}, "optional": false}], "name": "setLightingMode"}}, "id": "activityLightingMode", "version": 1}]]
