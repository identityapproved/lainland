#!/usr/bin/env bash
set -euo pipefail

exec kitty --title termfloat-calendar --hold sh -lc '
if command -v cal >/dev/null 2>&1; then
  cal -3
elif command -v ncal >/dev/null 2>&1; then
  ncal -bM
else
  date
fi
printf "\n"
date "+%A, %d %B %Y  %H:%M"
'
