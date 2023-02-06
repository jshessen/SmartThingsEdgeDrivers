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

local types_mt = {}
types_mt.__types_cache = {}
types_mt.__index = function(self, key)
  if types_mt.__types_cache[key] == nil then
    local req_loc = string.format("st.matter.generated.zap_clusters.DoorLock.types.%s", key)
    local cluster_type = require(req_loc)
    types_mt.__types_cache[key] = cluster_type
  end
  return types_mt.__types_cache[key]
end

--- @class st.matter.generated.zap_clusters.DoorLockTypes
---
--- @field public DlAlarmCode st.matter.generated.zap_clusters.DoorLock.types.DlAlarmCode
--- @field public DlCredentialRule st.matter.generated.zap_clusters.DoorLock.types.DlCredentialRule
--- @field public DlCredentialType st.matter.generated.zap_clusters.DoorLock.types.DlCredentialType
--- @field public DlDataOperationType st.matter.generated.zap_clusters.DoorLock.types.DlDataOperationType
--- @field public DlDoorState st.matter.generated.zap_clusters.DoorLock.types.DlDoorState
--- @field public DlLockDataType st.matter.generated.zap_clusters.DoorLock.types.DlLockDataType
--- @field public DlLockOperationType st.matter.generated.zap_clusters.DoorLock.types.DlLockOperationType
--- @field public DlLockState st.matter.generated.zap_clusters.DoorLock.types.DlLockState
--- @field public DlLockType st.matter.generated.zap_clusters.DoorLock.types.DlLockType
--- @field public DlOperatingMode st.matter.generated.zap_clusters.DoorLock.types.DlOperatingMode
--- @field public DlOperationError st.matter.generated.zap_clusters.DoorLock.types.DlOperationError
--- @field public DlOperationSource st.matter.generated.zap_clusters.DoorLock.types.DlOperationSource
--- @field public DlStatus st.matter.generated.zap_clusters.DoorLock.types.DlStatus
--- @field public DlUserStatus st.matter.generated.zap_clusters.DoorLock.types.DlUserStatus
--- @field public DlUserType st.matter.generated.zap_clusters.DoorLock.types.DlUserType
--- @field public DoorLockOperationEventCode st.matter.generated.zap_clusters.DoorLock.types.DoorLockOperationEventCode
--- @field public DoorLockProgrammingEventCode st.matter.generated.zap_clusters.DoorLock.types.DoorLockProgrammingEventCode
--- @field public DoorLockSetPinOrIdStatus st.matter.generated.zap_clusters.DoorLock.types.DoorLockSetPinOrIdStatus
--- @field public DoorLockUserStatus st.matter.generated.zap_clusters.DoorLock.types.DoorLockUserStatus
--- @field public DoorLockUserType st.matter.generated.zap_clusters.DoorLock.types.DoorLockUserType

--- @field public DlCredentialRuleMask st.matter.generated.zap_clusters.DoorLock.types.DlCredentialRuleMask
--- @field public DlCredentialRulesSupport st.matter.generated.zap_clusters.DoorLock.types.DlCredentialRulesSupport
--- @field public DlDaysMaskMap st.matter.generated.zap_clusters.DoorLock.types.DlDaysMaskMap
--- @field public DlDefaultConfigurationRegister st.matter.generated.zap_clusters.DoorLock.types.DlDefaultConfigurationRegister
--- @field public DlKeypadOperationEventMask st.matter.generated.zap_clusters.DoorLock.types.DlKeypadOperationEventMask
--- @field public DlKeypadProgrammingEventMask st.matter.generated.zap_clusters.DoorLock.types.DlKeypadProgrammingEventMask
--- @field public DlLocalProgrammingFeatures st.matter.generated.zap_clusters.DoorLock.types.DlLocalProgrammingFeatures
--- @field public DlManualOperationEventMask st.matter.generated.zap_clusters.DoorLock.types.DlManualOperationEventMask
--- @field public DlRFIDOperationEventMask st.matter.generated.zap_clusters.DoorLock.types.DlRFIDOperationEventMask
--- @field public DlRFIDProgrammingEventMask st.matter.generated.zap_clusters.DoorLock.types.DlRFIDProgrammingEventMask
--- @field public DlRemoteOperationEventMask st.matter.generated.zap_clusters.DoorLock.types.DlRemoteOperationEventMask
--- @field public DlRemoteProgrammingEventMask st.matter.generated.zap_clusters.DoorLock.types.DlRemoteProgrammingEventMask
--- @field public DlSupportedOperatingModes st.matter.generated.zap_clusters.DoorLock.types.DlSupportedOperatingModes
--- @field public DoorLockDayOfWeek st.matter.generated.zap_clusters.DoorLock.types.DoorLockDayOfWeek
--- @field public DoorLockFeature st.matter.generated.zap_clusters.DoorLock.types.DoorLockFeature
local DoorLockTypes = {}

setmetatable(DoorLockTypes, types_mt)

return DoorLockTypes
