#!/bin/sh
# setup-keyd.sh — caps -> esc remap on Gentoo (OpenRC)
# Run as a normal user; uses doas for privileged steps.
set -eu

KW=/etc/portage/package.accept_keywords/keyd
CONF=/etc/keyd/default.conf

# 1. Enable GURU overlay if missing
if ! eselect repository list -i 2>/dev/null | grep -q '\bguru\b'; then
    echo ">> Enabling GURU overlay"
    doas eselect repository enable guru
    doas emaint sync -r guru
fi

# 2. Accept ~amd64 keyword for keyd
if ! grep -qs 'app-misc/keyd' "$KW" 2>/dev/null; then
    echo ">> Accepting keyword"
    echo 'app-misc/keyd ~amd64' | doas tee "$KW" >/dev/null
fi

# 3. Install keyd
if ! command -v keyd >/dev/null 2>&1; then
    echo ">> Emerging keyd"
    doas emerge --ask=n app-misc/keyd
fi

# 4. Write config
echo ">> Writing $CONF"
printf '[ids]\n*\n\n[main]\ncapslock = esc\n' | doas tee "$CONF" >/dev/null

# 5. Enable + (re)start service
doas rc-update add keyd default 2>/dev/null || true
if doas rc-service keyd status >/dev/null 2>&1; then
    doas keyd reload
else
    doas rc-service keyd start
fi

echo ">> Done. Test with: doas keyd monitor  (press Caps, expect 'esc')"
