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

# Change to whatever works for you
ANDROID_HOME=~/android/system/jellybean
PATCHES_LOCATION=~/android/OpenPDroidPatches

# TODO: make BRANCH a parameter
BRANCH=4.3
LOG_DIR=~/android/openpdroid

LOG="$LOG_DIR"/OpDPatch.log
# This LOCK file is used by various scripts to determine if the patches are applied to the source code
LOCK="$LOG_DIR"/.pdroid-lock

print_error() {
     echo ""
     echo "!!! error: $@"
     echo "At least one patch failed to apply! You can see the problem below and in $LOG"
     echo ""
     grep FAILED "$LOG"
     echo ""
     echo "These failures are often just import statements"
     echo "and are generally easy to resolve manually."
     echo ""
     echo "If there is only one or two, I recommend you take a peek at the .rej file."
     echo ""
     echo "The directory the failure is in is listed above!"
}

patch_error() {
     echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
     echo "!!! error: $@"
     echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
     exit
}

if [ -f "$LOCK" ]; then
    echo ""
    echo "Pdroid patches are already applied."
    echo "   removePdroid.sh should be ran to remove the lock at $LOCK"
    echo ""
    exit
fi

cd "$PATCHES_LOCATION"
git checkout "$BRANCH" || patch_error "Could not checkout the branch you designated, double-check location and branch!"

DIRECTORIES_TO_PATCH=( build libcore frameworks_base frameworks_opt_telephony packages_apps_Mms )

cd "$ANDROID_HOME"/build; git checkout -b pdroid; patch -p1 < "$PATCHES_LOCATION"/openpdroid_"$BRANCH"_build.patch >> "$LOG_DIR"/${DIRECTORIES_TO_PATCH[0]}.log 2>&1
cd "$ANDROID_HOME"/libcore; git checkout -b pdroid; patch -p1 < "$PATCHES_LOCATION"/openpdroid_"$BRANCH"_libcore.patch >> "$LOG_DIR"/${DIRECTORIES_TO_PATCH[1]}.log 2>&1
cd "$ANDROID_HOME"/frameworks/base; git checkout -b pdroid; patch -p1 < "$PATCHES_LOCATION"/openpdroid_"$BRANCH"_frameworks_base.patch >> "$LOG_DIR"/${DIRECTORIES_TO_PATCH[2]}.log 2>&1
cd "$ANDROID_HOME"/frameworks/opt/telephony; git checkout -b pdroid; patch -p1 < "$PATCHES_LOCATION"/openpdroid_"$BRANCH"_frameworks_opt_telephony.patch >> "$LOG_DIR"/${DIRECTORIES_TO_PATCH[3]}.log 2>&1
cd "$ANDROID_HOME"/packages/apps/Mms; git checkout -b pdroid; patch -p1 < "$PATCHES_LOCATION"/openpdroid_"$BRANCH"_packages_apps_Mms.patch >> "$LOG_DIR"/${DIRECTORIES_TO_PATCH[4]}.log 2>&1

for d in ${DIRECTORIES_TO_PATCH[@]}; do
     [[ $(grep FAILED "$LOG_DIR"/"$d".log) != "" ]] && print_error "Failure in $d!"
     cat "$LOG_DIR"/"$d".log >> "$LOG"
     rm "$LOG_DIR"/"$d".log
done

cd "$ANDROID_HOME"; . build/envsetup.sh

# to determine if Pdroid patches are applied or not
touch $LOCK
