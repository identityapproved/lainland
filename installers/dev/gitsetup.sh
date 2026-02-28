#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
COMMON_LIB="$SCRIPT_DIR/../lib/common.sh"
LAZYGIT_SRC="$ROOT_DIR/lazygit"
DELTA_SRC="$ROOT_DIR/delta"

if [ -f "$COMMON_LIB" ]; then
  # shellcheck source=/dev/null
  source "$COMMON_LIB"
else
  echo "Error: Missing common library at $COMMON_LIB"
  exit 1
fi

ensure_helper

echo "Installing Git tooling (git-delta, lazygit)..."
install_pkg git-delta
install_pkg lazygit

if [ -d "$LAZYGIT_SRC" ]; then
  link_config_dir "$LAZYGIT_SRC" "$HOME/.config/lazygit"
else
  echo "No lazygit config found. Skipping link."
fi

if [ -d "$DELTA_SRC" ]; then
  link_config_dir "$DELTA_SRC" "$HOME/.config/delta"
else
  echo "No delta config found. Skipping link."
fi

# Prompt for user.name and user.email
read -rp "Enter your Git user.name: " git_name
read -rp "Enter your Git user.email: " git_email

# Set up global Git configuration
git config --global user.name "$git_name"
git config --global user.email "$git_email"
git config --global rerere.enabled true
git config --global merge.tool vimdiff
git config --global merge.conflictstyle zdiff3
git config --global mergetool.prompt false
git config --global help.autocorrect prompt

# Delta integration
git config --global core.pager delta
git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate true
git config --global delta.line-numbers true
git config --global delta.side-by-side true
git config --global delta.features lain

if ! git config --global --get-all include.path | grep -Fxq "~/.config/delta/themes.gitconfig"; then
  git config --global --add include.path "~/.config/delta/themes.gitconfig"
fi

echo "Git + delta configuration has been updated."
echo "Lazygit is configured to use delta for diff paging if delta is installed."
echo "SSH key generation skipped in this script."
