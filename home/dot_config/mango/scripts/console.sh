#!/bin/sh
# Quake-style drop-down console, launched by SUPER+` (toggle_named_scratchpad
# in config.conf). mango only runs this script when no console window
# exists yet; every later press is handled by the compositor's own show/hide,
# which preserves the window's geometry. So the pinning below runs exactly
# once per console lifetime and never drifts.
#
# Pinning: the window rule parks the console at offsety:-100, which always
# resolves to exactly gappov below the usable top of the screen -- for -100
# the maths in setclient_coordinate_center reduces to w.y + gappov whatever
# the monitor size or window ratio. offsety is a percentage of the remaining
# free space, so it cannot express "flush against waybar" on its own; we
# subtract that one gap here instead, with an absolute movewin.
#
# The console is a plain tmux session -- run whatever you want in it, from
# wherever you want. Being a session rather than a bare shell is what makes it
# survive the window being closed (or mango being restarted): the next SUPER+`
# attaches straight back to whatever was left running. `new-session -A` creates
# the session only if it is not already there. Override the session name with
# CONSOLE_SESSION; `exec $SHELL` is the fallback if tmux will not start.

APPID=console
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/mango/config.conf"
LOCK="${XDG_RUNTIME_DIR:-/tmp}/mango-console.lock"

console_geom() {
	mmsg get all-clients 2>/dev/null |
		jq -r --arg id "$APPID" \
			'.clients[] | select(.appid == $id) | "\(.id) \(.x) \(.y)"' 2>/dev/null |
		head -n1
}

# Guard the window between spawn and map: until it exists, mango would happily
# run this script again on a second keypress and start a second console.
mkdir "$LOCK" 2>/dev/null || exit 0
trap 'rmdir "$LOCK" 2>/dev/null' EXIT INT TERM

[ -n "$(console_geom)" ] && exit 0

kitty --class "$APPID" -e sh -c \
	'tmux new-session -A -s "${CONSOLE_SESSION:-console}" || exec ${SHELL:-zsh}' &

gappov=$(sed -n 's/^[[:space:]]*gappov=\([0-9][0-9]*\).*/\1/p' "$CONFIG" | tail -n1)
case $gappov in
'' | 0) exit 0 ;;
esac

i=0
while [ "$i" -lt 60 ]; do
	i=$((i + 1))
	# shellcheck disable=SC2046 # deliberate split of "id x y"
	set -- $(console_geom)
	if [ -n "$3" ]; then
		mmsg dispatch "movewin,$2,$(($3 - gappov))" "client,$1" >/dev/null
		exit 0
	fi
	sleep 0.05
done
