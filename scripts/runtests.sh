#!/bin/bash

$ANDROID_HOME/emulator/emulator -avd arm -wipe-data -writable-system -selinux disabled -no-audio -no-window -no-boot-anim -gpu off -verbose > /dev/null 2>&1 & ./waitfordevice.sh

./rootdevice.sh

./gradlew assembleDebug
./gradlew testDebugUnitTest
./gradlew connectedDebugAndroidTest

