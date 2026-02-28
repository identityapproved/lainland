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

capture_full() {
  if grim - | swappy -f - -o "$outfile"; then
    notify_result
  else
    notify "Screenshot failed" "Mode: full"
    exit 1
  fi
}

capture_output() {
  if grim -g "$(slurp -o)" - | swappy -f - -o "$outfile"; then
    notify_result
  else
    notify "Screenshot failed" "Mode: output"
    exit 1
  fi
}

capture_region() {
  if grim -g "$(slurp)" - | swappy -f - -o "$outfile"; then
    notify_result
  else
    notify "Screenshot failed" "Mode: region"
    exit 1
  fi
}

case "$mode" in
  full)
    outfile="$dir/<$tag>_full.png"
    capture_full
    ;;
  output)
    outfile="$dir/<$tag>_output.png"
    capture_output
    ;;
  region)
    outfile="$dir/<$tag>_region.png"
    capture_region
    ;;
  *)
    echo "Usage: $0 {full|output|region}" >&2
    exit 1
    ;;
esac
