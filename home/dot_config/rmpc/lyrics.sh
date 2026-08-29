#!/usr/bin/env bash
# rmpc on_song_change hook: fetch synced lyrics from LRCLIB.
# rmpc exports PID, FILE, DURATION, LRC_FILE, and one variable per song tag
# (ARTIST, TITLE, ALBUM, ...). LRC_FILE is the path rmpc will read lyrics from,
# derived from lyrics_dir + the song's path relative to MPD's music_directory.

set -uo pipefail

[[ -n ${LRC_FILE:-} && -n ${ARTIST:-} && -n ${TITLE:-} ]] || exit 0
[[ -e $LRC_FILE ]] && exit 0

duration=${DURATION%%.*}
duration=${duration//[^0-9]/}

api() {
    curl -fsS --max-time 10 -G "https://lrclib.net/api/$1" \
        -H 'User-Agent: rmpc-lyrics (https://github.com/mierak/rmpc)' \
        "${@:2}"
}

# /api/get needs the duration to match within a couple of seconds; fall back to
# a fuzzy search when the tags disagree with LRCLIB's copy.
lyrics=$(api get \
    --data-urlencode "artist_name=$ARTIST" \
    --data-urlencode "track_name=$TITLE" \
    --data-urlencode "album_name=${ALBUM:-}" \
    --data-urlencode "duration=$duration" |
    jq -r '.syncedLyrics // empty')

if [[ -z $lyrics ]]; then
    lyrics=$(api search \
        --data-urlencode "artist_name=$ARTIST" \
        --data-urlencode "track_name=$TITLE" |
        jq -r 'map(select(.syncedLyrics)) | first | .syncedLyrics // empty')
fi

[[ -n $lyrics ]] || exit 0

mkdir -p "$(dirname "$LRC_FILE")"
{
    printf '[ar:%s]\n' "$ARTIST"
    printf '[ti:%s]\n' "$TITLE"
    [[ -n ${ALBUM:-} ]] && printf '[al:%s]\n' "$ALBUM"
    printf '%s\n' "$lyrics"
} >"$LRC_FILE"

rmpc remote --pid "$PID" indexlrc --path "$LRC_FILE"
