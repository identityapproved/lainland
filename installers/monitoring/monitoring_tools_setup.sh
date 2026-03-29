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

configure_auditd() {
  local auditd_conf="/etc/audit/auditd.conf"
  local augenrules_output=""

  echo "[*] Installing auditd baseline..."
  install_pkg audit
  install_pkg jq

  sudo install -Dm644 "$ROOT_DIR/monitoring/audit/rules.d/hardening.rules" /etc/audit/rules.d/hardening.rules

  if [ -f "$auditd_conf" ]; then
    sudo cp "$auditd_conf" "$auditd_conf.bak.$(date +%Y%m%d%H%M%S)"
    while IFS='=' read -r key value; do
      key="$(printf '%s' "$key" | xargs)"
      value="$(printf '%s' "$value" | xargs)"
      [ -z "$key" ] && continue

      if sudo grep -Eq "^[[:space:]]*$key[[:space:]]*=" "$auditd_conf"; then
        sudo sed -i -E "s|^[[:space:]]*$key[[:space:]]*=.*|$key = $value|" "$auditd_conf"
      else
        echo "$key = $value" | sudo tee -a "$auditd_conf" >/dev/null
      fi
    done < "$ROOT_DIR/monitoring/audit/auditd.conf"
  fi

  sudo install -d -m 0700 /var/log/audit
  sudo touch /var/log/audit/audit.log
  sudo chmod 0600 /var/log/audit/audit.log

  augenrules_output="$(sudo augenrules --load 2>&1)" || {
    if printf '%s\n' "$augenrules_output" | grep -Fq 'Rule exists'; then
      echo "[*] audit rules already loaded; keeping current kernel rules."
    else
      printf '%s\n' "$augenrules_output" >&2
      return 1
    fi
  }

  if [ -n "$augenrules_output" ] && ! printf '%s\n' "$augenrules_output" | grep -Fq 'Rule exists'; then
    printf '%s\n' "$augenrules_output"
  fi

  sudo systemctl enable auditd

  if ! systemctl is-active --quiet auditd; then
    sudo systemctl start auditd
  fi

  echo "[*] auditd rules loaded."
  echo "[*] If auditd was already running, reboot or use your distro-approved auditd reload path if needed."
}

ensure_helper

if ask_yes "Install and configure auditd baseline?"; then
  configure_auditd
fi
