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

PDROID_DIR=~/android/openpdroid
LOCK=.pdroid-lock

API=$(cat $PDROID_DIR/$LOCK)

# default to JB until the custom scene drops 4.4
if [ -z $API ]; then
     API=18
fi

if [[ $# -gt 0 ]]; then
    API=$1
    echo ""
    echo "### Using API $API ###"
fi

# I guess I could just use find, although I don't know if the sanity checks would suffice for me.
PATCH_STATE=(stock pdroid)
JARS=(services core framework core telephony-common Mms.apk)

for STATE in ${PATCH_STATE[@]}; do
     for FILE in ${JARS[@]}; do
     # echoing API until I have faith in the process. WrongAPI==bootloops
     echo "... Decompiling $STATE-$FILE with API $API ..."
     java -jar ~/baksmali.jar -b -a $API $STATE-$FILE*/"$FILE"* -o $STATE-$FILE/smali
     done
done

for JAR in ${JARS[@]}; do
     if [ -d pdroid-$JAR*/smali ]; then
          ( diff -Npruw stock-$JAR*/smali pdroid-$JAR*/smali > $JAR.patch )
          if [ -s $JAR.patch ]; then
               echo "### Created: $JAR.patch ###"
          else
               echo "!!! Alert! The $JAR.patch was not created or is empty! Check it out. !!!"
          fi
     fi
done
