#!/usr/bin/env bash
# waybar custom/nb — note count for the nb notebook in $NB_DIR.
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

count="$(nb count --no-color 2>/dev/null </dev/null | tr -dc '0-9')"
count="${count:-0}"

# On an empty notebook `nb list` prints a multi-line "Add a note:" help blurb
# rather than nothing, which is not what you want hanging off a tooltip.
if [[ "${count}" == "0" ]]; then
  recent="notebook is empty"
else
  recent="$(nb list --limit 5 --no-color 2>/dev/null </dev/null || true)"
  [[ -n "${recent}" ]] || recent="notebook is empty"
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
