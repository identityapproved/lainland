#!/usr/bin/env python3
"""mango IPC -> Ironbar feed.

Ironbar has no native dwl/mango module, so this bridges mango's `mmsg watch`
JSON streams into single-line output for Ironbar `script`/`custom` modules in
"watch" mode (each printed line replaces the module's content).

Usage (one process per module):
    mango-ipc.py tags    [--monitor NAME]   # Pango markup, one glyph per tag
    mango-ipc.py title   [--max 80]         # focused window title
    mango-ipc.py layout                     # keyboard layout, abbreviated

Waybar does NOT use this — it reads tags/title from native ext/workspaces and
dwl/window. This feed exists only for the Ironbar (second) bar.

mmsg JSON shapes (mango 0.14.2; probed, not documented in the wiki):
    all-tags        {"all_tags":[{"monitor","tags":[{"index","is_active",
                                   "is_urgent","layout","client_count"}]}]}
    focusing-client {"id","title","appid","monitor","tags":[...], ...}
    keyboardlayout  {"layout":"English (US)"}
`watch` emits full state immediately, then re-emits the same shape on change.
"""

import argparse
import html
import json
import subprocess
import sys
import time

# Inline Pango colors. A script label carries no CSS class, so waybar's
# style.css cannot reach these -- they are set here and must be kept in step
# with waybar/style.css by hand.
COLOR_ACTIVE = "#C1B48E"  # highprimary    - focused tag
COLOR_OCCUPIED = "#CE7688"  # foreprimary  - has clients, not focused
COLOR_EMPTY = "#804654"  # foresenary      - no clients
COLOR_URGENT = "#FFB1C3"  # accent         - urgent

# Layout abbreviations for the keyboard-layout module.
LAYOUT_ABBR = {
    "English (US)": "us",
    "Ukrainian": "ua",
}


def stream(event, *extra):
    """Yield parsed JSON objects from `mmsg watch <event>`, restarting on death."""
    cmd = ["mmsg", "watch", event, *extra]
    while True:
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, text=True, bufsize=1)
        try:
            for line in proc.stdout:
                line = line.strip()
                if not line:
                    continue
                try:
                    yield json.loads(line)
                except json.JSONDecodeError:
                    continue
        finally:
            proc.terminate()
        # mmsg exited (compositor restart/socket drop); back off and retry.
        time.sleep(1)


def emit(text):
    print(text, flush=True)


def run_tags(monitor):
    last = None
    for msg in stream("all-tags"):
        mons = msg.get("all_tags", [])
        chosen = None
        if monitor:
            chosen = next((m for m in mons if m.get("monitor") == monitor), None)
        if chosen is None and mons:
            chosen = mons[0]
        if chosen is None:
            continue
        parts = []
        for t in chosen.get("tags", []):
            idx = t.get("index", "?")
            if t.get("is_urgent"):
                color = COLOR_URGENT
            elif t.get("is_active"):
                color = COLOR_ACTIVE
            elif t.get("client_count", 0) > 0:
                color = COLOR_OCCUPIED
            else:
                color = COLOR_EMPTY
            weight = "bold" if t.get("is_active") else "normal"
            parts.append(f'<span foreground="{color}" weight="{weight}">{idx}</span>')
        out = " ".join(parts)
        if out != last:
            emit(out)
            last = out


def run_eww_tags(monitor):
    """Emit an eww `literal` of clickable buttons for occupied/active tags.

    One process drives the whole workspace widget (cheap), rendered via
    `(literal :content workspaces)`. Empty, unfocused tags are skipped.
    State -> CSS class (.ws-btn.active/.occupied/.urgent) for styling.
    Per-tag MDI icons (Nerd Font); the tag number is the button tooltip.
    """
    # Material Design Icons (U+F0000+; present in M+ Nerd Font, survive stripping)
    icons = {
        1: "\U000f018d",  # console
        2: "\U000f059f",  # web
        3: "\U000f0174",  # code-tags
        4: "\U000f0362",  # message-text
        5: "\U000f0387",  # music
        6: "\U000f024b",  # folder
        7: "\U000f0297",  # gamepad
        8: "\U000f0493",  # cog
        9: "\U000f01d8",  # dots-horizontal
    }
    last = None
    for msg in stream("all-tags"):
        mons = msg.get("all_tags", [])
        chosen = None
        if monitor:
            chosen = next((m for m in mons if m.get("monitor") == monitor), None)
        if chosen is None and mons:
            chosen = mons[0]
        if chosen is None:
            continue
        btns = []
        for t in chosen.get("tags", []):
            idx = t.get("index")
            active = t.get("is_active")
            if t.get("is_urgent"):
                state = "urgent"
            elif active:
                state = "active"
            elif t.get("client_count", 0) > 0:
                state = "occupied"
            else:
                continue  # hide empty, unfocused tags
            glyph = icons.get(idx, str(idx))
            btns.append(
                f'(button :class "ws-btn {state}" :tooltip "{idx}" '
                f':onclick "mmsg dispatch view,{idx},0" "{glyph}")'
            )
        out = (
            '(box :class "ws" :orientation "h" :space-evenly false :spacing 4 '
            + " ".join(btns)
            + ")"
        )
        if out != last:
            emit(out)
            last = out


def run_tag(index, monitor):
    """Emit one tag's styled glyph (for a single clickable Ironbar button)."""
    last = None
    for msg in stream("all-tags"):
        mons = msg.get("all_tags", [])
        chosen = None
        if monitor:
            chosen = next((m for m in mons if m.get("monitor") == monitor), None)
        if chosen is None and mons:
            chosen = mons[0]
        if chosen is None:
            continue
        t = next((x for x in chosen.get("tags", []) if x.get("index") == index), None)
        if t is None:
            continue
        if t.get("is_active"):
            # active button carries the `active` CSS class (see run_active_class);
            # let CSS set the text color so it matches the highlighted background.
            out = f'<span weight="bold">{index}</span>'
        else:
            if t.get("is_urgent"):
                color = COLOR_URGENT
            elif t.get("client_count", 0) > 0:
                color = COLOR_OCCUPIED
            else:
                color = COLOR_EMPTY
            out = f'<span foreground="{color}">{index}</span>'
        if out != last:
            emit(out)
            last = out


