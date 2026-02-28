#!/bin/bash

# List of packages to install
packages=(
  "virtualbox"
  "virtualbox-ext-oracle"
  "linux-headers"
  "linux-firmware"
)

# Function to install package using yay
install_package() {
  paru -S "$1" || { echo "Failed to install $1. Exiting." >&2; exit 1; }
}

# Install VirtualBox and required packages
for pkg in "${packages[@]}"; do
  if [ "$pkg" == "virtualbox" ]; then
    # Ensure virtualbox-host-modules-arch is selected instead of virtualbox-host-dkms
    paru -S "$pkg" <<EOF
1
EOF
  else
    install_package "$pkg"
  fi
done

# If any errors occur, use commands below
# /sbin/rcvboxdrv setup
# dkms autoinstall

echo "VirtualBox and related packages have been installed successfully."
