# SmartThingsEdgeDrivers
---
An extension of the preliminary edge driver originally established by [ryanjmulder](https://community.smartthings.com/u/ryanjmulder) and forked from [his GitHub repo](https://github.com/ryanjmulder/smartthings-edge-drivers).

The goal of these drivers is to include the unique HomeSeer Z-Wave attributes not currently accounted for in the [SmartThingsCommunity/SmartThingsEdgeDrivers](https://github.com/SmartThingsCommunity/SmartThingsEdgeDrivers).


## Channel Invite:
HomeSeer Group = [https://bestow-regional.api.smartthings.com/invite/Kr2z1gQn3ZMA](https://bestow-regional.api.smartthings.com/invite/Kr2z1gQn3ZMA)

The Switch capabilities are rather feature complete, however, the remaing drivers are very much in **beta** regarding additional feature and functionality
## Current Drivers
### Category: Switches
- [HS-WS100+ Z-Wave Wall Switch](https://homeseer.com/wp-content/uploads/2020/09/HS-WS100-Manual-v7.pdf)
- [HS-WD100+ Z-Wave Wall Dimmer](https://docs.homeseer.com/products/lighting/legacy-lighting/hs-wd100+)
- [HS-WS200+ Z-Wave Wall Switch](https://docs.homeseer.com/products/lighting/legacy-lighting/hs-ws200+)
- [HS-WD200+ Z-Wave Wall Dimmer](https://docs.homeseer.com/products/lighting/legacy-lighting/hs-wd200+)
- [HS-WX300 Z-Wave Wall Dimmer](https://docs.homeseer.com/products/lighting/hs-wx300/)
- [ZLink ZL-WS-100 Z-Wave Wall Switch](https://cdn.shopify.com/s/files/1/0067/9814/7669/files/ZL-WS-100_Users_Guide.pdf)
- [ZLink ZL-WD-100 Z-Wave Wall Dimmer](https://cdn.shopify.com/s/files/1/0067/9814/7669/files/ZL-WD-100_Users_Guide_480fe582-aca4-4693-8ae6-5f1b0ee74072.pdf)

    #### Switch Capabilities
    The following capabilities are available:
    - Mult-Tap Functionality (Central Scene)
    - Multiple Profile Configuration (Driven by device Firmware version and/or Normal vs. Status Operating Mode)
    - LED Control (Status Mode)
        - Color Configuration - Although HomeSeer only supports 7 colors (Red/Green/Blue/Yellow/Magenta/Cyan/White), the driver supports HSL definitions and will select the closest color.
        - Blink Notification

        <span style="color:red">**LED Color Control is best managed via Routines and/or Rules API.  Smart Lighting is not currently working correctly with components**</span>

### Category: Fan Controllers (beta)
- [HS-FC200+ Z-Wave Plus Fan Controller](https://docs.homeseer.com/products/lighting/legacy-lighting/hs-fc200+)
    #### Switch Capabilities
    Eventually this should emulate the functionality of the common year switch models.
### Category: Sensors (beta)
- [HSM200 Multi-sensor](https://docs.homeseer.com/products/sensors/hsm200)
    #### Switch Capabilities
    Work In Progress

---

## Post Invite Activities

After accepting this channel invite and enrolling, any HomeSeer switches you add should automatically be assigned this Edge Driver.

To see if a switch is using this device driver, go to Devices, open the switch and click the "..." button. If "Driver" is in the list, then it's using the new Edge Driver code. The driver name will be "HomeSeer Z-Wave Switches". If "Driver" is not present, it's using the legacy Groovy Device Type Handler (DTH). In this case you should remove the device and re-add it.

### Removing the old handler

When removing the device via the SmartThings app, it will prompt you to follow your manufacturer's directions to exclude the old device. Once the exclusion process is started by the app, single click and release the rocker switch.

## Assigning multi-tap actions

To react to a multi-tap event, go to Automation and create a Routine. Under "If", choose "Device status", choose the switch and it should show all of the multi-tap events you can react to. Then you can add the result as normal for the routine.
