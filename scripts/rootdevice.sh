#!/bin/bash

# Restart adbd
adb root && adb remount

# Push and install su
adb push SuperSU/armv7/su /system/xbin/su
adb shell chmod 0755 /system
adb shell chmod 0755 /system/xbin/su

# Set SELinux permissive
adb shell setenforce 0

# Install su and run daemon
adb shell su --install
adb shell su --daemon&

