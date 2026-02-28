#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
COMMON_LIB="$SCRIPT_DIR/../lib/common.sh"

CMUS_SRC="$ROOT_DIR/cmus"
MPV_SRC="$ROOT_DIR/mpv"
AUDACIOUS_SRC="$ROOT_DIR/audacious"
VESKTOP_SRC="$ROOT_DIR/vesktop"
SPOTIFY_CFG_SRC="$ROOT_DIR/spotify"

if [ -f "$COMMON_LIB" ]; then
  # shellcheck source=/dev/null
  source "$COMMON_LIB"
else
  echo "Error: Missing common library at $COMMON_LIB"
  exit 1
fi

ensure_helper

link_config_file() {
  local src="$1"
  local dest="$2"

  if [ ! -f "$src" ]; then
    echo "Warning: $src not found. Skipping."
    return 0
  fi

  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ]; then
    local current
    current="$(readlink -f "$dest" || true)"
    if [ "$current" = "$src" ]; then
      echo "Config file already linked: $dest -> $src"
      return 0
    fi
  fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    local backup="${dest}.bak.$(date +%Y%m%d%H%M%S)"
    mv "$dest" "$backup"
    echo "Backed up existing config file: $dest -> $backup"
  fi
  ln -s "$src" "$dest"
  echo "Linked config file: $dest -> $src"
}

if ask_yes "Install cmus?"; then
  install_pkg cmus
  link_config_dir "$CMUS_SRC" "$HOME/.config/cmus"
fi

if ask_yes "Install mpv?"; then
  install_pkg mpv
  link_config_dir "$MPV_SRC" "$HOME/.config/mpv"
fi

if ask_yes "Install pavucontrol?"; then
  install_pkg pavucontrol
fi

if ask_yes "Install audacious?"; then
  install_pkg audacious
  if [ -d "$AUDACIOUS_SRC" ]; then
    link_config_dir "$AUDACIOUS_SRC" "$HOME/.config/audacious"
  else
    echo "No audacious config found. Skipping link."
  fi
fi

if ask_yes "Install spotify?"; then
  install_pkg spotify
  install_pkg spicetify-cli
  if [ -d "$SPOTIFY_CFG_SRC" ]; then
    link_config_dir "$SPOTIFY_CFG_SRC" "$HOME/.config/spicetify"
    echo "Spicetify theme attribution: adapted from https://github.com/Ascaniolamp/Hyprlain"
    sudo chown -R "$USER:$USER" /opt/spotify
    if command -v spicetify >/dev/null 2>&1; then
      spicetify config current_theme lain
      if ! spicetify backup apply; then
        echo "Warning: 'spicetify backup apply' failed. Launch Spotify once, then rerun:"
        echo "  spicetify backup apply"
      fi
    else
      echo "Warning: spicetify not found after install."
    fi
  else
    echo "No spotify (spicetify) config found. Skipping link."
  fi
fi

if ask_yes "Install vesktop?"; then
  install_pkg vesktop
  if [ -d "$VESKTOP_SRC" ]; then
    echo "Vesktop theme attribution: adapted from https://github.com/Ascaniolamp/Hyprlain"
    mkdir -p "$HOME/.config/vesktop" "$HOME/.config/vesktop/settings"
    link_config_dir "$VESKTOP_SRC/themes" "$HOME/.config/vesktop/themes"
    link_config_file "$VESKTOP_SRC/settings/settings.json" "$HOME/.config/vesktop/settings/settings.json"
  else
    echo "No vesktop config found. Skipping link."
  fi
fi
