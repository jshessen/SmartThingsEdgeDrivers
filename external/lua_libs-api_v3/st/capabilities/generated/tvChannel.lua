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

return [[{"name": "Tv Channel", "status": "proposed", "attributes": {"tvChannel": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "String"}}}, "setter": "setTvChannel", "actedOnBy": ["channelDown", "channelUp"]}, "tvChannelName": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "String"}}}, "setter": "setTvChannelName"}}, "commands": {"setTvChannel": {"arguments": [{"name": "tvChannel", "schema": {"$ref": "String"}, "optional": false}], "name": "setTvChannel"}, "channelUp": {"arguments": [], "name": "channelUp"}, "channelDown": {"arguments": [], "name": "channelDown"}, "setTvChannelName": {"arguments": [{"name": "tvChannelName", "schema": {"$ref": "String"}, "optional": true}], "name": "setTvChannelName"}}, "id": "tvChannel", "version": 1}]]
