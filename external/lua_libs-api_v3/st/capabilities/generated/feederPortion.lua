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

return [[{"name": "Feeder Portion", "status": "proposed", "attributes": {"feedPortion": {"schema": {"$ref": "FeedPortion"}, "setter": "setPortion"}}, "commands": {"setPortion": {"arguments": [{"name": "portion", "schema": {"title": "FeedPortion", "type": "number", "minimum": 0, "maximum": 2000}, "optional": false}, {"name": "unit", "schema": {"title": "unit", "type": "string", "enum": ["g", "lbs", "oz", "servings"], "default": "g"}, "optional": true}], "name": "setPortion"}}, "id": "feederPortion", "version": 1}]]
