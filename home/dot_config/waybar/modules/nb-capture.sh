#!/usr/bin/env bash
# Right-click target for waybar custom/nb: capture a new note in $EDITOR.
# Runs inside a kitty float, so it owns the terminal.
#
# NB_DIR is pinned unconditionally, same as nb.sh: a stale value inherited from
# whatever launched waybar would point nb at a dead path, and nb answers that by
# bootstrapping an empty notebook there.
set -euo pipefail

export NB_DIR="$HOME/nb"

nb add

# Bump the count straight away instead of waiting out the 5m poll.
pkill -RTMIN+9 waybar 2>/dev/null || true
