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

# Adjust the below section to suit your environment
PDROID_DIR=~/android/openpdroid
LOCK=.pdroid-lock
BAKSMALI_LOC=~

# If making auto-patcher patches for Android KitKat, you will need baksmali-2.0.jar. 
# It is pointed to SEPARATELY below. Not pretty, I know. I will probably bundle it soon.
BAKSMALI_BINARY=~/baksmali.jar


API=$(cat $PDROID_DIR/$LOCK)

# defaulting 4.4
if [ -z "$API" ]; then
     API=19
fi

if [[ $# -gt 0 ]]; then
    API=$1
    echo ""
    echo "### Using API $API ###"
fi

if [[ "$API" == "19" ]]; then
     # Turning off baksmali-2.0 for now...I am getting very ba results on patch application (?)
     BAKSMALI_BINARY=${BAKSMALI_LOC}/baksmali-2.0.jar
     echo "... Using $BAKSMALI_BINARY for KitKat ..."
     echo ""
fi

if [ ! -f "$BAKSMALI_BINARY" ]; then
     echo "Cannot find the $BAKSMALI_BINARY! Edit the location in the script!"
     echo ""
     echo "Android 4.4 requires baksmali-2.0.jar, earlier Android versions use baskmali-1.4*.jar"
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
          else
               echo "!!! Alert! The $JAR.patch was not created or is empty! Check it out. !!!"
          fi
     else
               echo "!!! Alert! One of the $JAR folders is empty! Check the arg to placeFiles.sh!"
     fi
done
