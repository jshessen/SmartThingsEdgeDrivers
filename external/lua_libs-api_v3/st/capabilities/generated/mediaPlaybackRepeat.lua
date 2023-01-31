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

return [[{"name": "Media Playback Repeat", "status": "proposed", "attributes": {"playbackRepeatMode": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "string", "enum": ["all", "off", "one"]}}, "required": ["value"]}, "values": ["all", "off", "one"], "setter": "setPlaybackRepeatMode"}}, "commands": {"setPlaybackRepeatMode": {"arguments": [{"name": "mode", "schema": {"type": "string", "enum": ["all", "off", "one"]}, "optional": false}], "name": "setPlaybackRepeatMode"}}, "id": "mediaPlaybackRepeat", "version": 1}]]
