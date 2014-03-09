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

# order OpD build

# Edit this section to match your file system
[[ "$PDROID_DIR" == "" ]] && PDROID_DIR=~/android/openpdroid

#TODO add a ANDROID_HOME env variable

# Pdroid lock means that the PDroid-patches are applied
LOCK=$PDROID_DIR/.pdroid-lock

# the absence of the PDroid lock means you are ordering a stock build...that usually needs to be clean
if [ ! -f $LOCK ]; then
     make clobber
fi

make framework services core telephony-common Mms && exit $? #|| ( echo "You need to lunch your target at your ANDROID_HOME!" && return -1)
