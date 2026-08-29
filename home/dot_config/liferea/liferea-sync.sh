#!/bin/sh
# liferea-sync.sh — push/pull the whole Liferea profile via the stora NAS.
#
# Syncs two files, always together:
#   ~/.config/liferea/feedlist.opml        subscriptions, folders, intervals
#   ~/.local/share/liferea/liferea.db      articles + read/starred state
#
# They are a MATCHED PAIR, not independent. The DB carries the subscription
# list too (its `subscription` table holds the feed URLs) and node ids key the
# two together — e.g. id "ekfpvak" is the same feed in both. Syncing one
# without the other desyncs the feed tree from its items, so this script always
# moves both and refuses to move a partial set.
#
# WHY THE "QUIT FIRST" RULE IS NOT OPTIONAL
#
# The DB runs in WAL journal mode. While Liferea is open there is a
# liferea.db-wal sidecar holding committed transactions not yet folded into the
# main file; copying liferea.db alone at that moment yields a stale or torn
# snapshot. A clean exit checkpoints the WAL away, leaving one consistent file.
# So this script refuses to run if Liferea is open OR if a -wal/-shm sidecar is
# present (which means it is running, or died without checkpointing).
#
# Liferea also only writes feedlist.opml on exit. Quit through the UI
# (File > Quit): it ignores SIGTERM — tested, it survives repeated TERM and
# only dies to SIGKILL — and a killed instance neither flushes the OPML nor
# checkpoints the WAL.
#
# THE LIMIT THIS CANNOT FIX
#
# There is no merge. Whoever pushes last wins the whole profile. Read state
# from a session on the other machine is discarded, not combined. This is safe
# only if you use one machine at a time and sync at the boundary. If you want
# genuine concurrent multi-device use, a server (FreshRSS/Miniflux via the
# Google Reader API source) is the only thing that actually merges state.
#
# WHAT THIS DOES NOT SYNC
#
# Theming and plugins are deliberately out of scope: gtk.css, liferea.css and
# plugins/ never travel over the NAS. They are per-machine — tracked in git on
# the host, kept separate here on void — so a shared copy would fight whichever
# machine pulled last. Only the profile pair above moves.
#
# Usage:
#   liferea-sync.sh status     compare local and remote, change nothing
#   liferea-sync.sh push       local -> NAS
#   liferea-sync.sh pull       NAS -> local (keeps .presync copies)
#   liferea-sync.sh bootstrap  NAS -> local, for a machine with no profile yet
#                              (creates the directories; theme comes from the
#                              machine's own setup, not from here)
#
# Host comes from ~/.ssh/config (Host stora). Override with the environment:
#   LIFEREA_SYNC_REMOTE=othernas LIFEREA_SYNC_DIR=/srv/liferea liferea-sync.sh push
set -eu

REMOTE="${LIFEREA_SYNC_REMOTE:-stora}"
REMOTE_DIR="${LIFEREA_SYNC_DIR:-/data/share/liferea}"

OPML="$HOME/.config/liferea/feedlist.opml"
DB="$HOME/.local/share/liferea/liferea.db"

die() {
    echo "!! $*" >&2
    exit 1
}

# An unreachable host must not look like an absent file, or status would
# advise seeding a remote that is merely offline.
require_host() {
    ssh "$REMOTE" true 2>/dev/null \
        || die "cannot reach $REMOTE over ssh (try: ssh $REMOTE true)"
    # Reaching the host is not enough: every comparison below reads mtimes with
    # `stat -c`, which BusyBox builds do not all provide. Without this probe a
    # remote whose stat rejects -c returns an empty timestamp, which is
    # indistinguishable from an empty directory — status would then advise
    # seeding a remote that already holds the profile, and push would happily
    # clobber it. Probe / because $REMOTE_DIR may legitimately not exist yet.
    ssh "$REMOTE" "stat -c %Y / >/dev/null 2>&1" \
        || die "$REMOTE has no 'stat -c' (BusyBox?). Timestamps cannot be
   compared, so sync direction cannot be decided safely. Install coreutils
   stat on the NAS, or run this against a host that has it."
}

require_closed() {
    if pgrep -x liferea >/dev/null 2>&1; then
        die "Liferea is running. Quit it via File > Quit first — it writes
   feedlist.opml and checkpoints the database only on a clean exit."
    fi
    # A leftover WAL means the DB was never checkpointed: either it is open
    # right now, or it was killed. Copying it in that state loses or tears
    # whatever the sidecar still holds.
    for sidecar in "$DB-wal" "$DB-shm"; do
        if [ -e "$sidecar" ]; then
            die "found $(basename "$sidecar") — the database was not checkpointed.
   Start Liferea and quit it cleanly, then retry."
        fi
    done
}

