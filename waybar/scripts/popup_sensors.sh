#!/usr/bin/env bash
set -euo pipefail

exec kitty --title termfloat-sensors --hold sh -lc '
if command -v watch >/dev/null 2>&1; then
  watch -n 1 sensors
else
  while :; do
    clear
    sensors
    sleep 1
  done
fi
'
