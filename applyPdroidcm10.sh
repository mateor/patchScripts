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

# TODO abandon this script as soon as I add branch parameter to the universal apply/remove

# Apply PDroid from build system Root.
cd ~/android/Open*
git checkout 4.1.2-cm

cd ~/android/system/jellybean/build; git checkout -b pdroid; patch -p1 < ~/android/Open*/openpdroid_4.1.2-cm_build.patch
cd ~/android/system/jellybean/libcore; git checkout -b pdroid; patch -p1 < ~/android/Open*/openpdroid_4.1.2-cm_libcore.patch
cd ~/android/system/jellybean/packages/apps/Mms; git checkout -b pdroid; patch -p1 < ~/android/Open*/openpdroid_4.1.2-cm_packages_apps_Mms.patch
cd ~/android/system/jellybean/frameworks/base; git checkout -b pdroid; patch -p1 < ~/android/Open*/openpdroid_4.1.2-cm_frameworks_base.patch
cd ~/android/system/jellybean; . build/envsetup.sh
