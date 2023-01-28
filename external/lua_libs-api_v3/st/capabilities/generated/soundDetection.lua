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

return [[{"name": "Sound Detection", "status": "live", "attributes": {"soundDetectionState": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "EnableState"}}, "required": ["value"]}, "values": ["enabled", "disabled"], "enumCommands": [{"command": "enableSoundDetection", "value": "enabled"}, {"command": "disableSoundDetection", "value": "disabled"}]}, "soundDetected": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "DetectedSoundType"}}, "required": ["value"]}, "values": ["noSound", "babyCrying", "glassBreaking", "fireAlarm", "dogBarking", "catMeowing", "doorKnocking", "siren", "fingerSnapping", "snoring"]}, "supportedSoundTypes": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "array", "items": {"$ref": "DetectedSoundType"}}}, "required": ["value"]}}}, "commands": {"enableSoundDetection": {"arguments": [], "name": "enableSoundDetection"}, "disableSoundDetection": {"arguments": [], "name": "disableSoundDetection"}}, "id": "soundDetection", "version": 1}]]
