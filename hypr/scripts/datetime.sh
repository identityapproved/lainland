#!/bin/bash

# Notify - Current time via notification

# main() {
#     vars
#     notify-send $TITLE "$TEXT"
# }
#
# vars() {
#     DATE="$(date +%d-%m-%y)"
#     WDAY="$(date +%A)"
#     TIME="$(date +%H:%M)"
#     TEXT="It's $TIME\n$WDAY $DATE"
# }

D=$(date  +%d-%m-%y)
T=$(date +%H:%M)
notify-send " ""$(D)"" ""$(T)"
