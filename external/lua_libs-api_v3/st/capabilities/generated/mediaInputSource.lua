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

return [[{"name": "Media Input Source", "status": "live", "attributes": {"inputSource": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "MediaSource"}}, "required": ["value"]}, "values": ["AM", "CD", "FM", "HDMI", "HDMI1", "HDMI2", "HDMI3", "HDMI4", "HDMI5", "HDMI6", "digitalTv", "USB", "YouTube", "aux", "bluetooth", "digital", "melon", "wifi"], "setter": "setInputSource"}, "supportedInputSources": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "array", "items": {"$ref": "MediaSource"}}}, "required": ["value"]}}}, "commands": {"setInputSource": {"arguments": [{"name": "mode", "schema": {"$ref": "MediaSource"}, "optional": false}], "name": "setInputSource"}}, "id": "mediaInputSource", "version": 1}]]
