#!/usr/bin/env bash
set -euo pipefail

ensure_helper() {
  if command -v paru >/dev/null 2>&1; then
    echo "Using paru."
    return 0
  fi
  if command -v yay >/dev/null 2>&1; then
    echo "Using yay."
    return 0
  fi

  echo "No AUR helper found. Install one:"
  local options=("paru" "yay" "quit")
  local choice

  if command -v fzf >/dev/null 2>&1; then
    choice=$(printf '%s\n' "${options[@]}" | fzf --prompt="Select helper > " --height=40% --layout=reverse)
  else
    echo "Select helper:"
    select choice in "${options[@]}"; do
      break
    done
  fi

  case "${choice:-}" in
    paru)
      sudo pacman -S --needed --noconfirm base-devel git
      tmp_dir=$(mktemp -d)
      git clone https://aur.archlinux.org/paru.git "$tmp_dir/paru"
      (cd "$tmp_dir/paru" && makepkg -si --noconfirm)
      rm -rf "$tmp_dir"
      ;;
    yay)
      sudo pacman -S --needed --noconfirm base-devel git
      tmp_dir=$(mktemp -d)
      git clone https://aur.archlinux.org/yay.git "$tmp_dir/yay"
      (cd "$tmp_dir/yay" && makepkg -si --noconfirm)
      rm -rf "$tmp_dir"
      ;;
    *)
      exit 0
      ;;
  esac
}

install_pkg() {
  local pkg="$1"
  if command -v paru >/dev/null 2>&1; then
    paru -S --needed --noconfirm "$pkg"
  elif command -v yay >/dev/null 2>&1; then
    yay -S --needed --noconfirm "$pkg"
  else
    echo "Error: No AUR helper available."
    exit 1
  fi
}

ask_yes() {
  local prompt="$1"
  local answer=""
  if command -v fzf >/dev/null 2>&1; then
    answer=$(printf '%s\n' "yes" "no" | fzf --prompt="$prompt > " --height=40% --layout=reverse)
  else
    read -rp "$prompt (y/N): " answer
  fi
  [[ "$answer" =~ ^([Yy]|yes)$ ]]
}

link_config_dir() {
  local src="$1"
  local dest="$2"

  if [ ! -d "$src" ]; then
    echo "Warning: $src not found. Skipping."
    return 0
  fi

  mkdir -p "$HOME/.config"
  if [ -L "$dest" ]; then
    local current
    current="$(readlink -f "$dest" || true)"
    if [ "$current" = "$src" ]; then
      echo "Config already linked: $dest -> $src"
      return 0
    fi
  fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    local backup="${dest}.bak.$(date +%Y%m%d%H%M%S)"
    mv "$dest" "$backup"
    echo "Backed up existing config: $dest -> $backup"
  fi
  ln -s "$src" "$dest"
  echo "Linked config: $dest -> $src"
}
