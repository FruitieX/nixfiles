#!/usr/bin/env bash

# enable USB tethering on an unrooted Android phone

PHONE_PIN=$(cat ~/.phone_pin)

$ADB shell <<SCRIPT
SCREEN_STATE=\$(dumpsys nfc | grep 'mScreenState=')

# unlock screen if needed
if [ "\$SCREEN_STATE" != "mScreenState=ON_UNLOCKED" ]; then
  echo unlocking screen
  input tap 500 500 # tap anywhere to hide stupid charging overlay
  sleep 1
  input keyevent KEYCODE_MENU
  input text $PHONE_PIN
fi

echo opening usb tethering settings
am start -n com.android.settings/.TetherSettings > /dev/null 2>&1

echo closing usb permissions dialog
input tap 200 1280

# needs to be done in subshell because toggling USB tethering seems
# to kill adb connections for a while
(
  sleep .1
  echo tapping on back button
  input keyevent KEYCODE_BACK
) &

echo tapping on USB tethering
input tap 650 500
SCRIPT
