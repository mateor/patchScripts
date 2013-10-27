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

# Apply PDroid from build system Root.

LOCK=~/android/openpdroid/.pdroid-lock

if [ -f "$LOCK" ]; then
    echo ""
    echo "Pdroid patches are already applied."
    echo "   removePdroid.sh should be ran to remov the lock at $LOCK"
    echo ""
    exit
fi

cd ~/android/open*/Open*
git checkout 4.2.x

cd ~/android/system/jellybean/build; git checkout -b pdroid; patch -p1 < ~/android/open*/Open*/openpdroid_4.2_build.patch
cd ~/android/system/jellybean/libcore; git checkout -b pdroid; patch -p1 < ~/android/open*/Open*/openpdroid_4.2_libcore.patch
cd ~/android/system/jellybean/packages/apps/Mms; git checkout -b pdroid; patch -p1 < ~/android/open*/Open*/openpdroid_4.2_packages_apps_Mms.patch
cd ~/android/system/jellybean/frameworks/base; git checkout -b pdroid; patch -p1 < ~/android/open*/Open*/openpdroid_4.2_frameworks_base.patch
cd ~/android/system/jellybean/frameworks/opt/telephony; git checkout -b pdroid; patch -p1 < ~/android/open*/Open*/openpdroid_4.2_frameworks_opt_telephony.patch
cd ~/android/system/jellybean; . build/envsetup.sh

# to determine if Pdroid patches are applied or not
touch $LOCK
