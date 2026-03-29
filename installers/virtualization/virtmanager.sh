#!/usr/bin/env bash
set -euo pipefail

VIRT_PACKAGES=(
  virt-manager
  qemu-full
  libvirt
  edk2-ovmf
  dnsmasq
  vde2
  bridge-utils
  openbsd-netcat
  virt-viewer
)

VIRTUALBOX_PACKAGES=(
  virtualbox
  virtualbox-ext-oracle
  virtualbox-host-modules-arch
  virtualbox-host-dkms
)

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

choose_action() {
  local choice=""
  if command_exists fzf; then
    choice=$(printf '%s\n' "install" "remove" | fzf --prompt="virt-manager action > " --height=40% --layout=reverse)
  else
    read -rp "Choose action (install/remove) [install]: " choice
    choice="${choice:-install}"
  fi
  printf '%s\n' "$choice"
}

ask_yes() {
  local prompt="$1"
  local answer=""
  if command_exists fzf; then
    answer=$(printf '%s\n' "yes" "no" | fzf --prompt="$prompt > " --height=40% --layout=reverse)
  else
    read -rp "$prompt (y/N): " answer
  fi
  [[ "$answer" =~ ^([Yy]|yes)$ ]]
}

install_packages() {
  if command_exists yay; then
    yay -S --needed --noconfirm "$@"
  else
    sudo pacman -S --needed --noconfirm "$@"
  fi
}

remove_packages() {
  local installed=()
  local removed=()
  local skipped=()
  for pkg in "$@"; do
    if pacman -Q "$pkg" >/dev/null 2>&1; then
      installed+=("$pkg")
    fi
  done

  if [ "${#installed[@]}" -eq 0 ]; then
    echo "[*] No virtualization packages from this stack are currently installed."
    return 0
  fi

  for pkg in "${installed[@]}"; do
    if command_exists yay; then
      if yay -Rns --noconfirm "$pkg" >/dev/null 2>&1; then
        removed+=("$pkg")
      else
        skipped+=("$pkg")
      fi
    else
      if sudo pacman -Rns --noconfirm "$pkg" >/dev/null 2>&1; then
        removed+=("$pkg")
      else
        skipped+=("$pkg")
      fi
    fi
  done

  if [ "${#removed[@]}" -gt 0 ]; then
    echo "[*] Removed packages:"
    printf '    - %s\n' "${removed[@]}"
  fi

  if [ "${#skipped[@]}" -gt 0 ]; then
    echo "[*] Kept packages with active dependencies:"
    printf '    - %s\n' "${skipped[@]}"
  fi
}

if [ ! -f /etc/arch-release ]; then
  echo "Error: This script is intended for Arch Linux."
  exit 1
fi

action="${1:-$(choose_action)}"

case "$action" in
  install)
    echo "[*] Installing virtualization stack..."
    install_packages "${VIRT_PACKAGES[@]}"

    echo "[*] Enabling libvirt..."
    sudo systemctl enable --now libvirtd

    echo "[*] Adding current user to libvirt and kvm groups..."
    sudo usermod -aG libvirt "$USER"
    sudo usermod -aG kvm "$USER"

    echo "[*] Autostarting default libvirt network (if available)..."
    sudo virsh net-autostart default >/dev/null 2>&1 || true
    sudo virsh net-start default >/dev/null 2>&1 || true

    if command_exists ufw; then
      echo "[*] Optional UFW route rules for libvirt/proton routing:"
      echo "    allow  virbr0 -> proton0"
      echo "    allow  proton0 -> virbr0"
      echo "    deny   virbr0 -> enp7s0"
      echo "    (interface names are machine-specific)"
      if ask_yes "Apply these UFW route rules if missing?"; then
        ufw_status="$(sudo ufw status 2>/dev/null || true)"

        if ! printf '%s\n' "$ufw_status" | grep -Fq "virbr0 on proton0"; then
          sudo ufw route allow in on virbr0 out on proton0 || true
        fi
        if ! printf '%s\n' "$ufw_status" | grep -Fq "proton0 on virbr0"; then
          sudo ufw route allow in on proton0 out on virbr0 || true
        fi
        if ! printf '%s\n' "$ufw_status" | grep -Fq "virbr0 on enp7s0"; then
          sudo ufw route deny in on virbr0 out on enp7s0 || true
        fi
      else
        echo "[*] Skipping UFW route rules."
      fi
    else
      echo "[*] UFW not installed; skipping UFW route rules."
    fi

    echo
    echo "Installation complete."
    echo "Log out and back in for libvirt group changes to take effect."
    echo "Then run: virt-manager"
    ;;
  remove)
    echo "[*] Removing virt-manager/libvirt virtualization stack..."
    echo "[*] Stopping and disabling libvirtd..."
    sudo systemctl disable --now libvirtd >/dev/null 2>&1 || true

    echo "[*] Removing virtualization packages..."
    remove_packages "${VIRT_PACKAGES[@]}"

    echo "[*] VirtualBox protection check:"
    for pkg in "${VIRTUALBOX_PACKAGES[@]}"; do
      if pacman -Q "$pkg" >/dev/null 2>&1; then
        echo "    kept: $pkg"
      fi
    done

    echo
    echo "Removal complete."
    echo "Any installed VirtualBox packages were intentionally not touched."
    ;;
  *)
    echo "Usage: $0 [install|remove]"
    exit 1
    ;;
esac
