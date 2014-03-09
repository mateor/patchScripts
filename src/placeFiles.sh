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

# Moves binary files to prep them for the patch construction. Determines if pdroid patches are applied
# automatically, but needs the ROMTYPE as the sole parameter

# Edit the below to suit your environment (not set if called from orderBuilds)
[[ "$ANDROID_HOME" == "" ]] && ANDROID_HOME=~/android/system/jellybean
[[ "$PDROID_DIR" == "" ]] && PDROID_DIR=~/android/openpdroid

# OpenPDroid-specific files. We also use core.jar but those files/patches haven't changed since ICS
FILES=( framework/telephony-common.jar framework/core.jar framework/services.jar framework/framework.jar app/Mms.apk )
for F in ${FILES[@]}; do
     JAR=${F##*/}
     JARS+=( $JAR )
done

# Perhaps one day to be expanded to take 'files to place' as a second parameter.
if [[ $# -lt 1 ]]; then
    echo ""
    echo "### Error ###"
    echo ""
    echo "You must indicate what the romtype is."
    echo ""
    echo " Usage is"
    echo "./placeFiles cm-10.2"
    echo "   or"
    echo "./placeFiles aosp"
    echo ""
    exit
fi

if [ ! -d $PDROID_DIR/$1 ]; then
    mkdir $PDROID_DIR/$1
fi

LOCK=$PDROID_DIR/.pdroid-lock

if [ -f "$LOCK" ]; then
    PATCHSTATUS=pdroid
else
    PATCHSTATUS=stock
fi

DATE=$(date +%Y%m%d)
if [ ! -d $PDROID_DIR/$1/$DATE ]; then
    mkdir $PDROID_DIR/$1/$DATE || exit
fi

# replaces makeDirs.sh
cd $PDROID_DIR/$1/$DATE
if [ ! -d $PDROID_DIR/$1/$DATE/$PATCHSTATUS-services ]; then
     for JAR in ${JARS[@]}; do
          if [[ $JAR == *".jar" ]]; then
               NAME=${JAR%.jar}
          else
               NAME=$JAR
          fi
          mkdir stock-$NAME
          mkdir pdroid-$NAME
     done
fi

# Find most recently built target- This is not fool proof, but covers the most likely scenarios
DEVICEDIR=$ANDROID_HOME/out/target/product
DEVICES=( $(ls -t $DEVICEDIR) )
DEVICE=${DEVICES[0]}

#TODO if $DEVICE=generic, etc. (no dex in generic builds)

ROM_OUT=$DEVICEDIR/$DEVICE/system

# Checking if being run alone or in the orderBuilds sequence
[[ "$JAR_OUT" == "" ]] && JAR_OUT=$PDROID_DIR/$1/$DATE

# if 4.4 has placed Mms.apk in system/priv-app
if [ ! -f "$ROM_OUT/app/Mms.apk" ]; then
     FILES=( ${FILES[@]//*Mms*} )
     FILES+=( priv-app/Mms.apk )
fi

#TODO Check for no dex file; or better yet automate lunch.

# We create a list of files we need to copy and remove a file only when it is successfully placed 
FAILED_JARS=( ${JARS[@]} )
for FILE in ${FILES[@]}; do
     # strip path
     mJAR=${FILE##*/}
     if [[ $mJAR == *".jar" ]]; then
          NAME=${mJAR%.jar}
     else
          NAME=$mJAR
     fi
     cp -a $ROM_OUT/$FILE "$JAR_OUT"/"$PATCHSTATUS"-$NAME && FAILED_JARS=( ${FAILED_JARS[@]//$mJAR} )
done

echo ""
if [ ${#FAILED_JARS[@]} == 0 ]; then
     echo "Successfully placed $PATCHSTATUS files ( ${FILES[@]} ) in $JAR_OUT"
else
     echo "ERROR! Was not able to place ( ${FAILED_JARS[@]} ) in $JAR_OUT"
fi
echo ""
echo $JAR_OUT > $PATCH_SCRIPTS_LOC/$IPC
