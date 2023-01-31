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

local data_types = require "st.matter.data_types"
local UintABC = require "st.matter.data_types.base_defs.UintABC"

--- @class st.matter.clusters.KeypadInput.types.CecKeyCode: st.matter.data_types.Uint8
--- @alias CecKeyCode
---
--- @field public byte_length number 1
--- @field public SELECT number 0
--- @field public UP number 1
--- @field public DOWN number 2
--- @field public LEFT number 3
--- @field public RIGHT number 4
--- @field public RIGHT_UP number 5
--- @field public RIGHT_DOWN number 6
--- @field public LEFT_UP number 7
--- @field public LEFT_DOWN number 8
--- @field public ROOT_MENU number 9
--- @field public SETUP_MENU number 10
--- @field public CONTENTS_MENU number 11
--- @field public FAVORITE_MENU number 12
--- @field public EXIT number 13
--- @field public MEDIA_TOP_MENU number 16
--- @field public MEDIA_CONTEXT_SENSITIVE_MENU number 17
--- @field public NUMBER_ENTRY_MODE number 29
--- @field public NUMBER11 number 30
--- @field public NUMBER12 number 31
--- @field public NUMBER0_OR_NUMBER10 number 32
--- @field public NUMBERS1 number 33
--- @field public NUMBERS2 number 34
--- @field public NUMBERS3 number 35
--- @field public NUMBERS4 number 36
--- @field public NUMBERS5 number 37
--- @field public NUMBERS6 number 38
--- @field public NUMBERS7 number 39
--- @field public NUMBERS8 number 40
--- @field public NUMBERS9 number 41
--- @field public DOT number 42
--- @field public ENTER number 43
--- @field public CLEAR number 44
--- @field public NEXT_FAVORITE number 47
--- @field public CHANNEL_UP number 48
--- @field public CHANNEL_DOWN number 49
--- @field public PREVIOUS_CHANNEL number 50
--- @field public SOUND_SELECT number 51
--- @field public INPUT_SELECT number 52
--- @field public DISPLAY_INFORMATION number 53
--- @field public HELP number 54
--- @field public PAGE_UP number 55
--- @field public PAGE_DOWN number 56
--- @field public POWER number 64
--- @field public VOLUME_UP number 65
--- @field public VOLUME_DOWN number 66
--- @field public MUTE number 67
--- @field public PLAY number 68
--- @field public STOP number 69
--- @field public PAUSE number 70
--- @field public RECORD number 71
--- @field public REWIND number 72
--- @field public FAST_FORWARD number 73
--- @field public EJECT number 74
--- @field public FORWARD number 75
--- @field public BACKWARD number 76
--- @field public STOP_RECORD number 77
--- @field public PAUSE_RECORD number 78
--- @field public RESERVED number 79
--- @field public ANGLE number 80
--- @field public SUB_PICTURE number 81
--- @field public VIDEO_ON_DEMAND number 82
--- @field public ELECTRONIC_PROGRAM_GUIDE number 83
--- @field public TIMER_PROGRAMMING number 84
--- @field public INITIAL_CONFIGURATION number 85
--- @field public SELECT_BROADCAST_TYPE number 86
--- @field public SELECT_SOUND_PRESENTATION number 87
--- @field public PLAY_FUNCTION number 96
--- @field public PAUSE_PLAY_FUNCTION number 97
--- @field public RECORD_FUNCTION number 98
--- @field public PAUSE_RECORD_FUNCTION number 99
--- @field public STOP_FUNCTION number 100
--- @field public MUTE_FUNCTION number 101
--- @field public RESTORE_VOLUME_FUNCTION number 102
--- @field public TUNE_FUNCTION number 103
--- @field public SELECT_MEDIA_FUNCTION number 104
--- @field public SELECT_AV_INPUT_FUNCTION number 105
--- @field public SELECT_AUDIO_INPUT_FUNCTION number 106
--- @field public POWER_TOGGLE_FUNCTION number 107
--- @field public POWER_OFF_FUNCTION number 108
--- @field public POWER_ON_FUNCTION number 109
--- @field public F1_BLUE number 113
--- @field public F2_RED number 114
--- @field public F3_GREEN number 115
--- @field public F4_YELLOW number 116
--- @field public F5 number 117
--- @field public DATA number 118

