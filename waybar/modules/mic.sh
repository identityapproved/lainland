#!/usr/bin/env bash
set -euo pipefail

status="$("$HOME/.config/hypr/scripts/toggle_mic.sh" status 2>/dev/null || true)"

if [[ -z "$status" || "$status" == "muted" ]]; then
  printf '{"text":"","class":"muted"}\n'
else
  printf '{"text":"","class":"unmuted"}\n'
fi
