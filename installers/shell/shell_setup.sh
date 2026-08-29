#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
COMMON_LIB="$SCRIPT_DIR/../lib/common.sh"

# No *_SRC paths here any more: ~/.zshrc, ~/.config/fish and
# ~/.config/dircolors are chezmoi-managed (home/ in this repo). These functions
# install the shells and their plugin managers; `chezmoi apply` supplies the
# configuration.

if [ -f "$COMMON_LIB" ]; then
  # shellcheck source=/dev/null
  source "$COMMON_LIB"
else
  echo "Error: Missing common library at $COMMON_LIB"
  exit 1
fi

setup_zsh() {
  ensure_helper
  echo "Installing zsh..."
  install_pkg zsh

  if [ -d "$HOME/.oh-my-zsh" ]; then
    bash "$SCRIPT_DIR/zsh_plugins.sh"
  else
    echo "Oh My Zsh not found. Skipping zsh plugin install."
  fi
}

setup_fish() {
  ensure_helper
  echo "Installing fish..."
  install_pkg fish

  echo "Adding fish vi keybindings and installing fisher + fzf.fish..."
  fish --no-config -c "grep -qx 'fish_vi_key_bindings' ~/.config/fish/config.fish; or echo 'fish_vi_key_bindings' >> ~/.config/fish/config.fish"
  fish --no-config -c '
    if not functions -q fisher
      curl -sL https://git.io/fisher | source
      fisher install jorgebucaran/fisher
    end
    fisher install PatrickF1/fzf.fish
  '
}

set_default_shell() {
  local shell_path="$1"
  read -rp "Set default shell to $shell_path? (y/N): " response
  if [[ "$response" =~ ^[Yy]$ ]]; then
    chsh -s "$shell_path"
  fi
}

choose_shell() {
  local options=("zsh" "fish" "both" "quit")
  if command -v fzf >/dev/null 2>&1; then
    printf '%s\n' "${options[@]}" | fzf --prompt="Select shell to setup > " --height=40% --layout=reverse
    return
  fi

  echo "Select shell to setup:"
  select choice in "${options[@]}"; do
    echo "$choice"
    return
  done
}

choice=$(choose_shell)
case "$choice" in
  zsh)
    setup_zsh
    set_default_shell "$(command -v zsh)"
    ;;
  fish)
    setup_fish
    set_default_shell "$(command -v fish)"
    ;;
  both)
    setup_zsh
    setup_fish
    ;;
  *)
    exit 0
    ;;
esac
