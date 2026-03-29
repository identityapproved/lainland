#!/usr/bin/env bash
set -euo pipefail

source_target='@DEFAULT_AUDIO_SOURCE@'
wpctl set-mute "$source_target" toggle || true
pkill -RTMIN+8 waybar 2>/dev/null || true
notify-send "$(wpctl get-volume "$source_target" 2>/dev/null || echo 'MIC status unavailable')"
