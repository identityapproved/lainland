#!/usr/bin/env bash
set -euo pipefail

if ! command -v sensors >/dev/null 2>&1; then
  printf '{"text":"T?","tooltip":"lm_sensors not installed"}\n'
  exit 0
fi

raw="$(sensors 2>/dev/null || true)"

if [[ -z "$raw" ]]; then
  printf '{"text":"T?","tooltip":"No sensors output"}\n'
  exit 0
fi

temp="$(
  printf '%s\n' "$raw" \
  | grep -m1 -oE '[+-]?[0-9]+([.][0-9]+)?°C' \
  | head -n1 \
  | sed 's/^+//'
)"

if [[ -z "$temp" ]]; then
  temp="?"
fi

tooltip="$(
  printf '%s\n' "$raw" \
  | awk 'BEGIN{ORS=""}
    {
      gsub(/\\/,"\\\\");
      gsub(/"/,"\\\"");
      if (NR > 1) printf "\\n";
      printf "%s", $0
    }'
)"

printf '{"text":"T%s","tooltip":"%s"}\n' "$temp" "$tooltip"
