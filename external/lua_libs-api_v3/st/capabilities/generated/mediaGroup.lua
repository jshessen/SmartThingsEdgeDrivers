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

return [[{"name": "Media Group", "status": "proposed", "attributes": {"groupRole": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "string", "enum": ["primary", "auxilary", "ungrouped"]}}, "required": ["value"]}, "values": ["primary", "auxilary", "ungrouped"]}, "groupPrimaryDeviceId": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "String"}}, "required": ["value"]}}, "groupId": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "String"}}, "required": ["value"]}}, "groupVolume": {"schema": {"$ref": "IntegerPercent"}, "setter": "setGroupVolume", "actedOnBy": ["groupVolumeUp", "groupVolumeDown"]}, "groupMute": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "MuteState"}}, "required": ["value"]}, "values": ["muted", "unmuted"], "setter": "setGroupMute", "enumCommands": [{"command": "muteGroup", "value": "muted"}, {"command": "unmuteGroup", "value": "unmuted"}]}}, "commands": {"setGroupVolume": {"arguments": [{"name": "groupVolume", "schema": {"type": "integer", "minimum": 0, "maximum": 100}, "optional": false}], "name": "setGroupVolume"}, "groupVolumeUp": {"arguments": [], "name": "groupVolumeUp"}, "groupVolumeDown": {"arguments": [], "name": "groupVolumeDown"}, "setGroupMute": {"arguments": [{"name": "state", "schema": {"$ref": "MuteState"}, "optional": false}], "name": "setGroupMute"}, "muteGroup": {"arguments": [], "name": "muteGroup"}, "unmuteGroup": {"arguments": [], "name": "unmuteGroup"}}, "id": "mediaGroup", "version": 1}]]
