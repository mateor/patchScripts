#!/bin/bash

# Apply PDroid from build system Root.

LOCK=~/android/openpdroid/.pdroid-lock

if [ -f "$LOCK" ]; then
    echo ""
    echo "Pdroid patches are already applied."
    echo "   removePdroid.sh should be ran to remov the lock at $LOCK"
    echo ""
    exit
fi

#TODO I should change this to provide a message and fail if patch fails.
cd ~/android/Open*
git checkout 4.3

cd ~/android/system/jellybean/build; git checkout -b pdroid; patch -p1 < ~/android/Open*/openpdroid_4.3_build.patch
cd ~/android/system/jellybean/libcore; git checkout -b pdroid; patch -p1 < ~/android/Open*/openpdroid_4.3_libcore.patch
cd ~/android/system/jellybean/packages/apps/Mms; git checkout -b pdroid; patch -p1 < ~/android/Open*/openpdroid_4.3_packages_apps_Mms.patch
cd ~/android/system/jellybean/frameworks/base; git checkout -b pdroid; patch -p1 < ~/android/Open*/openpdroid_4.3_frameworks_base.patch
cd ~/android/system/jellybean/frameworks/opt/telephony; git checkout -b pdroid; patch -p1 < ~/android/Open*/openpdroid_4.3_frameworks_opt_telephony.patch
cd ~/android/system/jellybean; . build/envsetup.sh

# to determine if Pdroid patches are applied or not
touch $LOCK
