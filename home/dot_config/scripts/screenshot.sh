#!/usr/bin/env bash
set -euo pipefail

mode="${1:-region}"

dir="$(eval echo "${SWAPPY_DIR:-$HOME/pics/screenshots}")"
mkdir -p "$dir"
tag="$(date +%m-%d-%Y)-$(printf "%s" "$(date +%s%N)" | sha1sum | cut -c1-7)"
outfile=""

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "$@"
  fi
}

notify_result() {
  if [[ -f "$outfile" ]]; then
    notify "Screenshot saved" "$outfile"
  else
    # swappy may be closed without saving the edited image.
    notify "Screenshot closed" "No file saved"
  fi
}

have_swappy() { command -v swappy >/dev/null 2>&1; }

# capture <mode> <grim geometry args...>
# Routes grim through swappy when available, otherwise saves directly.
capture() {
  local mode="$1"; shift
  if have_swappy; then
    grim "$@" - | swappy -f - -o "$outfile"
  else
    grim "$@" "$outfile"
  fi
}

capture_full() {
  if capture full; then
    notify_result
  else
    notify "Screenshot failed" "Mode: full"
    exit 1
  fi
}

capture_output() {
  if capture output -g "$(slurp -o)"; then
    notify_result
  else
    notify "Screenshot failed" "Mode: output"
    exit 1
  fi
}

capture_region() {
  if capture region -g "$(slurp)"; then
    notify_result
  else
    notify "Screenshot failed" "Mode: region"
    exit 1
  fi
}

capture_game() {
  # Silent capture for fullscreen games: never routes through swappy, so
  # nothing steals focus from the game.
  if grim "$outfile"; then
    notify_result
  else
    notify "Screenshot failed" "Mode: game"
    exit 1
  fi
}

case "$mode" in
  full)
    outfile="$dir/${tag}_full.png"
    capture_full
    ;;
  output)
    outfile="$dir/${tag}_output.png"
    capture_output
    ;;
  region)
    outfile="$dir/${tag}_region.png"
    capture_region
    ;;
  game)
    outfile="$dir/${tag}_game.png"
    capture_game
    ;;
  *)
    echo "Usage: $0 {full|output|region|game}" >&2
    exit 1
    ;;
esac
