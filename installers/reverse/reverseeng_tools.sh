#!/bin/bash

# Function to install a package using yay
install_package() {
    paru -S --noconfirm "$1" || { echo "Failed to install $1. Exiting." >&2; exit 1; }
}

# List of packages to install
packages=(
    "qemu-full"
    "aarch64-linux-gnu-gcc"
    "nasm"
)

# Install each package
for pkg in "${packages[@]}"; do
    install_package "$pkg"
done

echo "All required tools for reverse engineering and assembly have been installed."
