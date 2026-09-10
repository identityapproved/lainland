#!/usr/bin/env bash
# waybar custom/nb — open todo count for the nb notebook in $NB_DIR.
#
# waybar is started from mango's exec-once, which does not run a login shell, so
# NB_DIR from .zprofile cannot be relied on here — it is pinned below, same as
# toggle_mic.sh pins its device name. The pin is unconditional, not
# "${NB_DIR:-...}": waybar outlives config changes, and a stale NB_DIR inherited
# from the session that launched it would otherwise win and send nb at a dead
# path, which nb answers by bootstrapping an empty notebook there.
#
# Two nb behaviours drive the awkward bits below: it colours output even when
# stdout is a pipe (hence --no-color, or the tooltip fills with escapes), and it
# reads stdin whenever stdin is not a tty (hence </dev/null, or it blocks
# forever waiting on content that never arrives).
set -euo pipefail

export NB_DIR="$HOME/nb"

# Before nb has bootstrapped the notebook there is nothing to count, and merely
# invoking nb would try to create it.
if [[ ! -f "${NB_DIR}/.current" ]]; then
  jq -nc --arg d "${NB_DIR}" \
    '{text: "-", tooltip: ("nb: no notebook in " + $d), class: "empty"}'
  exit 0
fi

# Open todos only: `nb count` and `nb list` include done ones. `nb todos` applies
# --limit before the open filter (--limit 5 can yield fewer than 5 open), so the
# full list is trimmed here instead. With nothing open it exits 1 and says so on
# stderr only; the grep keeps just "[id] ..." rows.
open="$(nb todos open --no-color 2>/dev/null </dev/null | grep '^\[' || true)"
count=0
[[ -n "${open}" ]] && count="$(printf '%s\n' "${open}" | wc -l)"

if [[ "${count}" == "0" ]]; then
  recent="no open todos"
else
  recent="$(printf '%s\n' "${open}" | head -n 5)"
  ((count > 5)) && recent+=$'\n'"$((count - 5)) more open"
fi

# waybar renders tooltips as pango markup and note titles are arbitrary text, so
# the markup chars need escaping. Done in jq, not bash: since 5.2 an unquoted &
# in a ${v//p/r} replacement expands to the matched text, which silently turns
# "&lt;" into "<lt;".
jq -nc --arg c "${count}" --arg r "${recent}" '
  {
    text: $c,
    tooltip: ($r | gsub("&"; "&amp;") | gsub("<"; "&lt;") | gsub(">"; "&gt;")),
    class: (if $c == "0" then "empty" else "notes" end)
  }'
