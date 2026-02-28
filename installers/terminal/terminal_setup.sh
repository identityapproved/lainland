#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

ALACRITTY_SRC="$ROOT_DIR/alacritty"
KITTY_SRC="$ROOT_DIR/kitty"
GHOSTTY_SRC="$ROOT_DIR/ghostty"
COMMON_LIB="$SCRIPT_DIR/../lib/common.sh"

if [ -f "$COMMON_LIB" ]; then
  # shellcheck source=/dev/null
  source "$COMMON_LIB"
else
  echo "Error: Missing common library at $COMMON_LIB"
  exit 1
fi

setup_alacritty() {
  ensure_helper
  echo "Installing alacritty..."
  install_pkg alacritty
  link_config_dir "$ALACRITTY_SRC" "$HOME/.config/alacritty"
}

setup_kitty() {
  ensure_helper
  echo "Installing kitty..."
  install_pkg kitty
  link_config_dir "$KITTY_SRC" "$HOME/.config/kitty"
}

setup_ghostty() {
  ensure_helper
  echo "Installing ghostty..."
  install_pkg ghostty
  link_config_dir "$GHOSTTY_SRC" "$HOME/.config/ghostty"
}

choose_terminal() {
  local options=("alacritty" "kitty" "ghostty" "all" "quit")
  if command -v fzf >/dev/null 2>&1; then
    printf '%s\n' "${options[@]}" | fzf --prompt="Select terminal to setup > " --height=40% --layout=reverse
    return
  fi

  echo "Select terminal to setup:"
  select choice in "${options[@]}"; do
    echo "$choice"
    return
  done
}

choice=$(choose_terminal)
case "$choice" in
  alacritty)
    setup_alacritty
    ;;
  kitty)
    setup_kitty
    ;;
  all)
    setup_alacritty
    setup_kitty
    setup_ghostty
    ;;
  *)
    exit 0
    ;;
esac

remove_others() {
  local choices=("yes" "no")
  local answer=""
  if command -v fzf >/dev/null 2>&1; then
    answer=$(printf '%s\n' "${choices[@]}" | fzf --prompt="Remove other terminals? > " --height=40% --layout=reverse)
  else
    read -rp "Remove other terminals? (y/N): " answer
  fi

  [[ "$answer" =~ ^([Yy]|yes)$ ]]
}

if remove_others; then
  to_remove=()
  case "$choice" in
    alacritty) to_remove=(kitty ghostty) ;;
    kitty) to_remove=(alacritty ghostty) ;;
    ghostty) to_remove=(alacritty kitty) ;;
    all) to_remove=() ;;
    *) to_remove=() ;;
  esac

  for pkg in "${to_remove[@]}"; do
    if command -v paru >/dev/null 2>&1; then
      paru -Rns --noconfirm "$pkg"
    elif command -v yay >/dev/null 2>&1; then
      yay -Rns --noconfirm "$pkg"
    fi
  done
fi
