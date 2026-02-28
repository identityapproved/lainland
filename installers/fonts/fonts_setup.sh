#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
COMMON_LIB="$SCRIPT_DIR/../lib/common.sh"

if [ -f "$COMMON_LIB" ]; then
  # shellcheck source=/dev/null
  source "$COMMON_LIB"
else
  echo "Error: Missing common library at $COMMON_LIB"
  exit 1
fi

ensure_helper

remove_pkg() {
  local pkg="$1"
  if command -v paru >/dev/null 2>&1; then
    paru -Rns --noconfirm "$pkg"
  elif command -v yay >/dev/null 2>&1; then
    yay -Rns --noconfirm "$pkg"
  else
    sudo pacman -Rns --noconfirm "$pkg"
  fi
}

bundle_fonts=(
  "powerline-fonts"
  "ttc-iosevka"
  "ttf-joypixels"
  "gnu-free-fonts"
)

echo "Installing base font bundle..."
for pkg in "${bundle_fonts[@]}"; do
  install_pkg "$pkg"
done

fallback_fonts=(
  "noto-fonts"
  "noto-fonts-extra"
  "noto-fonts-cjk"
  "noto-fonts-emoji"
  "ttf-unifont"
  "ttf-symbola"
  "nerd-fonts-symbols"
  "ttf-nerd-fonts-symbols"
)

if ask_yes "Install other fallback fonts (Noto/Unifont/Symbola/Nerd Symbols)?"; then
  if ask_yes "Install fallback noto-fonts (broad Unicode coverage)?"; then
    install_pkg noto-fonts
  fi

  if ask_yes "Install fallback noto-fonts-extra (more symbols/glyphs)?"; then
    install_pkg noto-fonts-extra
  fi

  if ask_yes "Install fallback noto-fonts-cjk (CJK glyph coverage)?"; then
    install_pkg noto-fonts-cjk
  fi

  if ask_yes "Install fallback noto-fonts-emoji (emoji coverage)?"; then
    install_pkg noto-fonts-emoji
  fi

  if ask_yes "Install fallback ttf-unifont (last-resort glyph coverage)?"; then
    install_pkg ttf-unifont
  fi

  if ask_yes "Install optional ttf-symbola (excellent symbol fallback)?"; then
    install_pkg ttf-symbola
  fi

  if ask_yes "Install optional nerd-fonts-symbols (dev icons)?"; then
    if ! install_pkg nerd-fonts-symbols; then
      echo "Package 'nerd-fonts-symbols' failed, trying 'ttf-nerd-fonts-symbols'..."
      install_pkg ttf-nerd-fonts-symbols
    fi
  fi
else
  installed_fallbacks=()
  for pkg in "${fallback_fonts[@]}"; do
    if pacman -Qq "$pkg" >/dev/null 2>&1; then
      installed_fallbacks+=("$pkg")
    fi
  done

  if [ "${#installed_fallbacks[@]}" -gt 0 ]; then
    echo "Optional fallback fonts are installed:"
    printf '  - %s\n' "${installed_fallbacks[@]}"
    if ask_yes "Remove installed optional fallback fonts now?"; then
      for pkg in "${installed_fallbacks[@]}"; do
        remove_pkg "$pkg" || true
      done
    else
      echo "Keeping installed optional fallback fonts."
    fi
  else
    echo "No optional fallback fonts currently installed."
  fi
fi

mkdir -p "$HOME/.config/fontconfig"
ln -sfn "$ROOT_DIR/fontconfig/fonts.conf" "$HOME/.config/fontconfig/fonts.conf"

echo "Refreshing font cache (fc-cache -fv)..."
fc-cache -fv

echo "Fonts setup complete."
