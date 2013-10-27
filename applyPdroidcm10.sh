#!/bin/bash

# Apply PDroid from build system Root.
cd ~/android/Open*
git checkout 4.1.2-cm

cd ~/android/system/jellybean/build; git checkout -b pdroid; patch -p1 < ~/android/Open*/openpdroid_4.1.2-cm_build.patch
cd ~/android/system/jellybean/libcore; git checkout -b pdroid; patch -p1 < ~/android/Open*/openpdroid_4.1.2-cm_libcore.patch
cd ~/android/system/jellybean/packages/apps/Mms; git checkout -b pdroid; patch -p1 < ~/android/Open*/openpdroid_4.1.2-cm_packages_apps_Mms.patch
cd ~/android/system/jellybean/frameworks/base; git checkout -b pdroid; patch -p1 < ~/android/Open*/openpdroid_4.1.2-cm_frameworks_base.patch
cd ~/android/system/jellybean; . build/envsetup.sh
