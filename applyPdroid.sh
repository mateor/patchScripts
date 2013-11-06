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

# Change this section to whatever works for you
ANDROID_HOME=~/android/system/jellybean
PATCHES_LOCATION=~/android/OpenPDroidPatches
PDROID_DIR=~/android/openpdroid

# If you wish to patch earlier Android versions, pass the matching branch of the OpenPDroidPatches as param.
BRANCH=4.3

LOG="$PDROID_DIR"/OpDPatch.log

# This LOCK file is used by various scripts to determine if the patches are applied to the source code
LOCK="$PDROID_DIR"/.pdroid-lock

print_error() {
     echo ""
     echo "!!! error: $@"
     echo ""
     echo "At least one patch failed to apply! You can see the problem below and in $LOG"
     echo ""
     grep FAILED "$PDROID_DIR"/"$DIR".log
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

# We now wipe old logs here
echo "Patching with OpenPDroidPatches branch: $BRANCH" > "$LOG"
echo "" >> "$LOG"

# This could be significantly refactored. Lets wait until chen is succesful before we pull the rug, OK?
DIRECTORIES_TO_PATCH=( build libcore frameworks_base packages_apps_Mms frameworks_opt_telephony )

cd "$ANDROID_HOME"/build; git checkout -b pdroid; patch -p1 < "$PATCHES_LOCATION"/openpdroid_"$BRANCH"_build.patch >> "$PDROID_DIR"/${DIRECTORIES_TO_PATCH[0]}.log 2>&1
cd "$ANDROID_HOME"/libcore; git checkout -b pdroid; patch -p1 < "$PATCHES_LOCATION"/openpdroid_"$BRANCH"_libcore.patch >> "$PDROID_DIR"/${DIRECTORIES_TO_PATCH[1]}.log 2>&1
cd "$ANDROID_HOME"/frameworks/base; git checkout -b pdroid; patch -p1 < "$PATCHES_LOCATION"/openpdroid_"$BRANCH"_frameworks_base.patch >> "$PDROID_DIR"/${DIRECTORIES_TO_PATCH[2]}.log 2>&1

# Mms patch introduced in 4.1
if [ -f $PATCHES_LOCATION/*"$BRANCH"*packages_apps_Mms*h ]; then
     cd "$ANDROID_HOME"/packages/apps/Mms; git checkout -b pdroid; patch -p1 < "$PATCHES_LOCATION"/openpdroid_"$BRANCH"_packages_apps_Mms.patch >> "$PDROID_DIR"/${DIRECTORIES_TO_PATCH[3]}.log 2>&1
else
     DIRECTORIES_TO_PATCH=( ${DIRECTORIES_TO_PATCH[@]//packages_apps_Mms} )
fi

# Telephony-common introduced in 4.2
if [ -f $PATCHES_LOCATION/*"$BRANCH"*frameworks_opt_telephony*h ]; then
     cd "$ANDROID_HOME"/frameworks/opt/telephony; git checkout -b pdroid; patch -p1 < "$PATCHES_LOCATION"/openpdroid_"$BRANCH"_frameworks_opt_telephony.patch >> "$PDROID_DIR"/${DIRECTORIES_TO_PATCH[4]}.log 2>&1
else
     DIRECTORIES_TO_PATCH=( ${DIRECTORIES_TO_PATCH[@]//frameworks_opt_telephony} )
fi

echo ""
for DIR in ${DIRECTORIES_TO_PATCH[@]}; do
     ( [[ $(grep FAILED "$PDROID_DIR"/"$DIR".log) != "" ]] && print_error "Failure in $DIR!" ) || echo "Patched $DIR succesfully"
     [[ $(grep "Skip this patch?" "$PDROID_DIR"/"$DIR".log) != "" ]] && print_error "Files not found! Examine ${PDROID_DIR}/${LOG} because it is very likely you are using the wrong branch!"
     echo "" >> "$LOG"
     echo "Log for $DIR:" >> "$LOG"
     echo "" >> "$LOG"
     cat "$PDROID_DIR"/"$DIR".log >> "$LOG"
     rm "$PDROID_DIR"/"$DIR".log
done
echo ""
cd "$ANDROID_HOME"; . build/envsetup.sh

# use $LOCK to pass API to decompiler
case $(echo $BRANCH) in
2.3*)
     API=10
     ;;
4.0*)
     API=15
     ;;
4.1*)
     API=16
     ;;
4.2*)
     API=17
     ;;
4.3*)
     API=18
     ;;
esac

if [ -n $API ]; then
     echo -n $API > $LOCK
else
     touch "$LOCK"
     patch_error "API level could not be determined!! There was a problem!"
fi
