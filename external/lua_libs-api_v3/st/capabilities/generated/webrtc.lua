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

return [[{"name": "webrtc", "status": "live", "attributes": {"supportedFeatures": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "object", "additionalProperties": true, "properties": {"bundle": {"type": "boolean"}, "order": {"type": "string"}, "audio": {"type": "string"}, "video": {"type": "string"}}}}, "required": ["value"]}}, "audioOnly": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "boolean"}}, "required": ["value"]}}, "sdpAnswer": {"schema": {"type": "object", "properties": {"value": {"type": "object", "additionalProperties": false, "properties": {"id": {"type": "string"}, "sdp": {"type": "string"}, "turn_url": {"type": "string"}, "turn_user": {"type": "string"}, "turn_pwd": {"type": "string"}}, "required": ["id", "sdp"]}}, "additionalProperties": false, "required": ["value"]}}, "talkback": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "boolean"}}, "required": ["value"]}}, "stunUrl": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"title": "URL", "type": "string", "pattern": "^(stun?):((?:[a-zA-Z0-9.-]|%[0-9A-F]{2}){3,})(?::(\\d+))?((?:\\/(?:[a-zA-Z0-9-._~!$&'()*+,;=:@]|%[0-9A-F]{2})*)*)(?:\\?((?:[a-zA-Z0-9-._~!$&'()*+,;=:\\/?@]|%[0-9A-F]{2})*))?(?:#((?:[a-zA-Z0-9-._~!$&'()*+,;=:\\/?@]|%[0-9A-F]{2})*))?$"}}, "required": ["value"]}}}, "commands": {"sdpOffer": {"arguments": [{"name": "id", "schema": {"type": "string"}, "optional": false}, {"name": "sdp", "schema": {"type": "string"}, "optional": false}], "name": "sdpOffer"}, "end": {"arguments": [{"name": "id", "schema": {"type": "string"}, "optional": false}], "name": "end"}}, "id": "webrtc", "version": 1}]]
