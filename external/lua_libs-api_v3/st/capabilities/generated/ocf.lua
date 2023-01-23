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

return [[{"id": "ocf", "name": "Ocf", "status": "proposed", "attributes": {"n": {"schema": {"$ref": "StringAttribute"}, "actedOnBy": ["postOcfCommand"]}, "icv": {"schema": {"$ref": "StringAttribute"}, "actedOnBy": ["postOcfCommand"]}, "dmv": {"schema": {"$ref": "StringAttribute"}, "actedOnBy": ["postOcfCommand"]}, "di": {"schema": {"$ref": "StringAttribute"}, "actedOnBy": ["postOcfCommand"]}, "pi": {"schema": {"$ref": "StringAttribute"}, "actedOnBy": ["postOcfCommand"]}, "mnmn": {"schema": {"$ref": "StringAttribute"}, "actedOnBy": ["postOcfCommand"]}, "mnml": {"schema": {"$ref": "StringAttribute"}, "actedOnBy": ["postOcfCommand"]}, "mnmo": {"schema": {"$ref": "StringAttribute"}, "actedOnBy": ["postOcfCommand"]}, "mndt": {"schema": {"$ref": "StringAttribute"}, "actedOnBy": ["postOcfCommand"]}, "mnpv": {"schema": {"$ref": "StringAttribute"}, "actedOnBy": ["postOcfCommand"]}, "mnos": {"schema": {"$ref": "StringAttribute"}, "actedOnBy": ["postOcfCommand"]}, "mnhw": {"schema": {"$ref": "StringAttribute"}, "actedOnBy": ["postOcfCommand"]}, "mnfv": {"schema": {"$ref": "StringAttribute"}, "actedOnBy": ["postOcfCommand"]}, "mnsl": {"schema": {"$ref": "StringAttribute"}, "actedOnBy": ["postOcfCommand"]}, "st": {"schema": {"$ref": "StringAttribute"}, "actedOnBy": ["postOcfCommand"]}, "vid": {"schema": {"$ref": "StringAttribute"}, "actedOnBy": ["postOcfCommand"]}}, "commands": {"postOcfCommand": {"arguments": [{"name": "href", "schema": {"$ref": "String"}, "optional": false}, {"name": "value", "schema": {"$ref": "JsonObject"}, "optional": false}], "name": "postOcfCommand"}}, "version": 1}]]