def run_is_active(index, monitor):
    """One-shot: exit 0 if tag is occupied/active/urgent, else exit 1.

    Drives an Ironbar `show_if` script (exit-code based) so empty, unfocused
    tag buttons are hidden. mmsg `get` returns the same shape as `watch`.
    """
    try:
        out = subprocess.run(
            ["mmsg", "get", "all-tags"], capture_output=True, text=True, timeout=2
        ).stdout.strip()
        msg = json.loads(out)
    except (subprocess.SubprocessError, json.JSONDecodeError, OSError):
        sys.exit(1)  # mango unreachable -> hide
    mons = msg.get("all_tags", [])
    chosen = None
    if monitor:
        chosen = next((m for m in mons if m.get("monitor") == monitor), None)
    if chosen is None and mons:
        chosen = mons[0]
    if chosen is None:
        sys.exit(1)
    t = next((x for x in chosen.get("tags", []) if x.get("index") == index), None)
    if t is None:
        sys.exit(1)
    show = t.get("is_active") or t.get("is_urgent") or t.get("client_count", 0) > 0
    sys.exit(0 if show else 1)


def _ironbar(*args):
    try:
        subprocess.run(["ironbar", *args], capture_output=True, timeout=2)
    except (subprocess.SubprocessError, OSError):
        pass


def run_active_class(monitor, klass="active"):
    """Move a CSS class onto the active tag button(s) via Ironbar IPC.

    Pango (the tag label) can set text color but not a border/background on the
    button, so the highlight is done in CSS (`.active button`). This watches
    `all-tags` and add/removes `klass` on the `workN` modules as focus changes.
    """
    # wait for Ironbar's IPC so the very first (current) state applies
    for _ in range(60):
        try:
            if (
                subprocess.run(
                    ["ironbar", "ping"], capture_output=True, timeout=2
                ).returncode
                == 0
            ):
                break
        except (subprocess.SubprocessError, OSError):
            pass
        time.sleep(0.5)
    last = set()
    for msg in stream("all-tags"):
        mons = msg.get("all_tags", [])
        chosen = None
        if monitor:
            chosen = next((m for m in mons if m.get("monitor") == monitor), None)
        if chosen is None and mons:
            chosen = mons[0]
        if chosen is None:
            continue
        active = {t.get("index") for t in chosen.get("tags", []) if t.get("is_active")}
        if active == last:
            continue
        for i in last - active:
            _ironbar("style", "remove-class", f"work{i}", klass)
        for i in active - last:
            _ironbar("style", "add-class", f"work{i}", klass)
        last = active


def run_title(max_len):
    last = None
    for msg in stream("focusing-client"):
        title = msg.get("title") or ""
        if max_len and len(title) > max_len:
            title = title[: max_len - 1].rstrip() + "…"
        out = html.escape(title)
        if out != last:
            emit(out)
            last = out


def run_layout():
    last = None
    for msg in stream("keyboardlayout"):
        layout = msg.get("layout") or ""
        out = LAYOUT_ABBR.get(layout, layout)
        if out != last:
            emit(out)
            last = out


def main():
    p = argparse.ArgumentParser(description="mango mmsg -> Ironbar feed")
    sub = p.add_subparsers(dest="mode", required=True)

    pt = sub.add_parser("tags", help="all tag indicators (Pango markup)")
    pt.add_argument(
        "--monitor", default=None, help="monitor name (default: first reported)"
    )

    pe = sub.add_parser("eww-tags", help="eww literal of clickable workspace buttons")
    pe.add_argument(
        "--monitor", default=None, help="monitor name (default: first reported)"
    )

    pg = sub.add_parser("tag", help="one tag's indicator (for a single button)")
    pg.add_argument("index", type=int, help="tag index (1-based)")
    pg.add_argument(
        "--monitor", default=None, help="monitor name (default: first reported)"
    )

    pa = sub.add_parser(
        "is-active", help="one-shot: exit 0 if tag occupied/active (for show_if)"
    )
    pa.add_argument("index", type=int, help="tag index (1-based)")
    pa.add_argument(
        "--monitor", default=None, help="monitor name (default: first reported)"
    )

    pac = sub.add_parser(
        "active-class", help="move an 'active' CSS class onto the focused tag"
    )
    pac.add_argument(
        "--monitor", default=None, help="monitor name (default: first reported)"
    )

    pw = sub.add_parser("title", help="focused window title")
    pw.add_argument(
        "--max",
        type=int,
        default=80,
        dest="max_len",
        help="truncate title to N chars (0 = no limit)",
    )

    sub.add_parser("layout", help="keyboard layout, abbreviated")

    args = p.parse_args()
    try:
        if args.mode == "tags":
            run_tags(args.monitor)
        elif args.mode == "eww-tags":
            run_eww_tags(args.monitor)
        elif args.mode == "tag":
            run_tag(args.index, args.monitor)
        elif args.mode == "is-active":
            run_is_active(args.index, args.monitor)
        elif args.mode == "active-class":
            run_active_class(args.monitor)
        elif args.mode == "title":
            run_title(args.max_len)
        elif args.mode == "layout":
            run_layout()
    except KeyboardInterrupt:
        pass
    except BrokenPipeError:
        sys.exit(0)


if __name__ == "__main__":
    main()
