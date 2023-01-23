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

return [[{"name": "Button", "status": "live", "attributes": {"button": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "ButtonState"}}, "required": ["value"]}, "values": ["pushed", "held", "double", "pushed_2x", "pushed_3x", "pushed_4x", "pushed_5x", "pushed_6x", "down", "down_2x", "down_3x", "down_4x", "down_5x", "down_6x", "down_hold", "up", "up_2x", "up_3x", "up_4x", "up_5x", "up_6x", "up_hold", "swipe_up", "swipe_down", "swipe_left", "swipe_right"]}, "numberOfButtons": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "PositiveInteger"}}, "required": ["value"]}}, "supportedButtonValues": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"type": "array", "items": {"$ref": "ButtonState"}}}}}}, "commands": {}, "id": "button", "version": 1}]]
