#!/bin/bash

cd ~/android/system/jellybean/build
git reset --hard
git clean -df
cd ../libcore
git reset --hard
git clean -df
cd ../frameworks/base
git reset --hard
git clean -df
cd ../opt/telephony
git reset --hard
git clean -df
cd ../../../packages/apps/Mms
git reset --hard
git clean -df
cd ../../..
repo abandon pdroid
repo sync -l

rm -rf out/target/common/obj/JAVA_LIBRARIES/core_intermediates
rm -rf out/target/common/obj/JAVA_LIBRARIES/framework_intermediates
rm -rf out/target/common/obj/JAVA_LIBRARIES/services_intermediates
rm -rf out/target/common/obj/JAVA_LIBRARIES/telephony-common_intermediates
rm -rf out/target/common/obj/APPS/Mms_intermediates

# remove the lock and allow for future patching
LOCK=~/android/openpdroid/.pdroid-lock
rm -rf $LOCK && echo "Pdroid Lock removed."
