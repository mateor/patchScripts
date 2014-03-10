#!/bin/bash

# The MIT License (MIT)
#
# Copyright (c) 2013, 2014 Mateor
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

# order builds for SlimRom, CyanogenMod, AOKP, AOSP, PAC-man, OmniRom, ParanoidAndroid and whomever else.

set -a

# adjust these to your own environment/preferences

# PDROID_DIR generally will be where you git clone patchScripts
[[ "$PDROID_DIR" == "" ]] && PDROID_DIR=~/android/openpdroid
[[ "$ANDROID_HOME" == "" ]] && ANDROID_HOME=~/android/system/jellybean

# defaults...change if you intend to run files on your device.
[[ "$TARGET" == "" ]] && TARGET=mako
[[ "$MANUFACTURER" == "" ]] && MANUFACTURER=lge                    # not often needed, only AOKP right now.
[[ "$TARGET_VERSION" == "" ]] && TARGET_VERSION=4.4

# adjust as per your machine- 8 might be a good start.
REPO_SYNC_COMMAND="repo sync -j${JOBS} -f"
[[ "$JOBS" == "" ]] && JOBS=24

# this is for using github.com address as argument. For full builds, change this to "brunch $TARGET"
LUNCH_COMMAND="lunch ${1}_${TARGET}-userdebug"

# Needed to allow for AOKP, and anyone else who gets cute.
DEFAULT_LUNCH_COMMAND="lunch aosp_$TARGET-userdebug"

# If you want the whole rom, comment this line and uncomment the next.
[[ "$BUILD_COMMAND" == "" ]] && BUILD_COMMAND=$PATCH_SCRIPTS_LOC/src/makeOPDFiles.sh
#BUILD_COMMAND="make otapackage"

print_error() {
     echo ""
     echo "!!! error: $@ !!!"
     echo ""
     echo "Your build was not ordered correctly"
     echo ""
}

if [[ $# -gt 1 ]]; then
     TARGET_VERSION="$2"
fi

# Perhaps one day to be expanded to take 'files to place' as a second parameter.
if [[ $# -lt 1 ]]; then
     echo ""
     echo "### Error ###"
     echo ""
     echo "You must indicate what the romtype and Android version is."
     echo ""
     echo " Usage is"
     echo "./orderBuilds cm 4.3"
     echo "   or"
     echo "./orderBuilds aosp 4.4"
     echo ""
     echo "Supported options are ${ROM_OPTIONS[@]}"
     exit
fi

case "$1" in
     aosp)
          GITHUB=android/platform_manifest
          case "$TARGET_VERSION" in
               4.0)
               TARGET_BRANCH=android-4.0.4_r2
               ;;
               4.1)
               TARGET_BRANCH=android-4.1.2_r2.1
               ;;
               4.2)
               TARGET_BRANCH=android-4.2.2_r1.2
               ;;
               4.3)
               TARGET_BRANCH=android-4.3_r3
               ;;
               4.4)
               TARGET_BRANCH=android-4.4_r1.1
               ;;
          esac
     ;;
     cm)
          GITHUB=CyanogenMod/android
          case "$TARGET_VERSION" in
               4.0)
               TARGET_BRANCH=ics
               ;;
               4.1)
               TARGET_BRANCH=jellybean
               ;;
               4.2)
               TARGET_BRANCH=cm-10.1
               ;;
               4.3)
               TARGET_BRANCH=cm-10.2
               ;;
               4.4)
               TARGET_BRANCH=cm-11.0
               ;;
          esac
     ;;
     aokp)
          GITHUB=AOKP/platform_manifest
          case "$TARGET_VERSION" in
               4.0)
               TARGET_BRANCH=ics
               ;;
               4.1)
               TARGET_BRANCH=jb
               ;;
               4.2)
               TARGET_BRANCH=jb-mr1
               ;;
               4.3)
               TARGET_BRANCH=jb-mr2
               ;;
               4.4)
               TARGET_BRANCH=kitkat
               ;;
          esac
     ;;
     slim)
          GITHUB=SlimRoms/platform_manifest
          case "$TARGET_VERSION" in
               4.1)
               TARGET_BRANCH=jb
               ;;
               4.2)
               TARGET_BRANCH=jb4.2
               ;;
               4.3)
               TARGET_BRANCH=jb4.3
               ;;
               4.4)
               TARGET_BRANCH=kk4.4
               ;;
          esac
     ;;
     vanir)
          GITHUB=VanirAOSP/platform_manifest
          case "$TARGET_VERSION" in
               4.1)
               TARGET_BRANCH=jb
               ;;
               4.2)
               TARGET_BRANCH=jb42
               ;;
               4.3)
               TARGET_BRANCH=jb43
               ;;
               4.4)
               TARGET_BRANCH=kk44
               ;;
          esac
     ;;
     pa)
          GITHUB=ParanoidAndroid/manifest
          case "$TARGET_VERSION" in
               4.2)
               TARGET_BRANCH=jellybean
               ;;
               4.3)
               TARGET_BRANCH=jb43
               ;;
               4.4)
               TARGET_BRANCH=kk4.4
               ;;
          esac
     ;;
     pac)
          GITHUB=PAC-man/android
          case "$TARGET_VERSION" in
               4.1)
               TARGET_BRANCH=jellybean
               ;;
               4.2)
               TARGET_BRANCH=cm-10.1
               ;;
               4.3)
               TARGET_BRANCH=cm-10.2
               ;;
               4.4)
               TARGET_BRANCH=cm-11.0
               ;;
          esac
     ;;
     omni)
          GITHUB=PAC-man/android
          case "$TARGET_VERSION" in
               4.3)
               TARGET_BRANCH=android-4.3
               ;;
               4.4)
               TARGET_BRANCH=android-4.4
               ;;
          esac
     ;;
     http*)
          GITHUB_ADDRESS="$1"
          GITHUB=${GITHUB_ADDRESS//*.com\//}
          TARGET_BRANCH="$TARGET_VERSION"
          # The below works for us but won't provide full build. parsing lunch menu may be only current hope
          LUNCH_COMMAND="$DEFAULT_LUNCH_COMMAND"
     ;;
     *)
     print_error "Not a valid rom target." && exit -1
     ;;
esac

if [[ "$2" == aokp ]]; then
     REPO_INIT_COMMAND="repo init -u https://github.com/$GITHUB -b $TARGET_BRANCH -g all,-notdefault,$TARGET,$MANUFACTURER"
else
     REPO_INIT_COMMAND="repo init -u https://github.com/${GITHUB} -b $TARGET_BRANCH"
fi

# order builds
cd $ANDROID_HOME

# if OpD patches are applied, don't repo sync.
if [[ ! -f $LOCK ]]; then
     # get of legitimate as well as hacky manifests from old builds.
     current=$(cat $IPC)
     current_rom=${current%-*}
     # remove old manifests and repo init if switching rom types
     if [[ "$1" != current  ]]; then
          rm -rf .repo/manifests manifests.xml
          rm -rf .repo/local_manifests local_manifests.xml
          $REPO_INIT_COMMAND
          $REPO_SYNC_COMMAND
     fi
     . build/envsetup.sh
     $LUNCH_COMMAND
     # for roomservice and local_manifest pickups
     $REPO_SYNC_COMMAND 
else
     . build/envsetup.sh
     $LUNCH_COMMAND
fi

# deal with CM's totally irritating way of incorporating Android Terminal
if [[ "$2" == "cm" ]]; then
     cd "$ANDROID_HOME"/vendor/cm
     ./get-prebuilts
fi


 I may have to just check that the above went without error manually. I could capture stderr...hmmmph.
$BUILD_COMMAND


