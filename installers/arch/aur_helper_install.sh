#!/usr/bin/env bash
set -euo pipefail

if [ ! -f "/etc/arch-release" ]; then
  echo "Error: This script is intended for Arch Linux. Exiting."
  exit 1
fi

echo "System is Arch Linux."

if command -v paru >/dev/null 2>&1; then
  echo "paru is already installed."
  exit 0
fi

if command -v yay >/dev/null 2>&1; then
  echo "yay is already installed."
  exit 0
fi

options=("paru" "yay" "quit")
choice=""

if command -v fzf >/dev/null 2>&1; then
  choice=$(printf '%s\n' "${options[@]}" | fzf --prompt="Select AUR helper > " --height=40% --layout=reverse)
else
  echo "Select AUR helper to install:"
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

if ! command -v paru >/dev/null 2>&1 && ! command -v yay >/dev/null 2>&1; then
  echo "Error: Failed to install AUR helper."
  exit 1
fi
