#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON_LIB="$SCRIPT_DIR/../lib/common.sh"

if [ -f "$COMMON_LIB" ]; then
  # shellcheck source=/dev/null
  source "$COMMON_LIB"
else
  echo "Error: Missing common library at $COMMON_LIB"
  exit 1
fi

choose_browsers() {
  local options=("brave" "google-chrome" "chromium" "librewolf" "torbrowser-launcher" "zen-browser" "vivaldi" "quit")
  if command -v fzf >/dev/null 2>&1; then
    printf '%s\n' "${options[@]}" | fzf --prompt="Select browsers (multi) > " --height=50% --layout=reverse --multi
    return
  fi

  echo "Select a browser:"
  select choice in "${options[@]}"; do
    echo "$choice"
    return
  done
}

ensure_helper

selection=$(choose_browsers || true)
if [ -z "${selection:-}" ]; then
  exit 0
fi

mapfile -t selected < <(printf '%s\n' "$selection")

for browser in "${selected[@]}"; do
  case "$browser" in
  brave)
    install_pkg brave-bin
    ;;
  google-chrome)
    install_pkg google-chrome
    ;;
  chromium)
    install_pkg chromium
    ;;
  librewolf)
    install_pkg librewolf-bin
    ;;
  torbrowser-launcher)
    install_pkg torbrowser-launcher
    ;;
  zen-browser)
    install_pkg zen-browser
    ;;
  vivaldi)
    install_pkg vivaldi
    ;;
  *) ;;
  esac
done
