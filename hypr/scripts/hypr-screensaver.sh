#!/usr/bin/env bash
set -euo pipefail

self_path="$(readlink -f "$0" 2>/dev/null || printf '%s\n' "$0")"

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "$@"
  fi
}

is_running() {
  pgrep -f 'kitty .*--class screensaver' >/dev/null 2>&1
}

resolve_art_command() {
  local mode="$1"
  local colors=(green red blue white yellow cyan magenta)
  local color="${colors[RANDOM % ${#colors[@]}]}"
  local update_delay=$(( (RANDOM % 6) + 3 ))
  local bonsai_seed=$RANDOM

  case "$mode" in
    matrix)
      command -v rmatrix >/dev/null 2>&1 || return 1
      printf '%s\n' "$(command -v rmatrix) -s -C $color -u $update_delay"
      ;;
    bonsai)
      command -v rbonsai >/dev/null 2>&1 || return 1
      printf '%s\n' "$(command -v rbonsai) -S -s $bonsai_seed"
      ;;
    random)
      if (( RANDOM % 2 )); then
        resolve_art_command matrix
      else
        resolve_art_command bonsai
      fi
      ;;
    *)
      return 1
      ;;
  esac
}

list_monitors() {
  if command -v jq >/dev/null 2>&1; then
    hyprctl monitors -j 2>/dev/null | jq -r '.[].name'
    return
  fi

  hyprctl monitors 2>/dev/null | awk '/^Monitor / { print $2 }'
}

launch_on_monitor() {
  local monitor="$1"
  local cmd="$2"
  local launch_cmd=""
  local wrapped_cmd=""

  printf -v wrapped_cmd "%s; status=\$?; %s stop >/dev/null 2>&1 || true; exit \$status" "$cmd" "$self_path"
  printf -v launch_cmd 'kitty --start-as=fullscreen --class screensaver --title screensaver-%s sh -lc %q' \
    "$monitor" "$wrapped_cmd"

  hyprctl dispatch exec "$launch_cmd" >/dev/null 2>&1
}

start_kitty_art() {
  local mode="$1"
  local cmd=""
  local monitor=""

  if is_running; then
    exit 0
  fi

  cmd="$(resolve_art_command "$mode")" || {
    notify "Screensaver failed" "Required screensaver command not found"
    exit 1
  }

  if ! command -v kitty >/dev/null 2>&1; then
    notify "Screensaver failed" "kitty not found"
    exit 1
  fi

  if ! command -v hyprctl >/dev/null 2>&1; then
    notify "Screensaver failed" "hyprctl not found"
    exit 1
  fi

  while IFS= read -r monitor; do
    [[ -z "$monitor" ]] && continue
    launch_on_monitor "$monitor" "$cmd"
  done < <(list_monitors)

  sleep 0.3

  if ! is_running; then
    notify "Screensaver failed" "kitty exited immediately"
    exit 1
  fi
}

stop_screensaver() {
  pkill -f 'kitty .*--class screensaver' 2>/dev/null || true
}

case "${1:-}" in
  matrix|bonsai|random)
    start_kitty_art "$1"
    ;;
  stop)
    stop_screensaver
    ;;
  *)
    echo "usage: $0 {matrix|bonsai|random|stop}" >&2
    exit 2
    ;;
esac
