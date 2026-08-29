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

# Config linking is chezmoi's job now, not the installers'. The repo no longer
# has top-level per-app directories to link from -- they live under
# home/dot_config/ as a chezmoi source tree, applied with:
#
#   chezmoi init --apply <this repo>
#
# The call sites below are left in place because they document which installer
# owns which config; this stub keeps them harmless. Delete a call only when the
# installer itself goes away.
link_config_dir() {
  local dest="${2:-}"
  echo "Skipping link for ${dest:-config}: linking is handled by chezmoi apply."
  return 0
}
