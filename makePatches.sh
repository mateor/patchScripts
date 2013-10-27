#!/bin/bash

diff -Npruw stock-services/smali pdroid-services/smali > services.patch
diff -Npruw stock-framework/smali pdroid-framework/smali > framework.patch
diff -Npruw stock-telephony/smali pdroid-telephony/smali > telephony-common.patch
diff -Npruw stock-mms/smali pdroid-mms/smali > Mms.apk.patch

# this needs to be cleaned up so it doesn't produce empty patches. Time to spend the time....

