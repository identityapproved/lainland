#!/bin/sh
# setup-gtk-qt.sh — point GSettings at the Lain GTK theme, icons and cursors.
#
# The theme files themselves are chezmoi-managed and need nothing from this
# script: ~/.themes/lain, ~/.icons/lainicons, ~/.config/gtk-{3,4}.0/settings.ini,
# ~/.gtkrc-2.0, ~/.config/qt{5,6}ct, ~/.config/xsettingsd.conf.
#
# What is NOT a file is org.gnome.desktop.interface. GTK3 apps prefer those
# GSettings keys over settings.ini whenever a dconf backend is present, which
# on this desktop it is -- so a theme set only in settings.ini is silently
# ignored and the previous theme keeps rendering. dconf cannot be checked in,
# so this script is the reproducible record of it, same as setup-liferea.sh.
#
# Safe to re-run. Takes effect immediately for apps started afterwards.
set -eu

if ! command -v gsettings >/dev/null 2>&1; then
    echo "!! gsettings not found (gsettings-desktop-schemas); nothing to do" >&2
    exit 1
fi

set_key() {
    gsettings set org.gnome.desktop.interface "$1" "$2"
    printf '   %-22s %s\n' "$1" "$2"
}

echo ">> Applying GSettings"
set_key gtk-theme 'lain'
set_key icon-theme 'lainicons'
set_key cursor-theme 'lainicons'
set_key cursor-size 24
set_key color-scheme 'prefer-dark'
set_key font-name 'Iosevka Nerd Font 11'
set_key document-font-name 'Iosevka Nerd Font 11'
set_key monospace-font-name 'IosevkaTerm Nerd Font Mono 11'

echo ">> Done. Restart GTK apps to pick it up; Qt apps follow QT_QPA_PLATFORMTHEME=qt6ct,"
echo "   which mango/config.conf exports, so those need a compositor restart."
