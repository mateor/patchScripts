#!/bin/bash

# The MIT License (MIT)
#
# Copyright (c) 2013 Mateor
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

ANDROID_HOME=~/android/system/jellybean
LOCK_DIR=~/android/openpdroid

# File used to determine is source and created binaries are patched.
LOCK="$LOCK_DIR"/.pdroid-lock

# TODO add branch as a possible parameter, to clean CM10 and earlier. Default to 4.2+ (as below)
PATCHED_DIRS=( build libcore frameworks/base frameworks/opt/telephony packages/apps/Mms )

for dir in ${PATCHED_DIRS[@]}; do
     cd "$ANDROID_HOME"/$dir
     git reset --hard
     git clean -df
done

# TODO add some error catching in case something goes wrong

cd "$ANDROID_HOME"
repo abandon pdroid
repo sync -l

rm -rf out/target/common/obj/JAVA_LIBRARIES/core_intermediates
rm -rf out/target/common/obj/JAVA_LIBRARIES/framework_intermediates
rm -rf out/target/common/obj/JAVA_LIBRARIES/services_intermediates
rm -rf out/target/common/obj/JAVA_LIBRARIES/telephony-common_intermediates
rm -rf out/target/common/obj/APPS/Mms_intermediates

# remove the lock and allow for future patching
rm -rf $LOCK && echo "Pdroid Lock removed."
