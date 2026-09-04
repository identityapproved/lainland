#!/usr/bin/env bash
# gammastep control for waybar (mango + sway).
#
# gammastep has no IPC and no status file, so the process itself is the state:
# running means the night shift is applied, absent means the ramp is untouched.
# Settings all come from ~/.config/gammastep/config.ini -- no flags here, so the
# module and the compositor autostarts cannot drift apart.
#
# mango's spawn binds don't run a shell, hence the logic lives here rather than
# being chained with && in a keybind.
set -euo pipefail

# MDI glyphs, as in toggle_mic.sh. Moon = shift applied, sun = native ramp.
ICON_ON=󰖔
ICON_OFF=󰖙

refresh() { pkill -RTMIN+10 waybar 2>/dev/null || true; }
running() { pgrep -x gammastep >/dev/null 2>&1; }

start() {
  # setsid detaches it from waybar: started as a plain child it would die with
  # the bar, and the panel would stay warm with nothing left to reset it.
  setsid -f gammastep >/dev/null 2>&1
}

stop() {
  # SIGTERM only. gammastep restores the untouched ramp on a clean exit; SIGKILL
  # leaves the screen warm until the next session.
  pkill -x -TERM gammastep 2>/dev/null || true
}

case "${1:-toggle}" in
toggle)
  if running; then stop; else start; fi
  # The bar re-runs `waybar` below on the signal, and pgrep needs the process
  # table to have caught up with the fork/exit first.
  sleep 0.3
  refresh
  ;;
on)
  running || start
  sleep 0.3
  refresh
  ;;
off)
  stop
  sleep 0.3
  refresh
  ;;
status)
  running && echo on || echo off
  ;;
waybar)
  # JSON for the waybar custom/gammastep module.
  if ! command -v gammastep >/dev/null 2>&1; then
    # Same contract as the launcher configs: inert without the binary.
    echo '{"text":"","tooltip":"","class":"absent"}'
  elif running; then
    # -p is gammastep's one-shot print mode: period, location, solar elevation,
    # temperature. It reads the same config.ini, so the tooltip cannot disagree
    # with what the running instance is applying.
    tip=$(gammastep -p 2>/dev/null | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')
    [ -n "$tip" ] || tip="gammastep running"
    printf '{"text":"%s","class":"on","tooltip":"%s"}\n' "$ICON_ON" "$tip"
  else
    printf '{"text":"%s","class":"off","tooltip":"night colour shift off"}\n' "$ICON_OFF"
  fi
  ;;
*)
  echo "usage: $0 [toggle|on|off|status|waybar]" >&2
  exit 2
  ;;
esac
