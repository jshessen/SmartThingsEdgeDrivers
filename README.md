# SmartThingsEdgeDrivers
---
An extension of the preliminary edge driver originally established by [ryanjmulder](https://community.smartthings.com/u/ryanjmulder) and forked from [his GitHub repo](https://github.com/ryanjmulder/smartthings-edge-drivers).

The goal of these drivers is to include the unique HomeSeer Z-Wave attributes not currently accounted for in the [SmartThingsCommunity/SmartThingsEdgeDrivers](https://github.com/SmartThingsCommunity/SmartThingsEdgeDrivers).


## Channel Invite:
HomeSeer Group = [https://bestow-regional.api.smartthings.com/invite/Kr2z1gQn3ZMA](https://bestow-regional.api.smartthings.com/invite/Kr2z1gQn3ZMA)

At the moment, these drivers are very much in **beta** and additional feature and functionality
## Current Drivers
### Category: Switch
- [HS-WS100+ Z-Wave Wall Switch](https://homeseer.com/wp-content/uploads/2020/09/HS-WS100-Manual-v7.pdf)
- [HS-WD100+ Z-Wave Wall Dimmer](https://homeseer.com/wp-content/uploads/2020/09/HS-WD100-Manual-7.pdf)
- [HS-WS200+ Z-Wave Wall Switch](https://homeseer.com/wp-content/uploads/2019/11/HS-WS200-Manual-v8a.pdf)
- [HS-WD200+ Z-Wave Wall Dimmer](https://homeseer.com/wp-content/uploads/2019/11/HS-WD200-Manual-6.pdf)
- [ZLink ZL-WS-100 Z-Wave Wall Switch](https://cdn.shopify.com/s/files/1/0067/9814/7669/files/ZL-WS-100_Users_Guide.pdf)
- [ZLink ZL-WD-100 Z-Wave Wall Dimmer](https://cdn.shopify.com/s/files/1/0067/9814/7669/files/ZL-WD-100_Users_Guide_480fe582-aca4-4693-8ae6-5f1b0ee74072.pdf)

### Category: Fan (not released)
- [HS-FC200+ Z-Wave Plus Fan Controller](https://homeseer.com/wp-content/uploads/2020/09/HS-FC200-Manual-4.pdf)


## Post Invite Activities

After accepting this channel invite and enrolling, any HomeSeer switches you add should automatically be assigned this Device Type Handler (DTH).

To see if a switch is using this device handler, go to Devices, open the switch and click the "..." button. If "Driver" is in the list, then it's using the new Edge Driver code. The driver name will be "HomeSeer Z-Wave Switches". If "Driver" is not present, it's using the legacy Groovy handler. In this case you should remove the device and re-add it.

# Removing the old handler

When removing the device via the SmartThings app, it will prompt you to follow your manufacturer's directions to unpair the old device. For all models the factory reset sequence is:

1) Turn the light on.
2) Quickly tap up 3 times
3) Quickly tap down 3 times

If it worked, it will turn the light off then back on again, and the remove operation will complete successfully in the SmartThings app.

Newer models like WX300 have a dedicated Z-Wave exclusion mode which you should use instead as it doesn't reset the switch wiring mode.

# Assigning multi-tap actions

To react to a multi-tap event, go to Automation and create a Routine. Under "If", choose "Device status", choose the switch and it should show all of the multi-tap events you can react to. Then you can add the result as normal for the routine.