#!/usr/bin/env bash
set -euo pipefail

message="${*:-}"

if [ -z "$message" ] && [ ! -t 0 ]; then
    message="$(cat || true)"
fi

message="${message:-Upcoming calcurse reminder}"

if command -v notify-send >/dev/null 2>&1; then
    notify-send -a calcurse -u normal "Calcurse" "$message"
fi

printf '\a'
