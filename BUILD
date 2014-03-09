#!/bin/bash

# The MIT License (MIT)
#
# Copyright (c) 2014 Mateor
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

# Config for patchScripts 

# CHANGE THIS SECTION!!

# This is my personal set up. I include it as an example, but it would be pretty easy to
#  end up clong the entire AOSP in a new directory, if you aren't aware.


PATCH_SCRIPTS_LOC=$(pwd)

# ************  Start Editing Enviroment Here *****************

ANDROID_HOME=~/android/system/jellybean
PATCHES_LOCATION=~/android/OpenPDroidPatches

# These are for auto-patcher patch creation, you can ignore it if you aren't making those
PDROID_DIR=~/android/openpdroid
AUTOPATCHER_DIR=~/android/auto-patcher

# By default, patchScripts only builds the OpD framework!
# If you want to build an entire rom, comment this line and uncomment the next.
BUILD_COMMAND=$PATCH_SCRIPTS_LOC/src/makeOPDFiles.sh
#BUILD_COMMAND="make otapackage"

# TARGET and MANUFACTURER should match your device tree
TARGET_VERSION=4.4
TARGET=mako
MANUFACTURER=lge

# ************  End Editing Enviroment   **********************



LOCK="$PDROID_DIR"/.pdroid-lock
IPC=$PATCH_SCRIPTS_LOC/.iproc

bold=`tput bold`
normal=`tput sgr0`

exit_code=0
