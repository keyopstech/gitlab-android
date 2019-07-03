#! /bin/sh

./${ANDROID_HOME}/emulator/emulator-headless -avd device -memory 2096 -no-accel -gpu swiftshader_indirect -noaudio -no-window -no-boot-anim &

exec "$@"
