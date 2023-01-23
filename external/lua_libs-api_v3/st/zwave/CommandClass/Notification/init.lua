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
local Notification = require "st.zwave.generated.Notification"
local zw = require "st.zwave"
local buf = require "st.zwave.utils.buf"

do
  local _set_reflectors = Notification.ReportV3.set_reflectors
  --- Set const reflectors in a v3 or forward-compatible v4,v5,v6,v7,v8
  --- NOTIFICATION_REPORT command, adding additional decode for field
  --- event_parameter.
  function Notification.ReportV3:set_reflectors()
    _set_reflectors(self)
    local args = self.args
    args._reflect = args._reflect or {}
    args._reflect.event_parameter = function()
      local reader = buf.Reader(args.event_parameter)
      local event_parameter = reader:remain() > 0 and reader:read_u8() or nil
      return zw._reflect(
        Notification._reflect_event_parameter,
        args.notification_type,
        args.event,
        event_parameter
      )
    end
  end
end

Notification.event_parameter = {
  access_control = {
    barrier_performing_initialization_process = {
      PROCESS_COMPLETED = 0x00,
      PERFORMING_PROCESS = 0xFF
    },
    barrier_vacation_mode = {
      MODE_DISABLED = 0x00,
      MODE_ENABLED = 0x01
    },
    barrier_safety_beam_obstacle = {
      NO_OBSTRUCTION = 0x00,
      OBSTRUCTION = 0xFF
    },
    barrier_sensor_not_detected_supervisory_error = {
      SENSOR_NOT_DEFINED = 0x00
    },
    barrier_sensor_low_battery_warning = {
      SENSOR_NOT_DEFINED = 0x00
    }
  },
  co = {
    carbon_monoxide_test = {
      TEST_OK = 0x01,
      TEST_FAILED = 0x02
    }
  },
  co2 = {
    carbon_dioxide_test = {
      TEST_OK = 0x01,
      TEST_FAILED = 0x02
    }
  },
  home_health = {
    volatile_organic_compound_level = {
      CLEAN = 0x01,
      SLIGHTLY_POLLUTED = 0x02,
      MODERATELY_POLLUTED = 0x03,
      HIGHLY_POLLUTED = 0x04
    },
    sleep_apnea_detected = {
      LOW_BREATH = 0x01,
      NO_BREATH_AT_ALL = 0x02
    }
  },
  water = {
    flow_alarm = {
      NO_DATA = 0x01,
      BELOW_LOW_THRESHOLD = 0x02,
      ABOVE_HIGH_THRESHOLD = 0x03,
      MAX = 0x04
    },
    pressure_alarm = {
      NO_DATA = 0x01,
      BELOW_LOW_THRESHOLD = 0x02,
      ABOVE_HIGH_THRESHOLD = 0x03,
      MAX = 0x04
    },
    temperature_alarm = {
      NO_DATA = 0x01,
      BELOW_LOW_THRESHOLD = 0x02,
      ABOVE_HIGH_THRESHOLD = 0x03
    },
    level_alarm = {
      NO_DATA = 0x01,
      BELOW_LOW_THRESHOLD = 0x02,
      ABOVE_HIGH_THRESHOLD = 0x03
    }
  },
  water_quality_monitoring = {
    chlorine_alarm = {
      BELOW_LOW_THRESHOLD = 0x01,
      ABOVE_HIGH_THRESHOLD = 0x02
    },
    acidity_ph_alarm = {
      BELOW_LOW_THRESHOLD = 0x01,
      ABOVE_HIGH_THRESHOLD = 0x02,
      DECREASING_PH = 0x03,
      INCREASING_PH = 0x04
    },
    water_oxidation_alarm = {
      BELOW_LOW_THRESHOLD = 0x01,
      ABOVE_HIGH_THRESHOLD = 0x02
    }
  },
  water_valve = {
    valve_operation = {
      OFF_CLOSED = 0x00,
      ON_OPEN = 0x01
    },
    master_valve_operation = {
      OFF_CLOSED = 0x00,
      ON_OPEN = 0x01
    },
    valve_current_alarm = {
      NO_DATA = 0x01,
      BELOW_LOW_THRESHOLD = 0x02,
      ABOVE_HIGH_THRESHOLD = 0x03,
      MAX = 0x04
    },
    master_valve_current_alarm = {
      NO_DATA = 0x01,
      BELOW_LOW_THRESHOLD = 0x02,
      ABOVE_HIGH_THRESHOLD = 0x03,
      MAX = 0x04
    }
  }
}
Notification._reflect_event_parameter = zw._reflection_builder(
  Notification.event_parameter, Notification.notification_type, Notification.event)

return Notification