local CecKeyCode = {}
local new_mt = UintABC.new_mt({NAME = "CecKeyCode", ID = data_types.name_to_id_map["Uint8"]}, 1)
new_mt.__index.pretty_print = function(self)
  local name_lookup = {
    [self.SELECT] = "SELECT",
    [self.UP] = "UP",
    [self.DOWN] = "DOWN",
    [self.LEFT] = "LEFT",
    [self.RIGHT] = "RIGHT",
    [self.RIGHT_UP] = "RIGHT_UP",
    [self.RIGHT_DOWN] = "RIGHT_DOWN",
    [self.LEFT_UP] = "LEFT_UP",
    [self.LEFT_DOWN] = "LEFT_DOWN",
    [self.ROOT_MENU] = "ROOT_MENU",
    [self.SETUP_MENU] = "SETUP_MENU",
    [self.CONTENTS_MENU] = "CONTENTS_MENU",
    [self.FAVORITE_MENU] = "FAVORITE_MENU",
    [self.EXIT] = "EXIT",
    [self.MEDIA_TOP_MENU] = "MEDIA_TOP_MENU",
    [self.MEDIA_CONTEXT_SENSITIVE_MENU] = "MEDIA_CONTEXT_SENSITIVE_MENU",
    [self.NUMBER_ENTRY_MODE] = "NUMBER_ENTRY_MODE",
    [self.NUMBER11] = "NUMBER11",
    [self.NUMBER12] = "NUMBER12",
    [self.NUMBER0_OR_NUMBER10] = "NUMBER0_OR_NUMBER10",
    [self.NUMBERS1] = "NUMBERS1",
    [self.NUMBERS2] = "NUMBERS2",
    [self.NUMBERS3] = "NUMBERS3",
    [self.NUMBERS4] = "NUMBERS4",
    [self.NUMBERS5] = "NUMBERS5",
    [self.NUMBERS6] = "NUMBERS6",
    [self.NUMBERS7] = "NUMBERS7",
    [self.NUMBERS8] = "NUMBERS8",
    [self.NUMBERS9] = "NUMBERS9",
    [self.DOT] = "DOT",
    [self.ENTER] = "ENTER",
    [self.CLEAR] = "CLEAR",
    [self.NEXT_FAVORITE] = "NEXT_FAVORITE",
    [self.CHANNEL_UP] = "CHANNEL_UP",
    [self.CHANNEL_DOWN] = "CHANNEL_DOWN",
    [self.PREVIOUS_CHANNEL] = "PREVIOUS_CHANNEL",
    [self.SOUND_SELECT] = "SOUND_SELECT",
    [self.INPUT_SELECT] = "INPUT_SELECT",
    [self.DISPLAY_INFORMATION] = "DISPLAY_INFORMATION",
    [self.HELP] = "HELP",
    [self.PAGE_UP] = "PAGE_UP",
    [self.PAGE_DOWN] = "PAGE_DOWN",
    [self.POWER] = "POWER",
    [self.VOLUME_UP] = "VOLUME_UP",
    [self.VOLUME_DOWN] = "VOLUME_DOWN",
    [self.MUTE] = "MUTE",
    [self.PLAY] = "PLAY",
    [self.STOP] = "STOP",
    [self.PAUSE] = "PAUSE",
    [self.RECORD] = "RECORD",
    [self.REWIND] = "REWIND",
    [self.FAST_FORWARD] = "FAST_FORWARD",
    [self.EJECT] = "EJECT",
    [self.FORWARD] = "FORWARD",
    [self.BACKWARD] = "BACKWARD",
    [self.STOP_RECORD] = "STOP_RECORD",
    [self.PAUSE_RECORD] = "PAUSE_RECORD",
    [self.RESERVED] = "RESERVED",
    [self.ANGLE] = "ANGLE",
    [self.SUB_PICTURE] = "SUB_PICTURE",
    [self.VIDEO_ON_DEMAND] = "VIDEO_ON_DEMAND",
    [self.ELECTRONIC_PROGRAM_GUIDE] = "ELECTRONIC_PROGRAM_GUIDE",
    [self.TIMER_PROGRAMMING] = "TIMER_PROGRAMMING",
    [self.INITIAL_CONFIGURATION] = "INITIAL_CONFIGURATION",
    [self.SELECT_BROADCAST_TYPE] = "SELECT_BROADCAST_TYPE",
    [self.SELECT_SOUND_PRESENTATION] = "SELECT_SOUND_PRESENTATION",
    [self.PLAY_FUNCTION] = "PLAY_FUNCTION",
    [self.PAUSE_PLAY_FUNCTION] = "PAUSE_PLAY_FUNCTION",
    [self.RECORD_FUNCTION] = "RECORD_FUNCTION",
    [self.PAUSE_RECORD_FUNCTION] = "PAUSE_RECORD_FUNCTION",
    [self.STOP_FUNCTION] = "STOP_FUNCTION",
    [self.MUTE_FUNCTION] = "MUTE_FUNCTION",
    [self.RESTORE_VOLUME_FUNCTION] = "RESTORE_VOLUME_FUNCTION",
    [self.TUNE_FUNCTION] = "TUNE_FUNCTION",
    [self.SELECT_MEDIA_FUNCTION] = "SELECT_MEDIA_FUNCTION",
    [self.SELECT_AV_INPUT_FUNCTION] = "SELECT_AV_INPUT_FUNCTION",
    [self.SELECT_AUDIO_INPUT_FUNCTION] = "SELECT_AUDIO_INPUT_FUNCTION",
    [self.POWER_TOGGLE_FUNCTION] = "POWER_TOGGLE_FUNCTION",
    [self.POWER_OFF_FUNCTION] = "POWER_OFF_FUNCTION",
    [self.POWER_ON_FUNCTION] = "POWER_ON_FUNCTION",
    [self.F1_BLUE] = "F1_BLUE",
    [self.F2_RED] = "F2_RED",
    [self.F3_GREEN] = "F3_GREEN",
    [self.F4_YELLOW] = "F4_YELLOW",
    [self.F5] = "F5",
    [self.DATA] = "DATA",
  }
  return string.format("%s: %s", self.field_name or self.NAME, name_lookup[self.value] or string.format("%d", self.value))
