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

ensure_helper

if ask_yes "Setup and configure UFW firewall?"; then
  bash "$SCRIPT_DIR/ufw_install_and_configure.sh"
fi

if ask_yes "Install Proton VPN (GUI)?"; then
  install_pkg proton-vpn-gtk-app
fi

if ask_yes "Install Bitwarden?"; then
  install_pkg bitwarden
fi

if ask_yes "Install Bitwarden CLI?"; then
  install_pkg bitwarden-cli
fi
