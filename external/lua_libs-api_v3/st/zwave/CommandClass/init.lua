-- Copyright 2021 SmartThings
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
--- @class st.zwave.CommandClass.Params
--- @alias Params st.zwave.CommandClass.Params
--- @field public version number command class serialization version
--- @field public strict booelan if true, require explicit passing of all arguments to constructors
local Params = {}

return require "st.zwave.generated.cc"
