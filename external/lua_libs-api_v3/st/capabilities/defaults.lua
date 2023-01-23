local capabilities = require "st.capabilities"

local capability_defaults = {}

--Table that maps each capability to its default attribute:
capability_defaults.default_attributes = {
  [capabilities.alarm.ID] = {
    [capabilities.alarm.alarm] = "off"
  },
  [capabilities.switch.ID] = {
    [capabilities.switch.switch] = "off"
  },
  [capabilities.switchLevel.ID] = {
    [capabilities.switchLevel.level] = 100
  },
  [capabilities.battery.ID] = {
    [capabilities.battery.battery] = 100
  },
  [capabilities.illuminanceMeasurement.ID] = {
    [capabilities.illuminanceMeasurement.illuminance] = { value = 0, unit = "lux" }
  },
  [capabilities.occupancySensor.ID] = {
    [capabilities.occupancySensor.occupancy] = "unoccupied"
  },
  [capabilities.temperatureMeasurement.ID] = {
    [capabilities.temperatureMeasurement.temperature] = { value = 0, unit = "C" }
  },
  [capabilities.relativeHumidityMeasurement.ID] = {
    [capabilities.relativeHumidityMeasurement.humidity] = 0
  },
  [capabilities.colorTemperature.ID] = {
    [capabilities.colorTemperature.colorTemperature] = 3000
  },
  [capabilities.colorControl.ID] = {
    [capabilities.colorControl.hue] = 0,
    [capabilities.colorControl.saturation] = 0
  },
  [capabilities.thermostatHeatingSetpoint.ID] = {
    [capabilities.thermostatHeatingSetpoint.heatingSetpoint] = { value = 0, unit = "C" }
  },
  [capabilities.thermostatCoolingSetpoint.ID] = {
    [capabilities.thermostatCoolingSetpoint.coolingSetpoint] = { value = 0, unit = "C" }
  },
  [capabilities.lock.ID] = {
    [capabilities.lock.lock] = "unknown"
  },
  [capabilities.powerMeter.ID] = {
    [capabilities.powerMeter.power] = { value = 0, unit = "W" }
  },
  [capabilities.energyMeter.ID] = {
    [capabilities.energyMeter.energy] = { value = 0, unit = "kWh" }
  },
  [capabilities.contactSensor.ID] = {
    [capabilities.contactSensor.contact] = "closed"
  },
  [capabilities.waterSensor.ID] = {
    [capabilities.waterSensor.water] = "dry"
  },
  [capabilities.motionSensor.ID] = {
    [capabilities.motionSensor.motion] = "inactive"
  },
  [capabilities.smokeDetector.ID] = {
    [capabilities.smokeDetector.smoke] = "clear"
  },
  [capabilities.valve.ID] = {
    [capabilities.valve.valve] = "open"
  },
  [capabilities.powerSource.ID] = {
    [capabilities.powerSource.powerSource] = "unknown"
  },
  [capabilities.windowShade.ID] = {
    [capabilities.windowShade.windowShade] = "unknown"
  },
  [capabilities.windowShadeLevel.ID] = {
    [capabilities.windowShadeLevel.shadeLevel] = 0
  },
  [capabilities.soundSensor.ID] = {
    [capabilities.soundSensor.sound] = "not detected"
  },
  [capabilities.carbonMonoxideDetector.ID] = {
    [capabilities.carbonMonoxideDetector.carbonMonoxide] = "clear"
  },
  [capabilities.button.ID] = {
    [capabilities.button.button] = "up"
  },
  [capabilities.tamperAlert.ID] = {
    [capabilities.tamperAlert.tamper] = "clear"
  },
  [capabilities.chime.ID] = {
    [capabilities.chime.chime] = "off"
  }
}

--Assigns the device's default capability attributes:
--Iterates throught all the supported capabilities of the device (ex. cap_defaults.emit_default_events(device, driver.supported_capabilities)
--If there is a default for that capability, then assign it to all the device components:
capability_defaults.emit_default_events = function(device, cap_list)
  if (cap_list ~= nil) then
    for _, capability in pairs(cap_list) do
      for attribute, value in pairs(capability_defaults.default_attributes[capability.ID]) do
        for _, component in pairs(device.profile.components) do
          if(device:supports_capability(capability, component.id)) then
            device:emit_component_event(component, attribute(value))
          end
        end
      end
    end
  end
end

return capability_defaults
