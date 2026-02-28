#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
COMMON_LIB="$SCRIPT_DIR/../lib/common.sh"

SIOYEK_SRC="$ROOT_DIR/sioyek"
ZATHURA_SRC="$ROOT_DIR/zathura"

if [ -f "$COMMON_LIB" ]; then
  # shellcheck source=/dev/null
  source "$COMMON_LIB"
else
  echo "Error: Missing common library at $COMMON_LIB"
  exit 1
fi

ensure_helper

reader_choice=""
readers=("zathura" "sioyek" "quit")

if command -v fzf >/dev/null 2>&1; then
  reader_choice=$(printf '%s\n' "${readers[@]}" | fzf --prompt="Select reader > " --height=40% --layout=reverse)
else
  echo "Select reader:"
  select reader_choice in "${readers[@]}"; do
    break
  done
fi

case "${reader_choice:-}" in
  zathura)
    install_pkg zathura
    install_pkg zathura-cb
    install_pkg zathura-djvu
    install_pkg zathura-pdf-mupdf
    install_pkg zathura-ps
    link_config_dir "$ZATHURA_SRC" "$HOME/.config/zathura"
    ;;
  sioyek)
    install_pkg sioyek
    link_config_dir "$SIOYEK_SRC" "$HOME/.config/sioyek"
    ;;
  *)
    exit 0
    ;;
esac
