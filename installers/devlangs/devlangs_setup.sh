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

pick_langs() {
  local options=(
    "gcc"
    "clang"
    "go"
    "lua"
    "luajit"
    "luarocks"
    "fpc"
    "python"
    "python-pip"
    "python-libtmux"
    "python-pynvim"
    "python-pytest"
    "rustup"
    "all"
    "quit"
  )
  if command -v fzf >/dev/null 2>&1; then
    printf '%s\n' "${options[@]}" | fzf --prompt="Select language toolchain (multi-select) > " --height=50% --layout=reverse --multi
    return
  fi

  echo "Select language toolchains (space-separated numbers):"
  select opt in "${options[@]}"; do
    echo "$opt"
    return
  done
}

ensure_helper

selection=$(pick_langs || true)
if [ -z "${selection:-}" ]; then
  exit 0
fi

if echo "$selection" | grep -q "all"; then
  enable_set=(
    "gcc"
    "clang"
    "go"
    "lua"
    "luajit"
    "luarocks"
    "fpc"
    "python"
    "python-pip"
    "python-libtmux"
    "python-pynvim"
    "python-pytest"
    "rustup"
  )
else
  mapfile -t enable_set < <(printf '%s\n' "$selection")
fi

for lang in "${enable_set[@]}"; do
  case "$lang" in
    gcc|clang|go|lua|luajit|luarocks|fpc|python|python-pip|python-libtmux|python-pynvim|python-pytest)
      install_pkg "$lang"
      ;;
    rustup)
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
      ;;
    *)
      ;;
  esac
done
