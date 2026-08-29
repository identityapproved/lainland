#!/usr/bin/env bash
# Left-click target for waybar custom/nb: fzf over the notebook, open the pick in
# $EDITOR. Runs inside a kitty float, so it owns the terminal.
#
# --no-color throughout: nb colours even when piped, and the escapes would end up
# in the fzf list and in the id parsed out of it.
set -euo pipefail

export NB_DIR="${NB_DIR:-$HOME/nb}"

# nb list prints "[3] Some title"; the bracketed id is what nb show/edit take.
strip_id() { sed -E 's/^\[([^]]+)\].*/\1/'; }

selection="$(
  nb list --no-color </dev/null 2>/dev/null |
    fzf --reverse --prompt='nb > ' \
      --preview="printf '%s' {} | sed -E 's/^\[([^]]+)\].*/\1/' | xargs -r nb show --print --no-color" \
      --preview-window=right:60%:wrap
)" || exit 0

[[ -n "${selection}" ]] || exit 0

nb edit "$(printf '%s' "${selection}" | strip_id)"

# Editing can change the title shown in the tooltip; refresh rather than wait 5m.
pkill -RTMIN+9 waybar 2>/dev/null || true
