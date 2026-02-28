#!/usr/bin/env bash
set -euo pipefail

pidfile="${XDG_RUNTIME_DIR:-/tmp}/hypr-screensaver.pid"

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "$@"
  fi
}

is_running() {
  [[ -f "$pidfile" ]] && kill -0 "$(cat "$pidfile")" 2>/dev/null
}

start_kitty_art() {
  local mode="$1"
  local cmd=""

  if is_running; then
    exit 0
  fi

  case "$mode" in
    matrix)
      cmd='rmatrix'
      ;;
    bonsai)
      cmd='rbonsai -l -p -t 0.03'
      ;;
    random)
      if (( RANDOM % 2 )); then
        cmd='rmatrix'
      else
        cmd='rbonsai -l -p -t 0.03'
      fi
      ;;
    *)
      echo "usage: $0 {matrix|bonsai|random|stop}" >&2
      exit 2
      ;;
  esac

  if ! command -v kitty >/dev/null 2>&1; then
    notify "Screensaver failed" "kitty not found"
    exit 1
  fi

  kitty \
    --class screensaver \
    --title screensaver \
    --start-as=fullscreen \
    --hold \
    sh -lc "$cmd" &

  echo $! > "$pidfile"
}

stop_screensaver() {
  local pid=""

  if [[ -f "$pidfile" ]]; then
    pid="$(cat "$pidfile" || true)"
    rm -f "$pidfile"
    [[ -n "$pid" ]] && kill "$pid" 2>/dev/null || true
  fi

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
