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

return [[{"name": "Wifi Mesh Router", "status": "proposed", "attributes": {"wifiNetworkName": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "String"}}, "required": ["value"]}}, "wifiGuestNetworkName": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "String"}}, "required": ["value"]}}, "connectedRouterCount": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "PositiveInteger"}}, "required": ["value"]}}, "disconnectedRouterCount": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "PositiveInteger"}}, "required": ["value"]}}, "connectedDeviceCount": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "PositiveInteger"}}, "required": ["value"]}}, "wifiNetworkStatus": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "WifiState"}}, "required": ["value"]}, "values": ["enabled", "disabled", "not configured"], "enumCommands": [{"command": "enableWifiNetwork", "value": "enabled"}, {"command": "disableWifiNetwork", "value": "disabled"}]}, "wifiGuestNetworkStatus": {"schema": {"type": "object", "additionalProperties": false, "properties": {"value": {"$ref": "WifiState"}}, "required": ["value"]}, "values": ["enabled", "disabled", "not configured"], "enumCommands": [{"command": "enableWifiGuestNetwork", "value": "enabled"}, {"command": "disableWifiGuestNetwork", "value": "disabled"}]}}, "commands": {"enableWifiNetwork": {"arguments": [], "name": "enableWifiNetwork"}, "disableWifiNetwork": {"arguments": [], "name": "disableWifiNetwork"}, "enableWifiGuestNetwork": {"arguments": [], "name": "enableWifiGuestNetwork"}, "disableWifiGuestNetwork": {"arguments": [], "name": "disableWifiGuestNetwork"}}, "id": "wifiMeshRouter", "version": 1}]]
