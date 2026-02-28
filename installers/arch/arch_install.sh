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
BASE_LIST="$SCRIPT_DIR/base_tools_list.txt"
OPTIONAL_LIST="$SCRIPT_DIR/optional_tools_list.txt"
ADDITIONAL_PKGS=("git" "base-devel")

if [ ! -f "/etc/arch-release" ]; then
  echo "Error: This script is intended for Arch Linux. Exiting."
  exit 1
fi

echo "System is Arch Linux."
if ! command -v paru >/dev/null 2>&1 && ! command -v yay >/dev/null 2>&1; then
  echo "No AUR helper found. Running aur_helper_install.sh..."
  bash "$SCRIPT_DIR/aur_helper_install.sh"
fi

if ! command -v paru >/dev/null 2>&1 && ! command -v yay >/dev/null 2>&1; then
  echo "Error: No AUR helper found (paru or yay). Exiting."
  exit 1
fi

link_config_name() {
  local name="$1"
  link_config_dir "$ROOT_DIR/$name" "$HOME/.config/$name"
}

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

if [ ! -f "$BASE_LIST" ]; then
  echo "Error: Base tools list not found at $BASE_LIST"
  exit 1
fi

for pkg in "${ADDITIONAL_PKGS[@]}"; do
  install_pkg "$pkg"
done

while IFS= read -r tool; do
  [[ -z "$tool" || "$tool" =~ ^# ]] && continue
  install_pkg "$tool"
  link_config_name "$tool"
done < "$BASE_LIST"

if grep -Eq '^[[:space:]]*task[[:space:]]*$' "$BASE_LIST"; then
  cat <<'EOF'

Taskwarrior note:
  If your task data lives outside the default path, update:
    ~/.config/task/taskrc
  Example:
    data.location=$HOME/drives/kodak/taskwarrior/task

EOF
fi

if [ -f "$OPTIONAL_LIST" ]; then
  mail_choice="$(choose_option "Optional mail client (choose one)" "betterbird" "thunderbird" "skip")"
  case "${mail_choice:-skip}" in
    betterbird|thunderbird)
      install_pkg "$mail_choice"
      link_config_name "$mail_choice"
      ;;
    *)
      ;;
  esac

  while IFS= read -r tool; do
    [[ -z "$tool" || "$tool" =~ ^# ]] && continue
    [[ "$tool" == "betterbird" || "$tool" == "thunderbird" ]] && continue
    read -rp "Install optional package '$tool'? (y/N): " opt_choice
    if [[ "$opt_choice" =~ ^[Yy]$ ]]; then
      install_pkg "$tool"
      link_config_name "$tool"
    fi
  done < "$OPTIONAL_LIST"
fi
