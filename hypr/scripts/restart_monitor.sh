#!/usr/bin/env bash
set -euo pipefail

monitor="${1:-DVI-D-1}"
fallback_spec="${2:-preferred,auto,1}"

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "$@"
  fi
}

if ! command -v hyprctl >/dev/null 2>&1; then
  notify "Monitor restart failed" "hyprctl not found"
  exit 1
fi

get_monitor_block() {
  hyprctl monitors all 2>/dev/null | awk -v mon="$monitor" '
    /^Monitor / {
      if (in_block) exit
      in_block = ($2 == mon)
    }
    in_block { print }
  '
}

block="$(get_monitor_block)"

if [[ -z "$block" ]]; then
  hyprctl keyword monitor "$monitor,$fallback_spec" >/dev/null 2>&1 || {
    notify "Monitor restart failed" "Monitor '$monitor' not found"
    exit 1
  }
  notify "Monitor enabled" "$monitor ($fallback_spec)"
  exit 0
fi

if printf '%s\n' "$block" | grep -Eq '^[[:space:]]*disabled:[[:space:]]*(true|yes)'; then
  hyprctl keyword monitor "$monitor,$fallback_spec" >/dev/null 2>&1 || {
    notify "Monitor restart failed" "Could not enable $monitor"
    exit 1
  }
  notify "Monitor enabled" "$monitor ($fallback_spec)"
else
  hyprctl keyword monitor "$monitor,disable" >/dev/null 2>&1 || {
    notify "Monitor restart failed" "Could not disable $monitor"
    exit 1
  }
  sleep 0.4
  hyprctl keyword monitor "$monitor,$fallback_spec" >/dev/null 2>&1 || {
    notify "Monitor restart failed" "Disabled but failed to re-enable $monitor"
    exit 1
  }
  notify "Monitor restarted" "$monitor ($fallback_spec)"
fi
