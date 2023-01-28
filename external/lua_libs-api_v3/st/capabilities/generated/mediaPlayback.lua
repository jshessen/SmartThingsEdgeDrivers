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

return [[{"name": "Media Playback", "status": "live", "attributes": {"playbackStatus": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "string", "enum": ["paused", "playing", "stopped", "fast forwarding", "rewinding", "buffering"]}}}, "values": ["paused", "playing", "stopped", "fast forwarding", "rewinding", "buffering"], "setter": "setPlaybackStatus", "enumCommands": [{"command": "play", "value": "playing"}, {"command": "pause", "value": "paused"}, {"command": "stop", "value": "stopped"}, {"command": "fastForward", "value": "fast forwarding"}, {"command": "rewind", "value": "rewinding"}]}, "supportedPlaybackCommands": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "array", "items": {"$ref": "MediaPlaybackCommands"}}}}}}, "commands": {"setPlaybackStatus": {"arguments": [{"name": "status", "schema": {"type": "string", "enum": ["paused", "playing", "stopped", "fast forwarding", "rewinding"]}, "optional": false}], "name": "setPlaybackStatus"}, "play": {"arguments": [], "name": "play"}, "pause": {"arguments": [], "name": "pause"}, "stop": {"arguments": [], "name": "stop"}, "fastForward": {"arguments": [], "name": "fastForward"}, "rewind": {"arguments": [], "name": "rewind"}}, "id": "mediaPlayback", "version": 1}]]
