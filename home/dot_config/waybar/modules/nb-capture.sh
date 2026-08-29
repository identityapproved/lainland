#!/usr/bin/env bash
# Right-click target for waybar custom/nb: capture a new note in $EDITOR.
# Runs inside a kitty float, so it owns the terminal.
set -euo pipefail

export NB_DIR="${NB_DIR:-$HOME/nb}"

nb add

# Bump the count straight away instead of waiting out the 5m poll.
pkill -RTMIN+9 waybar 2>/dev/null || true
