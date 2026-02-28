#!/bin/bash

# Ensure the script is run in a Fish shell environment
if [ -z "$FISH_VERSION" ]; then
	echo "This script should be run within the Fish shell."
	exit 1
fi

# Add Vim keybindings to Fish shell
echo "Adding Vim keybindings to Fish shell..."
echo "fish_vi_key_bindings" | fish -c "echo 'fish_vi_key_bindings' >> ~/.config/fish/config.fish"

# Check if Fisher is installed
if ! fish -c "functions -q fisher" | grep -q fisher; then
	echo "Fisher is not installed. Installing Fisher..."
	fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"
fi

# Install the fzf.fish plugin using Fisher
echo "Installing PatrickF1/fzf.fish plugin..."
fish -c "fisher install PatrickF1/fzf.fish"

echo "Setup complete. Vim keybindings have been added and fzf.fish plugin has been installed."
