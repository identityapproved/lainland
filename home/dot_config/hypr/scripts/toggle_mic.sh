#!/usr/bin/env bash
set -euo pipefail

list_mic_sources() {
  local status_output line id in_sources=0 found=0

  status_output="$(wpctl status --name 2>/dev/null || true)"
  if [[ -z "$status_output" ]]; then
    printf '%s\n' '@DEFAULT_AUDIO_SOURCE@'
    return
  fi

  while IFS= read -r line; do
    if [[ "$line" =~ ^Audio[[:space:]]*$ ]]; then
      continue
    elif [[ "$line" =~ ^[[:space:]]*Sources: ]]; then
      in_sources=1
      continue
    elif [[ "${in_sources:-0}" -eq 1 && "$line" =~ ^[[:space:]]*(Filters:|Streams:|Video) ]]; then
      break
    fi

    if [[ "${in_sources:-0}" -ne 1 ]]; then
      continue
    fi

    if [[ "$line" =~ [Mm]onitor ]]; then
      continue
    fi

    if [[ "$line" =~ ([0-9]+)\. ]]; then
      id="${BASH_REMATCH[1]}"
      printf '%s\n' "$id"
      found=1
    fi
  done <<<"$status_output"

  if [[ "$found" -eq 0 ]]; then
    printf '%s\n' '@DEFAULT_AUDIO_SOURCE@'
  fi
}

any_mic_unmuted() {
  local id status

  while IFS= read -r id; do
    [[ -z "$id" ]] && continue
    status="$(wpctl get-volume "$id" 2>/dev/null || true)"
    if [[ -n "$status" && "$status" != *"[MUTED]"* ]]; then
      return 0
    fi
  done < <(list_mic_sources)

  return 1
}

all_mics_muted() {
  local id status

  while IFS= read -r id; do
    [[ -z "$id" ]] && continue
    status="$(wpctl get-volume "$id" 2>/dev/null || true)"
    if [[ "$status" != *"[MUTED]"* ]]; then
      return 1
    fi
  done < <(list_mic_sources)

  return 0
}

apply_mic_state() {
  local state="$1"
  local id

  while IFS= read -r id; do
    [[ -z "$id" ]] && continue
    wpctl set-mute "$id" "$state" >/dev/null 2>&1 || true
  done < <(list_mic_sources)
}

print_status() {
  if all_mics_muted; then
    printf 'muted\n'
  else
    printf 'unmuted\n'
  fi
}

case "${1:-toggle}" in
status)
  print_status
  ;;
toggle)
  if any_mic_unmuted; then
    apply_mic_state 1
    notify-send "⏸ Mic muted ✗"
  else
    apply_mic_state 0
    notify-send "▶︎ • Mic unmuted ၊၊||၊။|||"
  fi
  pkill -RTMIN+8 waybar 2>/dev/null || true
  ;;
*)
  echo "usage: $0 [toggle|status]" >&2
  exit 2
  ;;
esac
