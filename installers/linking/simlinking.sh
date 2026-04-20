#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONFIG_DIR="$HOME/.config"

# Check if the script is being run from the dotfiles directory
# if [ "$(basename "$DOTFILES_DIR")" != "dotfiles" ]; then
#   # Prompt the user for the path to dotfiles
#   echo -n "Enter the full path to your dotfiles directory (or press Enter to use the current directory): "
#   read -r DOTFILES_DIR
# fi

# Check if the dotfiles directory exists
# if [ ! -d "$DOTFILES_DIR" ]; then
#   echo "Error: Dotfiles directory not found."
#   exit 1
# fi

# Automatically create list of available directories inside the repository
directories=("$DOTFILES_DIR"/*/)
directories=("${directories[@]%/}")

# Create symbolic links for .zshrc and .aliases
ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/.aliases" "$HOME/.aliases"

task_config_dir="$DOTFILES_DIR/taskwarrior"
if [ -d "$task_config_dir" ]; then
  target_dir="$CONFIG_DIR/task"

  if [ -L "$target_dir" ]; then
    if [ "$(readlink -f "$target_dir")" = "$(readlink -f "$task_config_dir")" ]; then
      rm -f "$target_dir"
      echo "Removed existing symbolic link: $target_dir"
    fi
  elif [ -d "$target_dir" ]; then
    mv "$target_dir" "$target_dir.bak"
    echo "Existing directory '$target_dir' renamed to '$target_dir.bak'"
  fi

  ln -sfn "$task_config_dir" "$target_dir"
  echo "Created symlink: $target_dir"
  ln -sf "$target_dir/taskrc" "$HOME/.taskrc"
fi

for dir in "${directories[@]}"; do
  if [ "$(basename "$dir")" = "taskwarrior" ]; then
    continue
  fi
  target_dir="$CONFIG_DIR/$(basename "$dir")"

  # Check if the target directory is a symbolic link
  if [ -L "$target_dir" ]; then
    # Check if the link points to the dotfiles directory
    if [ "$(readlink -f "$target_dir")" = "$(readlink -f "$dir")" ]; then
      # Existing symbolic link points to dotfiles, remove it
      rm -f "$target_dir"
      echo "Removed existing symbolic link: $target_dir"
    fi
  elif [ -d "$target_dir" ]; then
    # Check if it's a directory (not a symbolic link)
    mv "$target_dir" "$target_dir.bak"
    echo "Existing directory '$target_dir' renamed to '$target_dir.bak'"
  fi

  # Create symlink
  ln -sfn "$dir" "$target_dir"
  echo "Created symlink: $target_dir"
done

echo "Symbolic links created successfully."
