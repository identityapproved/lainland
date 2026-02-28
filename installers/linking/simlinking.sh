#!/bin/bash

CONFIG_DIR="$HOME/.config"
# Get the current directory
DOTFILES_DIR=$(pwd)

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
ln -sf "$DOTFILES_DIR/.taskrc" "$HOME/.taskrc"

for dir in "${directories[@]}"; do
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
