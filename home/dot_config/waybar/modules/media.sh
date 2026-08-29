#!/usr/bin/env bash
# Now-playing for waybar via the playerctl CLI (the GObject/Playerctl GIR that
# mediaplayer.py needs isn't installed; the CLI is). Same source eww used.
# Emits one waybar JSON object per change (return-type "json", --follow).

emit_idle() { printf '{"text":"","class":"stopped","tooltip":false}\n'; }

# No player yet -> show nothing, then let --follow stream updates.
emit_idle

playerctl --follow metadata \
  --format $'{{status}}\x1f{{artist}}\x1f{{title}}' 2>/dev/null |
while IFS=$'\x1f' read -r status artist title; do
  case "$status" in
    Playing) icon="" ;;
    Paused)  icon="" ;;
    *) emit_idle; continue ;;
  esac

  if [ -n "$artist" ]; then text="$artist - $title"; else text="$title"; fi
  # JSON-escape backslashes and quotes
  text="${text//\\/\\\\}"; text="${text//\"/\\\"}"

  printf '{"text":"%s %s","class":"%s","tooltip":false}\n' \
    "$icon" "$text" "$(printf '%s' "$status" | tr '[:upper:]' '[:lower:]')"
done
