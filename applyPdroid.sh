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
[ -f "$LOG" ] && rm "$LOG"

# This LOCK file is used by various scripts to determine if the patches are applied to the source code
LOCK="$LOG_DIR"/.pdroid-lock

print_error() {
     echo ""
     echo "!!! error: $@"
     echo ""
     echo "At least one patch failed to apply! You can see the problem below and in $LOG"
     echo ""
     grep FAILED "$LOG_DIR"/"$d".log
     echo ""
     echo "Failures are often just import statements which are easy to resolve manually."
     echo "If there is only one or two, I recommend you take a peek at the .rej file."
     echo ""
}

patch_error() {
     echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
     echo "!!! error: $@"
     echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
     exit
}

if [ $# -gt 0 ]; then
     BRANCH=$1
elif [ $# -gt 1 ]; then
     patch_error "Only the OpenPDroidPatches branch name is accepted as a parameter!"
fi

AVAILABLE_BRANCHES=( 4.3 4.2.x 4.1.2-aosp 4.1.2-cm 4.1.1-aosp 4.1.1-cm 4.0.4-aosp 4.0.4-cm 2.3 )
VALID_BRANCH=false
for a in ${AVAILABLE_BRANCHES[@]}; do
     if [[ "$a" == $BRANCH ]]; then
          VALID_BRANCH=true
     fi
done

if [[ ! "$VALID_BRANCH" == true ]]; then
     patch_error "$BRANCH is not a valid branch! Check OpenPDroidPatch branch names for valid parameters!"
fi

if [ -f "$LOCK" ]; then
    echo ""
    echo "Pdroid patches are already applied."
    echo "   removePdroid.sh should be ran to remove the lock at $LOCK"
    echo ""
    exit
fi

cd "$PATCHES_LOCATION"
git checkout "$BRANCH" || patch_error "Could not checkout the branch you designated, double-check location and branch!"

DIRECTORIES_TO_PATCH=( build libcore frameworks_base packages_apps_Mms frameworks_opt_telephony )

cd "$ANDROID_HOME"/build; git checkout -b pdroid; patch -p1 < "$PATCHES_LOCATION"/openpdroid_"$BRANCH"_build.patch >> "$LOG_DIR"/${DIRECTORIES_TO_PATCH[0]}.log 2>&1
cd "$ANDROID_HOME"/libcore; git checkout -b pdroid; patch -p1 < "$PATCHES_LOCATION"/openpdroid_"$BRANCH"_libcore.patch >> "$LOG_DIR"/${DIRECTORIES_TO_PATCH[1]}.log 2>&1
cd "$ANDROID_HOME"/frameworks/base; git checkout -b pdroid; patch -p1 < "$PATCHES_LOCATION"/openpdroid_"$BRANCH"_frameworks_base.patch >> "$LOG_DIR"/${DIRECTORIES_TO_PATCH[2]}.log 2>&1

# Mms patch introduced in 4.1
if [ -f $PATCHES_LOCATION/*"$BRANCH"*packages_apps_Mms*h ]; then
     cd "$ANDROID_HOME"/packages/apps/Mms; git checkout -b pdroid; patch -p1 < "$PATCHES_LOCATION"/openpdroid_"$BRANCH"_packages_apps_Mms.patch >> "$LOG_DIR"/${DIRECTORIES_TO_PATCH[3]}.log 2>&1
else
     DIRECTORIES_TO_PATCH=( ${DIRECTORIES_TO_PATCH[@]//packages_apps_Mms} )
fi

# Telephony-common introduced in 4.2
if [ -f $PATCHES_LOCATION/*"$BRANCH"*frameworks_opt_telephony*h ]; then
     cd "$ANDROID_HOME"/frameworks/opt/telephony; git checkout -b pdroid; patch -p1 < "$PATCHES_LOCATION"/openpdroid_"$BRANCH"_frameworks_opt_telephony.patch >> "$LOG_DIR"/${DIRECTORIES_TO_PATCH[4]}.log 2>&1
else
     DIRECTORIES_TO_PATCH=( ${DIRECTORIES_TO_PATCH[@]//frameworks_opt_telephony} )
fi

echo ""
for d in ${DIRECTORIES_TO_PATCH[@]}; do
     ( [[ $(grep FAILED "$LOG_DIR"/"$d".log) != "" ]] && print_error "Failure in $d!" ) || echo "Patched $d succesfully"
     [[ $(grep "Skip this patch?" "$LOG_DIR"/"$d".log) != "" ]] && print_error "Files not found! Examine ${LOG_DIR}/${LOG} because it is very likely you are using the wrong branch!"
     cat "$LOG_DIR"/"$d".log >> "$LOG"
     rm "$LOG_DIR"/"$d".log
done
echo ""
cd "$ANDROID_HOME"; . build/envsetup.sh

# to determine if Pdroid patches are applied or not
touch $LOCK
