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

# These environmental variables are best set in the BUILD file!
[[ "$PDROID_DIR" == "" ]] && PDROID_DIR=~/android/openpdroid
[[ "$PATCH_SCRIPTS_LOC" == "" ]] && PATCH_SCRIPTS_LOC=~/android/openpdroid/patchScripts
[[ "$LOCK" == "" ]] && LOCK=$PDROID_DIR/.pdroid-lock
[[ $AUTOPATCHER_DIR == "" ]] && AUTOPATCHER_DIR=~/android/auto-patcher

# If making auto-patcher patches for Android KitKat, you will need baksmali-2.0.jar. Now bundled.
BAKSMALI_LOC="$PATCH_SCRIPTS_LOC/bin"
BAKSMALI_BINARY=~/baksmali.jar


if [ -f "$PDROID_DIR"/"$LOCK" ]; then
     API=$(cat $PDROID_DIR/$LOCK)
else
     REMOVE_SOURCE=false
fi

# The API is sent to the decompiler as an argument. Android 4.4 MUST be used with API 19 and is the default.
# The other Android versions are a little more flexible, but best to be precise
# Android 2.3 is API=10
# 4.0 is API=15
# 4.1* is API=16
# 4.2* is API=17
# 4.3* is API=18
# 4.4 is API=19

if [[ $# -gt 1 ]]; then
    API=$2
    echo ""
    echo "### Using API $API ###"
fi

if [ -z "$API" ]; then
     API=19
     echo ""
     echo "Defaulting to API 19. This should automatically be properly set, but you may"
     echo "    pass an API as an argunment (i.e. ./patchScripts makePatches 19)"
     echo ""
fi

if [[ "$API" == "19" ]]; then
     BAKSMALI_BINARY=${BAKSMALI_LOC}/baksmali-2.0.jar
     echo "... Using $BAKSMALI_BINARY for KitKat ..."
     echo ""
fi

if [ ! -f "$BAKSMALI_BINARY" ]; then
     echo "Cannot find the $BAKSMALI_BINARY! Edit the location in the script!"
     echo ""
     echo "Android 4.4 requires baksmali-2.0.jar."
     echo " while earlier Android versions use baskmali-1.4*.jar"
     exit
fi

# I guess I could just use find, although I don't know if the sanity checks would suffice for me.
PATCH_STATE=(stock pdroid)
JARS=(services core framework core telephony-common Mms.apk)

for STATE in ${PATCH_STATE[@]}; do
     for FILE in ${JARS[@]}; do
          # echoing API until I have faith in the process. WrongAPI==bootloops
          echo "... Decompiling $STATE-$FILE with API "$API" ..."
          java -jar $BAKSMALI_BINARY -b -a $API $STATE-$FILE/"$FILE"* -o $STATE-$FILE/smali
     done
done

for JAR in ${JARS[@]}; do
     # TODO handle this better if there's multiple matches to the wildcard: errors. Refactor naming, brah.
     if ( [ -d pdroid-$JAR*/smali ] && [ -d stock-$JAR*/smali ] ); then
          ( diff -Npruw stock-$JAR*/smali pdroid-$JAR*/smali > $JAR.patch )
          if [ -s $JAR.patch ]; then
               echo "### Created: $JAR.patch ###"
               JARS=( ${JARS[@]//$JAR} )
          else
               echo "!!! Alert! The $JAR.patch was not created or is empty! Check it out. !!!"
          fi
     else
               echo "!!! Alert! One of the $JAR folders is empty! Check the arg to placeFiles.sh!"
     fi
done

# reset source (I always forget to do this elsewhere. Maybe this will not be smart.)
if [[ ${#JARS[@]} -eq 0 ]]; then
     echo ""
     echo "All patches created successfully"
     if [[ "$REMOVE_SOURCE" != "false" ]]; then
          $PATCH_SCRIPTS_LOC/src/removePdroid.sh && echo "OpenPDroid patches have been removed from source"
     fi
fi

# Load Auto-patcher
# TODO. I think it might fit better in here as the variables wouldn't need to port. Fitting these together 
#    is a work in progress
