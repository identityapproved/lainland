#!/bin/bash
# ==============================================
#  Secure UFW Installation and Configuration
#  Tested on Arch Linux
# ==============================================

set -euo pipefail

# Colors
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

echo -e "${YELLOW}[*] Checking for UFW installation...${RESET}"

# Install ufw if not present
if ! command -v ufw >/dev/null 2>&1; then
  if command -v yay >/dev/null 2>&1; then
    echo -e "${GREEN}[+] Installing ufw using yay...${RESET}"
    yay -S --noconfirm ufw
  else
    echo -e "${GREEN}[+] Installing ufw using pacman...${RESET}"
    sudo pacman -S --noconfirm ufw
  fi
else
  echo -e "${GREEN}[+] ufw already installed.${RESET}"
fi

echo -e "${YELLOW}[*] Stopping and resetting ufw...${RESET}"
sudo ufw disable || true
sudo ufw --force reset

# ----------------------------------------------
# Secure baseline configuration
# ----------------------------------------------
echo -e "${YELLOW}[*] Applying secure firewall rules...${RESET}"

# Default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw default deny routed

# Limit SSH brute-force attempts
SSH_PORT=${1:-22}
sudo ufw limit "${SSH_PORT}/tcp" comment "Limit SSH to prevent brute-force"

# Allow essential web services
sudo ufw allow 80/tcp comment "Allow HTTP"
sudo ufw allow 443/tcp comment "Allow HTTPS"

# Optional ICMP (Ping) blocking — uncomment if you want stealth mode
# echo -e "${YELLOW}[*] Blocking ICMP (ping) requests...${RESET}"
# sudo ufw deny proto icmp from any

# Logging level
sudo ufw logging medium

# ----------------------------------------------
# Drop invalid packets (extra hardening)
# ----------------------------------------------
BEFORE_RULES="/etc/ufw/before.rules"
if ! grep -q "ctstate INVALID" "$BEFORE_RULES"; then
  echo -e "${YELLOW}[*] Adding invalid packet drop rule...${RESET}"
  sudo sed -i '/^:ufw-before-input -/a -A ufw-before-input -m conntrack --ctstate INVALID -j DROP' "$BEFORE_RULES"
fi

# ----------------------------------------------
# Disable IPv6 if not needed
# ----------------------------------------------
# UFW_CONF="/etc/ufw/ufw.conf"
# if grep -q "^IPV6=" "$UFW_CONF"; then
#   sudo sed -i 's/^IPV6=.*/IPV6=no/' "$UFW_CONF"
# else
#   echo "IPV6=no" | sudo tee -a "$UFW_CONF" >/dev/null
# fi

# ----------------------------------------------
# Enable UFW safely
# ----------------------------------------------
echo -e "${YELLOW}[*] Enabling and starting ufw.service...${RESET}"
sudo systemctl enable ufw.service
sudo systemctl start ufw.service

echo -e "${YELLOW}[*] Enabling ufw...${RESET}"
sudo ufw --force enable

# ----------------------------------------------
# Display final status
# ----------------------------------------------
echo -e "${GREEN}[+] Final UFW Status:${RESET}"
sudo ufw status verbose

echo -e "${GREEN}[✓] UFW installation and configuration complete.${RESET}"
