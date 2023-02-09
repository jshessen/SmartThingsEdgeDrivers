-- Copyright 2022 SmartThings
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

-- DO NOT EDIT: this code is automatically generated by ZCL Advanced Platform generator.

local attr_mt = {}
attr_mt.__attr_cache = {}
attr_mt.__index = function(self, key)
  if attr_mt.__attr_cache[key] == nil then
    local req_loc = string.format("st.matter.generated.zap_clusters.DoorLock.server.attributes.%s", key)
    local raw_def = require(req_loc)
    local cluster = rawget(self, "_cluster")
    raw_def:set_parent_cluster(cluster)
    attr_mt.__attr_cache[key] = raw_def
  end
  return attr_mt.__attr_cache[key]
end

--- @class st.matter.generated.zap_clusters.DoorLockServerAttributes
---
--- @field public LockState st.matter.generated.zap_clusters.DoorLock.server.attributes.LockState
--- @field public LockType st.matter.generated.zap_clusters.DoorLock.server.attributes.LockType
--- @field public ActuatorEnabled st.matter.generated.zap_clusters.DoorLock.server.attributes.ActuatorEnabled
--- @field public DoorState st.matter.generated.zap_clusters.DoorLock.server.attributes.DoorState
--- @field public DoorOpenEvents st.matter.generated.zap_clusters.DoorLock.server.attributes.DoorOpenEvents
--- @field public DoorClosedEvents st.matter.generated.zap_clusters.DoorLock.server.attributes.DoorClosedEvents
--- @field public OpenPeriod st.matter.generated.zap_clusters.DoorLock.server.attributes.OpenPeriod
--- @field public NumberOfTotalUsersSupported st.matter.generated.zap_clusters.DoorLock.server.attributes.NumberOfTotalUsersSupported
--- @field public NumberOfPINUsersSupported st.matter.generated.zap_clusters.DoorLock.server.attributes.NumberOfPINUsersSupported
--- @field public NumberOfRFIDUsersSupported st.matter.generated.zap_clusters.DoorLock.server.attributes.NumberOfRFIDUsersSupported
--- @field public NumberOfWeekDaySchedulesSupportedPerUser st.matter.generated.zap_clusters.DoorLock.server.attributes.NumberOfWeekDaySchedulesSupportedPerUser
--- @field public NumberOfYearDaySchedulesSupportedPerUser st.matter.generated.zap_clusters.DoorLock.server.attributes.NumberOfYearDaySchedulesSupportedPerUser
--- @field public NumberOfHolidaySchedulesSupported st.matter.generated.zap_clusters.DoorLock.server.attributes.NumberOfHolidaySchedulesSupported
--- @field public MaxPINCodeLength st.matter.generated.zap_clusters.DoorLock.server.attributes.MaxPINCodeLength
--- @field public MinPINCodeLength st.matter.generated.zap_clusters.DoorLock.server.attributes.MinPINCodeLength
--- @field public MaxRFIDCodeLength st.matter.generated.zap_clusters.DoorLock.server.attributes.MaxRFIDCodeLength
--- @field public MinRFIDCodeLength st.matter.generated.zap_clusters.DoorLock.server.attributes.MinRFIDCodeLength
--- @field public CredentialRulesSupport st.matter.generated.zap_clusters.DoorLock.server.attributes.CredentialRulesSupport
--- @field public NumberOfCredentialsSupportedPerUser st.matter.generated.zap_clusters.DoorLock.server.attributes.NumberOfCredentialsSupportedPerUser
--- @field public Language st.matter.generated.zap_clusters.DoorLock.server.attributes.Language
--- @field public LEDSettings st.matter.generated.zap_clusters.DoorLock.server.attributes.LEDSettings
--- @field public AutoRelockTime st.matter.generated.zap_clusters.DoorLock.server.attributes.AutoRelockTime
--- @field public SoundVolume st.matter.generated.zap_clusters.DoorLock.server.attributes.SoundVolume
--- @field public OperatingMode st.matter.generated.zap_clusters.DoorLock.server.attributes.OperatingMode
--- @field public SupportedOperatingModes st.matter.generated.zap_clusters.DoorLock.server.attributes.SupportedOperatingModes
--- @field public DefaultConfigurationRegister st.matter.generated.zap_clusters.DoorLock.server.attributes.DefaultConfigurationRegister
--- @field public EnableLocalProgramming st.matter.generated.zap_clusters.DoorLock.server.attributes.EnableLocalProgramming
--- @field public EnableOneTouchLocking st.matter.generated.zap_clusters.DoorLock.server.attributes.EnableOneTouchLocking
--- @field public EnableInsideStatusLED st.matter.generated.zap_clusters.DoorLock.server.attributes.EnableInsideStatusLED
--- @field public EnablePrivacyModeButton st.matter.generated.zap_clusters.DoorLock.server.attributes.EnablePrivacyModeButton
--- @field public LocalProgrammingFeatures st.matter.generated.zap_clusters.DoorLock.server.attributes.LocalProgrammingFeatures
--- @field public WrongCodeEntryLimit st.matter.generated.zap_clusters.DoorLock.server.attributes.WrongCodeEntryLimit
--- @field public UserCodeTemporaryDisableTime st.matter.generated.zap_clusters.DoorLock.server.attributes.UserCodeTemporaryDisableTime
--- @field public SendPINOverTheAir st.matter.generated.zap_clusters.DoorLock.server.attributes.SendPINOverTheAir
--- @field public RequirePINforRemoteOperation st.matter.generated.zap_clusters.DoorLock.server.attributes.RequirePINforRemoteOperation
--- @field public ExpiringUserTimeout st.matter.generated.zap_clusters.DoorLock.server.attributes.ExpiringUserTimeout
--- @field public AcceptedCommandList st.matter.generated.zap_clusters.DoorLock.server.attributes.AcceptedCommandList
--- @field public AttributeList st.matter.generated.zap_clusters.DoorLock.server.attributes.AttributeList
local DoorLockServerAttributes = {}

function DoorLockServerAttributes:set_parent_cluster(cluster)
  self._cluster = cluster
  return self
end

setmetatable(DoorLockServerAttributes, attr_mt)

return DoorLockServerAttributes
