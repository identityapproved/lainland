#!/usr/bin/env bash
# Audio visualizer for waybar (custom module, continuous stdout).
# Same technique eww used: cava raw ASCII -> unicode block bars.

# Drop any cava left orphaned by a previous waybar instance (e.g. after a
# session restart) — otherwise its pipe is dead and the module shows nothing.
pkill -x cava 2>/dev/null || true

bars=10
printf "[general]\nframerate=60\nbars=%d\n[output]\nmethod=raw\nraw_target=/dev/stdout\ndata_format=ascii\nascii_max_range=7\n" "$bars" \
  | cava -p /dev/stdin \
  | sed -u 's/;//g;s/0/▁/g;s/1/▂/g;s/2/▃/g;s/3/▄/g;s/4/▅/g;s/5/▆/g;s/6/▇/g;s/7/█/g;'
