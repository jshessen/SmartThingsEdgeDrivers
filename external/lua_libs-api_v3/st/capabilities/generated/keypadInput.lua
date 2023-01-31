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

return [[{"name": "Keypad Input", "status": "proposed", "attributes": {"supportedKeyCodes": {"schema": {"type": "object", "properties": {"value": {"type": "array", "items": {"type": "string", "enum": ["UP", "DOWN", "LEFT", "RIGHT", "SELECT", "BACK", "EXIT", "MENU", "SETTINGS", "HOME", "NUMBER0", "NUMBER1", "NUMBER2", "NUMBER3", "NUMBER4", "NUMBER5", "NUMBER6", "NUMBER7", "NUMBER8", "NUMBER9"]}}}, "additionalProperties": false, "required": ["value"]}}}, "commands": {"sendKey": {"name": "sendKey", "arguments": [{"name": "keyCode", "schema": {"type": "string", "enum": ["UP", "DOWN", "LEFT", "RIGHT", "SELECT", "BACK", "EXIT", "MENU", "SETTINGS", "HOME", "NUMBER0", "NUMBER1", "NUMBER2", "NUMBER3", "NUMBER4", "NUMBER5", "NUMBER6", "NUMBER7", "NUMBER8", "NUMBER9"]}, "optional": false}]}}, "id": "keypadInput", "version": 1}]]
