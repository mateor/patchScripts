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

# Moves binary files to prep them for the patch construction. Determines if pdroid patches are applied
# automatically, but needs the ROMTYPE as the sole parameter
 

PDROID_DIR=~/android/openpdroid

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
    mkdir ~/android/openpdroid/$1
fi

LOCK=~/android/openpdroid/.pdroid-lock

if [ -f "$LOCK" ]; then
    PATCHSTATUS=pdroid
else
    PATCHSTATUS=stock
fi

DATE=$(date +%Y%m%d)
if [ ! -d $PDROID_DIR/$1/$DATE ]; then
    mkdir $PDROID_DIR/$1/$DATE || exit
fi

cd $PDROID_DIR/$1/$DATE
if [ ! -d $PDROID_DIR/$1/$DATE/$PATCHSTATUS-services ]; then
    bash $PDROID_DIR/makeDirs.sh
fi

# Find most recently built target
DEVICEDIR=~/android/system/jellybean/out/target/product
DEVICES=( $(ls -t $DEVICEDIR) )
DEVICE=${DEVICES[0]}

ROM_OUT=$DEVICEDIR/$DEVICE/system
TARGET=$PDROID_DIR/$1/$DATE

cp -av $ROM_OUT/framework/services.jar $TARGET/"$PATCHSTATUS"-services
cp -av $ROM_OUT/framework/framework.jar $TARGET/"$PATCHSTATUS"-framework
cp -av $ROM_OUT/framework/telephony-common.jar $TARGET/"$PATCHSTATUS"-telephony-common
cp -av $ROM_OUT/app/Mms.apk $TARGET/"$PATCHSTATUS"-Mms

#if [[ "$PATCHSTATUS" == "pdroid" ]]; then
#    source $PDROID_DIR/decompile.sh || ( echo "something went wrong with the decompile!!!" && exit )
 #   source makePatches.sh
#fi

echo ""
echo "Successfully placed $PATCHSTATUS files in $PDROID_DIR/$1/$DATE"

#PDROID_OUT="~/android/openpdroid/$1/$DATE"
#export $PDROID_OUT
