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

return [[{"name": "Audio Mute", "status": "live", "attributes": {"mute": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "MuteState"}}, "required": ["value"]}, "values": ["muted", "unmuted"], "setter": "setMute", "enumCommands": [{"command": "mute", "value": "muted"}, {"command": "unmute", "value": "unmuted"}]}}, "commands": {"setMute": {"arguments": [{"name": "state", "schema": {"$ref": "MuteState"}, "optional": false}], "name": "setMute"}, "mute": {"arguments": [], "name": "mute"}, "unmute": {"arguments": [], "name": "unmute"}}, "id": "audioMute", "version": 1}]]
