#!/usr/bin/env bash
set -euo pipefail

monitor="${1:-DVI-D-1}"
fallback_spec="${2:-preferred,auto,1}"
normalized_spec="$(printf '%s' "$fallback_spec" | sed 's/[[:space:]]*,[[:space:]]*/,/g; s/^[[:space:]]*//; s/[[:space:]]*$//')"
config_file="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/configs/monitors.conf"

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "$@"
  fi
}

if ! command -v hyprctl >/dev/null 2>&1; then
  notify "Monitor restart failed" "hyprctl not found"
  exit 1
fi

enable_monitor() {
  hyprctl keyword monitor "$monitor,$normalized_spec" >/dev/null 2>&1
}

load_monitor_spec_from_config() {
  [[ -r "$config_file" ]] || return 1

  awk -F',' -v mon="$monitor" '
    /^[[:space:]]*monitor[[:space:]]*=/ {
      line = $0
      sub(/^[[:space:]]*monitor[[:space:]]*=[[:space:]]*/, "", line)
      if (line ~ /^[[:space:]]*#/) next
      split(line, parts, ",")
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", parts[1])
      if (parts[1] != mon) next
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", parts[2])
      if (parts[2] == "disable") next

      spec = parts[2]
      for (i = 3; i <= length(parts); i++) {
        spec = spec "," parts[i]
      }
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", spec)
      gsub(/[[:space:]]*,[[:space:]]*/, ",", spec)
      print spec
      exit
    }
  ' "$config_file"
}

if config_spec="$(load_monitor_spec_from_config)" && [[ -n "$config_spec" ]]; then
  normalized_spec="$config_spec"
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
  enable_monitor || {
    notify "Monitor restart failed" "Monitor '$monitor' not found"
    exit 1
  }
  notify "Monitor enabled" "$monitor ($normalized_spec)"
  exit 0
fi

if printf '%s\n' "$block" | grep -Eq '^[[:space:]]*disabled:[[:space:]]*(true|yes)'; then
  enable_monitor || {
    notify "Monitor restart failed" "Could not enable $monitor"
    exit 1
  }
  notify "Monitor enabled" "$monitor ($normalized_spec)"
else
  hyprctl keyword monitor "$monitor,disable" >/dev/null 2>&1 || {
    notify "Monitor restart failed" "Could not disable $monitor"
    exit 1
  }
  sleep 0.4
  enable_monitor || {
    notify "Monitor restart failed" "Disabled but failed to re-enable $monitor"
    exit 1
  }
  notify "Monitor restarted" "$monitor ($normalized_spec)"
fi
