#!/usr/bin/env bash
# Mic mute control for the compositor binds and the waybar custom/mic module.
# Acts on whatever source PipeWire currently defaults to. mango's spawn binds
# don't run a shell, hence the logic lives here instead of being chained with &&
# in the keybind.
set -euo pipefail

SRC="@DEFAULT_SOURCE@"

refresh() { pkill -RTMIN+8 waybar 2>/dev/null || true; }
is_muted() { pactl get-source-mute "$SRC" 2>/dev/null | grep -q yes; }
have_src() { pactl get-source-mute "$SRC" >/dev/null 2>&1; }

case "${1:-toggle}" in
toggle)
  pactl set-source-mute "$SRC" toggle
  if is_muted; then
    notify-send "⏸ Mic muted ✗"
  else
    notify-send "▶︎ • Mic unmuted ၊၊||၊။|||"
  fi
  refresh
  ;;
mute)
  pactl set-source-mute "$SRC" 1
  refresh
  ;;
unmute)
  pactl set-source-mute "$SRC" 0
  refresh
  ;;
status)
  is_muted && echo muted || echo unmuted
  ;;
waybar)
  # JSON for the waybar custom/mic module (MDI glyphs render in M+ Nerd Font).
  if ! have_src; then
    echo '{"text":"󰍮","class":"absent"}'
  elif is_muted; then
    echo '{"text":"󰍭","class":"muted"}'
  else
    echo '{"text":"󰍬","class":"unmuted"}'
  fi
  ;;
*)
  echo "usage: $0 [toggle|mute|unmute|status|waybar]" >&2
  exit 2
  ;;
esac
