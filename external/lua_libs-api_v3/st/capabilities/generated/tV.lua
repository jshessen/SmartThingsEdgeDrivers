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

return [[{"name": "TV", "status": "live", "attributes": {"channel": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "PositiveInteger"}}}, "actedOnBy": ["channelDown", "channelUp"]}, "movieMode": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "String"}}}}, "picture": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "String"}}}}, "power": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "String"}}}}, "sound": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "String"}}}}, "volume": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "PositiveInteger"}}}, "actedOnBy": ["volumeDown", "volumeUp"]}}, "commands": {"channelDown": {"arguments": [], "name": "channelDown"}, "channelUp": {"arguments": [], "name": "channelUp"}, "volumeDown": {"arguments": [], "name": "volumeDown"}, "volumeUp": {"arguments": [], "name": "volumeUp"}}, "id": "tV", "version": 1}]]
