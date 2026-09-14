#!/bin/sh
# setup-liferea.sh — apply Liferea's GSettings preferences.
# Liferea keeps its preferences in GSettings (dconf), not in a config file, so
# they cannot be checked into this repo as dotfiles — this script is the
# reproducible record of them. Safe to re-run.
#
# It used to link the theme and plugin files as well. chezmoi does that now:
#   ~/.config/liferea/{liferea.css,gtk.css}   <- home/dot_config/liferea/
#   ~/.local/share/liferea/plugins/*          <- home/dot_local/share/liferea/
# Both are linked file-by-file on purpose. Liferea writes its own data into
# ~/.config/liferea — feedlist.opml, feedlist.opml.backup, user.js — so making
# the directory itself a link would drag subscriptions into the working tree.
# chezmoi's symlink mode gives that for free: real directory, symlinked files.
set -eu

CONF="$HOME/.config/liferea"

if ! command -v liferea >/dev/null 2>&1; then
    echo "!! liferea is not installed; install it first" >&2
    exit 1
fi

# One-time migration off the old layout: lainland used to symlink the whole
# ~/.config/liferea directory into the repo, which put Liferea's own data
# inside the working tree. If that link is still here, unpick it and move the
# data back out before chezmoi tries to create files underneath.
if [ -L "$CONF" ]; then
    OLD=$(readlink -f "$CONF")
    echo ">> $CONF is a whole-directory symlink (old layout); migrating"
    rm "$CONF"
    mkdir -p "$CONF"
    for data in feedlist.opml feedlist.opml.backup feedlist.opml.presync user.js; do
        if [ -f "$OLD/$data" ]; then
            mv "$OLD/$data" "$CONF/$data"
            echo "   moved $data out of the repo"
        fi
    done
fi
mkdir -p "$CONF"

# Preferences.
set_key() {
    gsettings set net.sf.liferea "$1" "$2"
}

echo ">> Applying GSettings"

# Open links in zen, not the GNOME default handler. browser-id must be
# "manual" or the browser command below is ignored.
set_key browser-id 'manual'
set_key browser 'zen %s'
set_key browse-inside-application false

# Space pages down and then jumps to the next unread item (0=space,
# 1=ctrl-space, 2=alt-space).
set_key browse-key-setting 0

# Poll hourly. Per-feed intervals still override this.
set_key default-update-interval 60
set_key startup-feed-action 0

# Reading pane: auto-switch between the email-like and wide 3-pane layouts
# depending on window shape.
set_key default-view-mode 2
set_key toolbar-style 'icons'
set_key confirm-mark-all-read false

# Privacy: no JS in the item view, and tell sites so.
set_key disable-javascript true
set_key enable-itp true
set_key do-not-track true
set_key do-not-sell false

# Strip page chrome from fetched articles.
set_key enable-reader-mode true

# Enable the transparency plugin, keeping whatever else is already active.
#    (This is the libpeas plugin list; the separate "enable-plugins" key is a
#    WebKit browser-plugin setting and is unrelated.)
echo ">> Enabling transparency plugin"
ACTIVE=$(gsettings get net.sf.liferea.plugins active-plugins)
NEW=$(ACTIVE="$ACTIVE" python3 -c '
import ast, os
plugins = ast.literal_eval(os.environ["ACTIVE"])
if "transparency" not in plugins:
    plugins.append("transparency")
print(repr(plugins))
')
gsettings set net.sf.liferea.plugins active-plugins "$NEW"

echo ">> Done. Restart Liferea — liferea.css and the plugin load only at startup."
