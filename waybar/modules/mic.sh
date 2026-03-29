#!/usr/bin/env bash
set -euo pipefail

source_target='@DEFAULT_AUDIO_SOURCE@'
status="$(wpctl get-volume "$source_target" 2>/dev/null || true)"

if [[ -z "$status" || "$status" == *"[MUTED]"* ]]; then
  printf '{"text":"","class":"muted"}\n'
else
  printf '{"text":"","class":"unmuted"}\n'
fi
