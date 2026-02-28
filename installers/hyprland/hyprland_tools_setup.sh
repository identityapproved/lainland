#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
COMMON_LIB="$SCRIPT_DIR/../lib/common.sh"

if [ -f "$COMMON_LIB" ]; then
  # shellcheck source=/dev/null
  source "$COMMON_LIB"
else
  echo "Error: Missing common library at $COMMON_LIB"
  exit 1
fi

ensure_helper

install_pkg waybar
install_pkg wl-clipboard
install_pkg wlogout
install_pkg wofi
install_pkg mako
install_pkg libnotify
install_pkg hyprlock
install_pkg swappy
install_pkg rmatrix
install_pkg rbonsai
install_pkg polkit-gnome

link_config_dir "$ROOT_DIR/waybar" "$HOME/.config/waybar"
link_config_dir "$ROOT_DIR/wlogout" "$HOME/.config/wlogout"
link_config_dir "$ROOT_DIR/wofi" "$HOME/.config/wofi"
link_config_dir "$ROOT_DIR/mako" "$HOME/.config/mako"
link_config_dir "$ROOT_DIR/hypr" "$HOME/.config/hypr"
link_config_dir "$ROOT_DIR/wallpapers" "$HOME/.config/wallpapers"

wallpaper_options=("hyprpaper" "wpaperd" "skip")
wallpaper_choice=""

if command -v fzf >/dev/null 2>&1; then
  wallpaper_choice=$(printf '%s\n' "${wallpaper_options[@]}" | fzf --prompt="Select wallpaper tool > " --height=40% --layout=reverse)
else
  echo "Select wallpaper tool:"
  select wallpaper_choice in "${wallpaper_options[@]}"; do
    break
  done
fi

case "${wallpaper_choice:-}" in
  hyprpaper)
    install_pkg hyprpaper
    echo "If wpaperd is installed, remove it and uncomment hyprpaper in your hyprland.conf."
    ;;
  wpaperd)
    install_pkg wpaperd
    link_config_dir "$ROOT_DIR/wpaperd" "$HOME/.config/wpaperd"
    ;;
  *)
    ;;
esac
