#!/usr/bin/env bash
set -euo pipefail

THEME_DIR="$HOME/.config/sioyek/themes"
SWITCHER="$HOME/.config/sioyek/theme_switcher.py"
SIOYEK_BIN="${SIOYEK_BIN:-sioyek}"

# PDF/file currently open in Sioyek (passed from %{file_path})
CURRENT_FILE="${1:-}"

# --- Safety checks ---
if ! command -v fzf >/dev/null 2>&1; then
  echo "[theme_picker] fzf not found in PATH" >&2
  exit 1
fi

if [[ ! -d "$THEME_DIR" ]]; then
  echo "[theme_picker] theme dir not found: $THEME_DIR" >&2
  exit 1
fi

if [[ ! -f "$SWITCHER" ]]; then
  echo "[theme_picker] missing switcher: $SWITCHER" >&2
  exit 1
fi

# Collect theme files (non-hidden)
mapfile -t themes < <(find "$THEME_DIR" -maxdepth 1 -type f ! -name '.*' | sort)

if ((${#themes[@]} == 0)); then
  echo "[theme_picker] no theme files in $THEME_DIR" >&2
  exit 1
fi

# NOTE: This picker is *not* bound by default anymore (it used to kill the
# parent sioyek process). This version never restarts sioyek; it just applies
# the selected theme to the running instance.

choice=""
if [[ -t 0 && -t 1 ]]; then
  choice="$(printf '%s\n' "${themes[@]}" | fzf --prompt="Choose theme > " --height=40% --border)" || exit 0
else
  if ! command -v kitty >/dev/null 2>&1; then
    echo "[theme_picker] kitty not found; install kitty or use ': _theme_choose <name>'" >&2
    exit 1
  fi

  tmp="$(mktemp)"
  kitty -e bash -lc "find \"$THEME_DIR\" -maxdepth 1 -type f ! -name \".*\" | sort | fzf --prompt=\"Choose theme > \" --height=40% --border >\"$tmp\"" || true
  if [[ -s "$tmp" ]]; then
    choice="$(cat "$tmp")"
  fi
  rm -f "$tmp"
  [[ -n "$choice" ]] || exit 0
fi

python "$SWITCHER" "$choice" "$CURRENT_FILE"
