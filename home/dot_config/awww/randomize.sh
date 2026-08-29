#!/bin/sh
# Random wallpaper picker/cycler for awww.
#   randomize.sh [dir]              -> set ONE random wallpaper, then exit (buttons/keybinds)
#   randomize.sh loop [dir] [secs]  -> cycle forever; singleton, re-launch is a no-op (autostart)
# The Lain set ships with this repo and lands at the XDG data path; ~/pics is
# the unmanaged catch-all (149 other-palette images) and is only the fallback,
# so a fresh machine cycles Lain wallpapers without any extra setup.
DEFAULT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/wallpapers"
[ -d "$DEFAULT_DIR" ] || DEFAULT_DIR="$HOME/pics/wallpapers"

export AWWW_TRANSITION_FPS="${AWWW_TRANSITION_FPS:-60}"
export AWWW_TRANSITION_STEP="${AWWW_TRANSITION_STEP:-2}"

set_random() {
  dir=$1
  [ -d "$dir" ] || { echo "awww randomize: dir not found: $dir" >&2; exit 1; }
  img=$(find -L "$dir" -type f | shuf -n1)
  [ -n "$img" ] && awww img --resize=crop --fill-color 000000 "$img"
}

# True while a fullscreen client is focused (games, fullscreen video). The
# awww img transition hitches the GPU, which can freeze a fullscreen game, so
# the loop skips cycling until focus leaves fullscreen. No-op if mmsg/jq absent.
focused_fullscreen() {
  command -v mmsg >/dev/null 2>&1 && command -v jq >/dev/null 2>&1 || return 1
  fs=$(mmsg get focusing-client 2>/dev/null \
    | jq -r 'select(.is_fullscreen or .is_fakefullscreen) | true' 2>/dev/null)
  [ "$fs" = true ]
}

if [ "$1" = "loop" ]; then
  dir="${2:-$DEFAULT_DIR}"
  interval="${3:-300}"
  # singleton lock: a second loop just exits, so autostart/clicks can never stack
  lock="${XDG_RUNTIME_DIR:-/tmp}/awww-randomize.lock"
  if command -v flock >/dev/null 2>&1; then
    exec 9>"$lock"
    flock -n 9 || { echo "awww randomize: cycler already running" >&2; exit 0; }
  fi
  while true; do
    focused_fullscreen || set_random "$dir"
    sleep "$interval"
  done
else
  set_random "${1:-$DEFAULT_DIR}"
fi