# Newest mtime across the pair, so a change to either file marks the profile
# as newer. Empty when neither exists.
newest_local() {
    for f in "$OPML" "$DB"; do
        [ -f "$f" ] && stat -c %Y "$f" || true
    done | sort -n | tail -1
}

newest_remote() {
    ssh "$REMOTE" "stat -c %Y '$REMOTE_DIR/feedlist.opml' '$REMOTE_DIR/liferea.db' \
        2>/dev/null | sort -n | tail -1" || true
}

human() {
    [ -n "$1" ] && date -d "@$1" '+%Y-%m-%d %H:%M:%S' || echo "(absent)"
}

cmd_status() {
    require_host
    mine=$(newest_local)
    theirs=$(newest_remote)
    echo "local  $(human "$mine")"
    for f in "$OPML" "$DB"; do
        [ -f "$f" ] && echo "         $(stat -c '%9s  %n' "$f")" || echo "         (missing) $f"
    done
    echo "remote $(human "$theirs")  $REMOTE:$REMOTE_DIR"
    ssh "$REMOTE" "ls -l '$REMOTE_DIR' 2>/dev/null | tail -n +2 | \
        awk '{printf \"         %9s  %s\\n\", \$5, \$9}'" || true

    if [ -z "$theirs" ]; then
        echo "-> remote has no profile yet; 'push' to seed it"
    elif [ -z "$mine" ]; then
        echo "-> no local profile; 'pull' to fetch"
    elif [ "$mine" -gt "$theirs" ]; then
        echo "-> local is newer; 'push' to publish it"
    elif [ "$theirs" -gt "$mine" ]; then
        echo "-> remote is newer; 'pull' to fetch it"
    else
        echo "-> in sync"
    fi
}

cmd_push() {
    require_closed
    [ -f "$OPML" ] || die "no feed list at $OPML"
    [ -f "$DB" ]   || die "no database at $DB"
    require_host

    theirs=$(newest_remote)
    mine=$(newest_local)
    # Refuse to clobber a remote newer than ours — that means the other machine
    # pushed since we last pulled, and push would discard its read state.
    if [ -n "$theirs" ] && [ "$theirs" -gt "$mine" ]; then
        die "remote is NEWER than local ($(human "$theirs") vs $(human "$mine")).
   Pushing would discard the other machine's reading progress.
   Run 'pull' first if you want the remote copy."
    fi

    # 700 on the dir: /data/share is group-readable by stora-share (gid 1001),
    # and neither your subscriptions nor your reading history belong to that
    # group. -p keeps the local 0600 on both files; without it the receiver's
    # umask decides and they can land 0644 inside the private directory.
    ssh "$REMOTE" "mkdir -p '$REMOTE_DIR' && chmod 700 '$REMOTE_DIR'" \
        || die "cannot create or lock down $REMOTE:$REMOTE_DIR.
   Check that its parent is writable by your ssh user, and that the share is
   not on a filesystem that ignores chmod (SMB/exFAT) — without a working
   chmod the profile would land readable by the stora-share group."
    rsync -tp --progress "$OPML" "$DB" "$REMOTE:$REMOTE_DIR/"
    echo ">> pushed profile to $REMOTE:$REMOTE_DIR"
}

cmd_bootstrap() {
    require_closed
    require_host
    theirs=$(newest_remote)
    [ -n "$theirs" ] || die "no profile on $REMOTE at $REMOTE_DIR"

    # Unlike pull, this runs where nothing exists yet, so the parent
    # directories have to be made before rsync can land the files.
    mkdir -p "$(dirname "$OPML")" "$(dirname "$DB")"
    rsync -tp "$REMOTE:$REMOTE_DIR/feedlist.opml" "$OPML"
    rsync -tp "$REMOTE:$REMOTE_DIR/liferea.db" "$DB"

    echo ">> bootstrapped profile from $REMOTE. Start Liferea to load it."
    echo "   Theme and plugins are not synced — install them from this"
    echo "   machine's own setup before expecting the rice to look right."
}

cmd_pull() {
    require_closed
    require_host
    theirs=$(newest_remote)
    [ -n "$theirs" ] || die "no profile on $REMOTE at $REMOTE_DIR"

    for f in "$OPML" "$DB"; do
        if [ -f "$f" ]; then
            cp -p "$f" "$f.presync"
        fi
    done
    echo ">> kept previous local copies as *.presync"

    rsync -tp --progress "$REMOTE:$REMOTE_DIR/feedlist.opml" "$OPML"
    rsync -tp --progress "$REMOTE:$REMOTE_DIR/liferea.db" "$DB"
    echo ">> pulled profile from $REMOTE. Start Liferea to load it."
}

case "${1:-status}" in
    status)    cmd_status ;;
    push)      cmd_push ;;
    pull)      cmd_pull ;;
    bootstrap) cmd_bootstrap ;;
    *)         die "usage: $(basename "$0") [status|push|pull|bootstrap]" ;;
esac
