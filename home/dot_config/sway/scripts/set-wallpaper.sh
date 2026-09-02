#!/usr/bin/env sh
# Pick a random wallpaper per output and hand it to swaybg.
# swww is a transitional dummy package on Void and wpaperd is unpackaged,
# so swaybg is the wallpaper setter here.
set -eu

if [ -z "${WAYLAND_DISPLAY:-}" ]; then
  exit 0
fi

wall_dir="${XDG_DATA_HOME:-$HOME/.local/share}/wallpapers"
cache_dir="$HOME/.cache/lain-wallpaper"

wallpaper_list=$(find -L "$wall_dir" -type f \
  \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null || true)
if [ -z "$wallpaper_list" ]; then
  exit 0
fi

wallpaper_count=$(printf '%s\n' "$wallpaper_list" | wc -l | tr -d ' ')
mkdir -p "$cache_dir"

pick_wallpaper() {
  output_name="$1"
  last_file="$cache_dir/$output_name.last"
  last_wallpaper=""
  if [ -f "$last_file" ]; then
    last_wallpaper=$(cat "$last_file")
  fi

  if command -v shuf >/dev/null 2>&1; then
    if [ -n "$last_wallpaper" ] && [ "$wallpaper_count" -ge 2 ]; then
      candidate=$(printf '%s\n' "$wallpaper_list" | grep -Fvx "$last_wallpaper" | shuf -n 1)
    else
      candidate=$(printf '%s\n' "$wallpaper_list" | shuf -n 1)
    fi
  else
    candidate=$(printf '%s\n' "$wallpaper_list" | head -n 1)
    if [ "$candidate" = "$last_wallpaper" ] && [ "$wallpaper_count" -ge 2 ]; then
      candidate=$(printf '%s\n' "$wallpaper_list" | sed -n '2p')
    fi
  fi

  [ -n "$candidate" ] || candidate="$last_wallpaper"
  [ -n "$candidate" ] && printf '%s' "$candidate" >"$last_file"
  printf '%s\n' "$candidate"
}

# `-p` prints "Output <name> '<make model serial>'" — no JSON parser needed.
outputs=$(swaymsg -t get_outputs -p 2>/dev/null | awk '/^Output /{print $2}' || true)
[ -n "$outputs" ] || outputs="*"

pkill -x swaybg 2>/dev/null || true

for output in $outputs; do
  wall=$(pick_wallpaper "$output")
  [ -n "$wall" ] || continue
  swaybg -o "$output" -i "$wall" -m fill >/dev/null 2>&1 &
done
