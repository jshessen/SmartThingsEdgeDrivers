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
os.__advance_time = function(time)
  assert(type(time) == "number", "time must be numeric")
  assert(time >= 0, "time must only increase")
  os.__mock_time = os.__mock_time + time
end

os.__set_time = function(value)
  os.__mock_time = value
end

os.time = function()
  return os.__mock_time
end
