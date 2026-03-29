#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
COMMON_LIB="$SCRIPT_DIR/../lib/common.sh"
KEYBINDS_FILE="$ROOT_DIR/hypr/configs/keybinds.conf"
VOICE_BIND_PATTERN="hyprvoice toggle"

if [ -f "$COMMON_LIB" ]; then
  # shellcheck source=/dev/null
  source "$COMMON_LIB"
else
  echo "Error: Missing common library at $COMMON_LIB"
  exit 1
fi

ensure_helper

remove_pkg_if_installed() {
  local pkg="$1"
  if ! pacman -Qi "$pkg" >/dev/null 2>&1; then
    echo "$pkg is not installed. Skipping."
    return 0
  fi

  if command -v paru >/dev/null 2>&1; then
    paru -Rns --noconfirm "$pkg" || true
  elif command -v yay >/dev/null 2>&1; then
    yay -Rns --noconfirm "$pkg" || true
  else
    echo "No AUR helper found for package removal. Skipping $pkg."
  fi
}

pick_voice_packages() {
  local options=("hyprvoice-bin" "wtype" "ydotool" "done")
  local picked=()
  local choice=""

  if command -v fzf >/dev/null 2>&1; then
    while true; do
      choice="$(printf '%s\n' "${options[@]}" | fzf --prompt="Voice package (pick one, repeat, done to finish) > " --height=40% --layout=reverse)" || true
      if [ -z "${choice:-}" ] || [ "$choice" = "done" ]; then
        break
      fi
      if [[ " ${picked[*]} " != *" $choice "* ]]; then
        picked+=("$choice")
        echo "Queued: $choice"
      fi
    done
  else
    echo "Select voice packages to install (choose repeatedly, then done):"
    while true; do
      select choice in "${options[@]}"; do
        break
      done
      if [ -z "${choice:-}" ] || [ "$choice" = "done" ]; then
        break
      fi
      if [[ " ${picked[*]} " != *" $choice "* ]]; then
        picked+=("$choice")
        echo "Queued: $choice"
      fi
    done
  fi

  printf '%s\n' "${picked[@]}"
}

if ask_yes "Remove voice input stack (hyprvoice-bin, wtype, ydotool) and disable service?"; then
  systemctl --user disable --now hyprvoice.service >/dev/null 2>&1 || true
  remove_pkg_if_installed hyprvoice-bin
  remove_pkg_if_installed wtype
  remove_pkg_if_installed ydotool

  if [ -f "$KEYBINDS_FILE" ] && rg -q "$VOICE_BIND_PATTERN" "$KEYBINDS_FILE"; then
    if ask_yes "Remove Hyprvoice keybind lines from keybinds.conf?"; then
      sed -i '/# Hyprvoice/d;/hyprvoice toggle/d' "$KEYBINDS_FILE"
      echo "Removed Hyprvoice keybind lines from $KEYBINDS_FILE"
      echo "Reload Hyprland config: hyprctl reload"
    fi
  fi

  echo "Voice input removal complete."
  exit 0
fi

mapfile -t selected_packages < <(pick_voice_packages)

if [ "${#selected_packages[@]}" -eq 0 ]; then
  echo "No packages selected. Nothing to install."
  exit 0
fi

for pkg in "${selected_packages[@]}"; do
  install_pkg "$pkg"
done

hyprvoice_enabled=false
if [[ " ${selected_packages[*]} " == *" hyprvoice-bin "* ]]; then
  hyprvoice_enabled=true
fi

if $hyprvoice_enabled; then
  if ask_yes "Add current user to input group (required for some Hyprvoice input backends)?"; then
    sudo usermod -aG input "$USER"
    echo "Added $USER to input group. Re-login is required for group membership to apply."
  fi

  if ask_yes "Run 'hyprvoice onboarding' now?"; then
    hyprvoice onboarding
  else
    echo "Run later: hyprvoice onboarding"
  fi

  if ask_yes "Enable and start hyprvoice user service now?"; then
    systemctl --user enable --now hyprvoice.service
    systemctl --user status hyprvoice.service --no-pager || true
  else
    echo "Run later: systemctl --user enable --now hyprvoice.service"
  fi

  if [ -f "$KEYBINDS_FILE" ]; then
    bind_line='bindd = $mainMod ALT, R, Toggle Hyprvoice dictation, exec, hyprvoice toggle'
    if ! rg -q "$VOICE_BIND_PATTERN" "$KEYBINDS_FILE"; then
      if ask_yes "Add Hyprland keybind (Mod+Alt+R) for hyprvoice toggle?"; then
        printf '\n# Hyprvoice\n%s\n' "$bind_line" >> "$KEYBINDS_FILE"
        echo "Added keybind to $KEYBINDS_FILE"
        echo "Reload Hyprland config: hyprctl reload"
      fi
    else
      echo "Hyprvoice keybind already exists in $KEYBINDS_FILE"
    fi
  fi
fi

echo
echo "Voice input setup complete."
echo "Useful commands:"
echo "  hyprvoice configure"
echo "  hyprvoice toggle"
echo "  hyprvoice cancel"
echo "  hyprvoice status"
echo "  journalctl --user -u hyprvoice.service -f"
