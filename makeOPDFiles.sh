#!/bin/bash

# order OpD build

# Pdroid lock means that the PDroid-patches are applied

LOCK=~/android/openpdroid/.pdroid-lock

# the absence of the PDroid lock means you are ordering a stock build...that usually needs to be clean
if [ ! -f $LOCK ]; then
     make clobber
fi

make framework services core telephony-common Mms
