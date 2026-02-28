#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

scripts=(
  "arch/arch_install.sh"
  "arch/aur_helper_install.sh"
  "dev/gitsetup.sh"
  "devlangs/devlangs_setup.sh"
  "fonts/fonts_setup.sh"
  "gaming/gaming_setup.sh"
  "linking/simlinking.sh"
  "hyprland/hyprland_tools_setup.sh"
  "browsers/browser_setup.sh"
  "media/media_setup.sh"
  "readers/reader_setup.sh"
  "reverse/reverseeng_tools.sh"
  "security/security_tools_setup.sh"
  "shell/shell_setup.sh"
  "terminal/terminal_setup.sh"
  "virtualization/virtmanager.sh"
  "virtualization/virtualboxinstall.sh"
)

run_script() {
  local rel="$1"
  local path="$ROOT_DIR/$rel"
  if [ ! -x "$path" ]; then
    chmod +x "$path"
  fi
  echo "Running: $rel"
  "$path"
}

if command -v fzf >/dev/null 2>&1; then
  choice=$(printf '%s\n' "${scripts[@]}" | fzf --prompt="Select installer > " --height=60% --layout=reverse)
  if [ -n "${choice:-}" ]; then
    run_script "$choice"
  fi
  exit 0
fi

echo "Select installer:"
select choice in "${scripts[@]}" "Quit"; do
  case "$choice" in
    "Quit"|"") exit 0 ;;
    *) run_script "$choice" ;;
  esac
done
