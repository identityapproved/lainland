#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON_LIB="$SCRIPT_DIR/../lib/common.sh"

if [ -f "$COMMON_LIB" ]; then
  # shellcheck source=/dev/null
  source "$COMMON_LIB"
else
  echo "Error: Missing common library at $COMMON_LIB"
  exit 1
fi

choose_option() {
  local prompt="$1"
  shift
  local options=("$@")
  local choice=""
  if command -v fzf >/dev/null 2>&1; then
    choice=$(printf '%s\n' "${options[@]}" | fzf --prompt="$prompt > " --height=40% --layout=reverse)
  else
    echo "$prompt"
    select choice in "${options[@]}"; do
      break
    done
  fi
  printf '%s\n' "${choice:-}"
}

detect_gpu_vendor() {
  if ! command -v lspci >/dev/null 2>&1; then
    return 1
  fi

  local gpu_info
  gpu_info="$(lspci | grep -Ei 'VGA|3D|Display' || true)"

  if echo "$gpu_info" | grep -qi 'NVIDIA'; then
    echo "nvidia"
    return 0
  fi
  if echo "$gpu_info" | grep -qiE 'AMD|ATI|Radeon'; then
    echo "amd"
    return 0
  fi
  if echo "$gpu_info" | grep -qi 'Intel'; then
    echo "intel"
    return 0
  fi
  return 1
}

detect_gpu_info() {
  if ! command -v lspci >/dev/null 2>&1; then
    return 1
  fi
  lspci | grep -Ei 'VGA|3D|Display' || true
}

gpu_packages_for_vendor() {
  case "$1" in
    amd)
      printf '%s\n' mesa vulkan-radeon lib32-mesa lib32-vulkan-radeon
      ;;
    nvidia)
      printf '%s\n' nvidia nvidia-utils lib32-nvidia-utils
      ;;
    intel)
      printf '%s\n' mesa vulkan-intel lib32-mesa lib32-vulkan-intel
      ;;
    *)
      return 1
      ;;
  esac
}

install_many() {
  local pkg
  for pkg in "$@"; do
    install_pkg "$pkg"
  done
}

ensure_helper

echo "Gaming setup (Arch)."
echo "If you need Steam/Proton, make sure multilib is enabled (preferably in archinstall -> Additional repositories -> multilib)."
if ! ask_yes "Continue with gaming setup?"; then
  exit 0
fi

echo "[1/6] Installing Steam + core gaming stack..."
install_many \
  steam \
  gamemode \
  mangohud \
  gamescope \
  lib32-gamemode \
  lib32-mangohud

echo "[2/6] GPU driver stack"
gpu_vendor="$(detect_gpu_vendor || true)"
gpu_info="$(detect_gpu_info || true)"
if [ -n "${gpu_vendor:-}" ]; then
  echo "Detected via lspci:"
  [ -n "${gpu_info:-}" ] && printf '  %s\n' "$gpu_info"
  echo "Detected GPU vendor: $gpu_vendor"
  echo "Will install packages:"
  gpu_packages_for_vendor "$gpu_vendor" | sed 's/^/  - /'
  if ! ask_yes "OK to install detected GPU stack?"; then
    gpu_vendor=""
  fi
fi

if [ -z "${gpu_vendor:-}" ]; then
  gpu_vendor="$(choose_option "Select GPU vendor" "amd" "nvidia" "intel" "skip")"
fi

case "${gpu_vendor:-skip}" in
  amd)
    install_many $(gpu_packages_for_vendor amd)
    ;;
  nvidia)
    install_many $(gpu_packages_for_vendor nvidia)
    ;;
  intel)
    install_many $(gpu_packages_for_vendor intel)
    ;;
  *)
    echo "Skipping GPU driver stack installation."
    ;;
esac

echo "[3/6] Installing extra compatibility libraries/tools..."
install_many wine winetricks vulkan-tools goverlay

echo "[4/6] Optional apps"
if ask_yes "Install obs-studio?"; then
  install_pkg obs-studio
fi

chat_choice="$(choose_option "Select one chat app (Discord family)" "vesktop" "discord" "vencord" "skip")"
case "${chat_choice:-skip}" in
  discord)
    install_pkg discord
    ;;
  vesktop)
    install_pkg vesktop
    ;;
  vencord)
    if ! install_pkg vencord; then
      echo "Package 'vencord' failed. Try your preferred package manually (e.g. a *-bin variant)."
    fi
    ;;
  *)
    echo "Skipping Discord-family app installation."
    ;;
esac

echo "[5/6] Proton + compatibility tools"
if ask_yes "Install proton-ge-custom?"; then
  install_pkg proton-ge-custom
  echo "Installed proton-ge-custom (AUR) for Steam compatibility tools."
fi

echo "[6/6] Optional performance kernel tweaks"
if ask_yes "Install linux-zen and linux-zen-headers?"; then
  install_many linux-zen linux-zen-headers
  echo "Select linux-zen in your bootloader after installation."
fi

echo
echo "Gaming setup complete."
echo "Suggested: reboot after installations (especially GPU drivers / kernel changes)."