end
new_mt.__tostring = new_mt.__index.pretty_print

new_mt.__index.SELECT  = 0x00
new_mt.__index.UP  = 0x01
new_mt.__index.DOWN  = 0x02
new_mt.__index.LEFT  = 0x03
new_mt.__index.RIGHT  = 0x04
new_mt.__index.RIGHT_UP  = 0x05
new_mt.__index.RIGHT_DOWN  = 0x06
new_mt.__index.LEFT_UP  = 0x07
new_mt.__index.LEFT_DOWN  = 0x08
new_mt.__index.ROOT_MENU  = 0x09
new_mt.__index.SETUP_MENU  = 0x0A
new_mt.__index.CONTENTS_MENU  = 0x0B
new_mt.__index.FAVORITE_MENU  = 0x0C
new_mt.__index.EXIT  = 0x0D
new_mt.__index.MEDIA_TOP_MENU  = 0x10
new_mt.__index.MEDIA_CONTEXT_SENSITIVE_MENU  = 0x11
new_mt.__index.NUMBER_ENTRY_MODE  = 0x1D
new_mt.__index.NUMBER11  = 0x1E
new_mt.__index.NUMBER12  = 0x1F
new_mt.__index.NUMBER0_OR_NUMBER10  = 0x20
new_mt.__index.NUMBERS1  = 0x21
new_mt.__index.NUMBERS2  = 0x22
new_mt.__index.NUMBERS3  = 0x23
new_mt.__index.NUMBERS4  = 0x24
new_mt.__index.NUMBERS5  = 0x25
new_mt.__index.NUMBERS6  = 0x26
new_mt.__index.NUMBERS7  = 0x27
new_mt.__index.NUMBERS8  = 0x28
new_mt.__index.NUMBERS9  = 0x29
new_mt.__index.DOT  = 0x2A
new_mt.__index.ENTER  = 0x2B
new_mt.__index.CLEAR  = 0x2C
new_mt.__index.NEXT_FAVORITE  = 0x2F
new_mt.__index.CHANNEL_UP  = 0x30
new_mt.__index.CHANNEL_DOWN  = 0x31
new_mt.__index.PREVIOUS_CHANNEL  = 0x32
new_mt.__index.SOUND_SELECT  = 0x33
new_mt.__index.INPUT_SELECT  = 0x34
new_mt.__index.DISPLAY_INFORMATION  = 0x35
new_mt.__index.HELP  = 0x36
new_mt.__index.PAGE_UP  = 0x37
new_mt.__index.PAGE_DOWN  = 0x38
new_mt.__index.POWER  = 0x40
new_mt.__index.VOLUME_UP  = 0x41
new_mt.__index.VOLUME_DOWN  = 0x42
new_mt.__index.MUTE  = 0x43
new_mt.__index.PLAY  = 0x44
new_mt.__index.STOP  = 0x45
new_mt.__index.PAUSE  = 0x46
new_mt.__index.RECORD  = 0x47
new_mt.__index.REWIND  = 0x48
new_mt.__index.FAST_FORWARD  = 0x49
new_mt.__index.EJECT  = 0x4A
new_mt.__index.FORWARD  = 0x4B
new_mt.__index.BACKWARD  = 0x4C
new_mt.__index.STOP_RECORD  = 0x4D
new_mt.__index.PAUSE_RECORD  = 0x4E
new_mt.__index.RESERVED  = 0x4F
new_mt.__index.ANGLE  = 0x50
new_mt.__index.SUB_PICTURE  = 0x51
new_mt.__index.VIDEO_ON_DEMAND  = 0x52
new_mt.__index.ELECTRONIC_PROGRAM_GUIDE  = 0x53
new_mt.__index.TIMER_PROGRAMMING  = 0x54
new_mt.__index.INITIAL_CONFIGURATION  = 0x55
new_mt.__index.SELECT_BROADCAST_TYPE  = 0x56
new_mt.__index.SELECT_SOUND_PRESENTATION  = 0x57
new_mt.__index.PLAY_FUNCTION  = 0x60
new_mt.__index.PAUSE_PLAY_FUNCTION  = 0x61
new_mt.__index.RECORD_FUNCTION  = 0x62
new_mt.__index.PAUSE_RECORD_FUNCTION  = 0x63
new_mt.__index.STOP_FUNCTION  = 0x64
new_mt.__index.MUTE_FUNCTION  = 0x65
new_mt.__index.RESTORE_VOLUME_FUNCTION  = 0x66
new_mt.__index.TUNE_FUNCTION  = 0x67
new_mt.__index.SELECT_MEDIA_FUNCTION  = 0x68
new_mt.__index.SELECT_AV_INPUT_FUNCTION  = 0x69
new_mt.__index.SELECT_AUDIO_INPUT_FUNCTION  = 0x6A
new_mt.__index.POWER_TOGGLE_FUNCTION  = 0x6B
new_mt.__index.POWER_OFF_FUNCTION  = 0x6C
new_mt.__index.POWER_ON_FUNCTION  = 0x6D
new_mt.__index.F1_BLUE  = 0x71
new_mt.__index.F2_RED  = 0x72
new_mt.__index.F3_GREEN  = 0x73
new_mt.__index.F4_YELLOW  = 0x74
new_mt.__index.F5  = 0x75
new_mt.__index.DATA  = 0x76

CecKeyCode.augment_type = function(cls, val)
  setmetatable(val, new_mt)
end

setmetatable(CecKeyCode, new_mt)

return CecKeyCode
