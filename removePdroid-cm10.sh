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
pwd
cd ../../packages/apps/Mms
git clean -df
git reset --hard
cd ../../..
repo abandon pdroid

rm -rf out/target/common/obj/JAVA_LIBRARIES/core_intermediates
rm -rf out/target/common/obj/JAVA_LIBRARIES/framework_intermediates
rm -rf out/target/common/obj/JAVA_LIBRARIES/services_intermediates
rm -rf out/target/common/obj/JAVA_LIBRARIES/telephony-common_intermediates
rm -rf out/target/common/obj/APPS/Mms_intermediates
