#This file is derived from https://cs.android.com/android/platform/superproject/+/android-latest-release:device/generic/car/emulator/multi-display/input/virtio_input_multi_touch_9.idc
#which is under Apache 2.0 license.

device.internal = 0

touch.deviceType = touchScreen
touch.orientationAware = 1

cursor.mode = navigation
cursor.orientationAware = 1

# This displayID matches the unique ID of the display created for device.
# This will indicate to input flinger than it should link this input device
# with the  display.
touch.displayId = local:4630946780669082115

# Allow touches while the screen is off
touch.enableForInactiveViewport = 1

# Tap on the display will wake the device.
touch.wake = 1

