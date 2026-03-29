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

choose_one() {
  local prompt="$1"
  shift
  local options=("$@")
  local choice=""

  if command -v fzf >/dev/null 2>&1; then
    choice="$(printf '%s\n' "${options[@]}" | fzf --prompt="$prompt > " --height=40% --layout=reverse)"
  else
    echo "$prompt"
    select choice in "${options[@]}"; do
      break
    done
  fi

  printf '%s\n' "${choice:-}"
}

ensure_helper

echo "[*] Installing containerization core (Podman)..."
install_pkg podman
install_pkg podman-compose
install_pkg podman-docker

ui_choice="$(choose_one "Install optional Podman UI" "podman-desktop" "podman-tui" "skip")"
case "${ui_choice:-skip}" in
  podman-desktop)
    install_pkg podman-desktop
    ;;
  podman-tui)
    install_pkg podman-tui
    ;;
  *)
    echo "Skipping optional Podman UI."
    ;;
esac

if ask_yes "Enable user lingering for rootless Podman services?"; then
  sudo loginctl enable-linger "$USER"
  echo "Enabled lingering for $USER."
fi

if ask_yes "Enable and start rootless Podman socket (podman.socket)?"; then
  systemctl --user enable --now podman.socket
  systemctl --user status podman.socket --no-pager || true
fi

if ask_yes "Enable and start rootless Podman service (podman.service)?"; then
  systemctl --user enable --now podman.service
  systemctl --user status podman.service --no-pager || true
fi

# Docker template (disabled by default)
# if ask_yes "Install Docker template stack?"; then
#   install_pkg docker
#   install_pkg docker-compose
#   sudo systemctl enable --now docker
# fi

echo
echo "Containerization setup complete."
echo "Try: podman info"
