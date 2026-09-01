#!/bin/sh
# Cycle focus among the visible floating windows on the current monitor.
# mango has no floating-only focus dispatcher (focusstack/focusdir walk every
# window), so this rebuilds Hyprland's `cyclenext, floating` over IPC: read the
# client list, keep the floating ones on the monitor being looked at, and focus
# the next one by id. Bound to SUPER+d / SUPER+SHIFT+d in config.conf.
#
# Cycling is by id, not stack order: mmsg lists clients focus-first, so cycling
# in list order would ping-pong between the last two windows instead of walking
# the ring. Ids are stable for a window's lifetime, so the ring is too.

dir="${1:-next}"

clients=$(mmsg get all-clients 2>/dev/null) || exit 0
[ -n "$clients" ] || exit 0

focused=$(printf '%s' "$clients" | jq -r 'first(.clients[] | select(.is_focused)) | .id // empty')

# The monitor in play: the focused window's, or the one under the pointer when
# nothing is focused (empty tag, or focus left on a layer surface).
mon=$(printf '%s' "$clients" | jq -r 'first(.clients[] | select(.is_focused)) | .monitor // empty')
[ -n "$mon" ] || mon=$(mmsg get cursorpos 2>/dev/null | jq -r '.monitor // empty')
[ -n "$mon" ] || exit 0

# Minimized clients still report is_visible, so they need excluding by hand.
ids=$(printf '%s' "$clients" | jq -r --arg mon "$mon" '
	[.clients[]
	| select(.monitor == $mon and .is_floating and .is_visible and (.is_minimized | not))]
	| sort_by(.id)[] | .id')
[ -n "$ids" ] || exit 0

case $dir in
prev) ids=$(printf '%s\n' "$ids" | tac) ;;
esac

# Next id after the focused one, wrapping. If the focused window is not
# floating -- the usual case, since this is how you reach a floating window
# from the tiled stack -- start at the head of the ring.
target=$(printf '%s\n' "$ids" | awk -v cur="$focused" '
	{ ids[NR] = $0; if ($0 == cur) hit = NR }
	END { if (NR) print (hit ? ids[hit % NR + 1] : ids[1]) }')
[ -n "$target" ] || exit 0

mmsg dispatch focusid "client,$target" >/dev/null 2>&1
