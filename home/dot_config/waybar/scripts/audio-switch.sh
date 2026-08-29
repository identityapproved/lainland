#!/usr/bin/env bash
# Default-sink switcher for the waybar audio module (PipeWire: wpctl + pactl).
# Usage: audio-switch.sh next|mute
set -euo pipefail

case "${1:-next}" in
  next)
      mapfile -t s < <(pactl list short sinks | awk '{print $2}')
      def=$(pactl get-default-sink); i=0
      for k in "${!s[@]}"; do [ "${s[$k]}" = "$def" ] && i=$k; done
      nx=${s[$(((i+1)%${#s[@]}))]}
      pactl set-default-sink "$nx"
      # follow existing streams to the new output
      pactl list short sink-inputs | awk '{print $1}' | while read -r in; do
          pactl move-sink-input "$in" "$nx"; done
      # brief desktop hint of what we switched to
      desc=$(pactl list sinks | awk -v n="$nx" '
          $1=="Name:"{cur=($2==n)} cur&&$1=="Description:"{$1="";sub(/^ /,"");print;exit}')
      command -v notify-send >/dev/null && \
          notify-send -t 1500 -h string:x-canonical-private-synchronous:audio-switch \
              "Audio output" "${desc:-$nx}" || true ;;
  mute) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
  *)    echo "usage: $0 next|mute" >&2; exit 1 ;;
esac
