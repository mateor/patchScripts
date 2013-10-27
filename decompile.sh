#!/bin/bash

# at some point I need to explictly handle apk vs. jars

JARS=$(ls)

for j in ${JARS[@]}; do
     java -jar ~/baksmali.jar -b -a 17 $j/*jar -o $j/smali || java -jar ~/baksmali.jar -b -a 17 $j/*apk -o $j/smali
done
