#!/usr/bin/env python3

from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
from collections import OrderedDict
from dataclasses import dataclass
from datetime import UTC, datetime
from pathlib import Path


ICON_ACTIVE = "󱎫"
ICON_IDLE = "󱫐"
ICON_EMPTY = "󱑊"
ICON_UNINITIALIZED = "󰔟"
ICON_ERROR = "󰀦"
CONFIG_PATH = Path.home() / ".config/timewarrior/timewarrior.cfg"
DATA_PATH = Path.home() / ".local/share/timewarrior/data"
STATE_PATH = Path.home() / ".local/state/timewarrior-waybar-bundles.json"


@dataclass
class Interval:
    start: datetime
    end: datetime | None
    tags: list[str]
    annotation: str


def is_initialized() -> bool:
    return CONFIG_PATH.exists() and DATA_PATH.exists()


def run_timew(*args: str, check: bool = True) -> subprocess.CompletedProcess[str]:
    env = os.environ.copy()
    env["LC_ALL"] = "C"
    result = subprocess.run(
        ["timew", *args],
        text=True,
        capture_output=True,
        env=env,
        check=False,
    )
    if check and result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or result.stdout.strip() or f"timew {' '.join(args)} failed")
    return result


def parse_timew_timestamp(value: str) -> datetime:
    return datetime.strptime(value, "%Y%m%dT%H%M%SZ").replace(tzinfo=UTC).astimezone()


def parse_intervals(*filters: str) -> list[Interval]:
    result = run_timew("export", *filters)
    raw_intervals = json.loads(result.stdout or "[]")
    intervals: list[Interval] = []
    for item in raw_intervals:
        intervals.append(
            Interval(
                start=parse_timew_timestamp(item["start"]),
                end=parse_timew_timestamp(item["end"]) if "end" in item else None,
                tags=item.get("tags", []),
                annotation=item.get("annotation", ""),
            )
        )
    return intervals


def active_interval() -> Interval | None:
    result = run_timew("get", "dom.active.json", check=False)
    if result.returncode != 0:
        return None
    payload = (result.stdout or "").strip()
    if payload in {"", "0"}:
        return None
    data = json.loads(payload)
    return Interval(
        start=parse_timew_timestamp(data["start"]),
        end=parse_timew_timestamp(data["end"]) if "end" in data else None,
        tags=data.get("tags", []),
        annotation=data.get("annotation", ""),
    )


def total_seconds(intervals: list[Interval], now: datetime) -> int:
    total = 0
    for interval in intervals:
        end = interval.end or now
        total += max(0, int((end - interval.start).total_seconds()))
    return total


def format_duration(seconds: int) -> str:
    hours, remainder = divmod(max(0, seconds), 3600)
    minutes, secs = divmod(remainder, 60)
    if hours:
        return f"{hours}:{minutes:02d}"
    if minutes:
        return f"{minutes}:{secs:02d}"
    return f"0:{secs:02d}"


def compact_tags(tags: list[str], limit: int = 2) -> str:
    if not tags:
        return "untagged"
    if len(tags) <= limit:
        return "/".join(tags)
    return f"{'/'.join(tags[:limit])}+{len(tags) - limit}"


def recent_bundles(limit: int = 8) -> list[str]:
    if not is_initialized():
        return []
    try:
        intervals = parse_intervals(":month")
    except Exception:
        return []

    seen: OrderedDict[str, None] = OrderedDict()
    for interval in reversed(intervals):
        if not interval.tags:
            continue
        bundle = " ".join(interval.tags)
        seen.setdefault(bundle, None)
        if len(seen) >= limit:
            break
    return list(seen.keys())


def load_saved_bundles(limit: int = 24) -> list[str]:
    if not STATE_PATH.exists():
        return []
    try:
        raw = json.loads(STATE_PATH.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return []
    if not isinstance(raw, list):
        return []

    bundles: list[str] = []
    for item in raw:
        if not isinstance(item, str):
            continue
        cleaned = " ".join(item.split()).strip()
        if cleaned and cleaned not in bundles:
            bundles.append(cleaned)
        if len(bundles) >= limit:
            break
    return bundles


def save_bundle(bundle: str, limit: int = 24) -> None:
    cleaned = " ".join(bundle.split()).strip()
    if not cleaned:
        return

    bundles = [cleaned]
    for item in load_saved_bundles(limit=limit):
        if item != cleaned:
            bundles.append(item)
        if len(bundles) >= limit:
            break

    try:
        STATE_PATH.parent.mkdir(parents=True, exist_ok=True)
        STATE_PATH.write_text(json.dumps(bundles, indent=2) + "\n", encoding="utf-8")
    except OSError:
        pass


def notify(summary: str, body: str) -> None:
    if shutil.which("notify-send"):
        subprocess.run(["notify-send", "-t", "2000", summary, body], check=False)


def print_status() -> int:
    if not is_initialized():
        print(
            json.dumps(
                {
                    "text": f"{ICON_UNINITIALIZED} init",
                    "class": ["uninitialized"],
                    "tooltip": "Timewarrior is not initialized. Middle click to open the tag picker after running timew once in a terminal.",
                }
            )
        )
        return 0

    now = datetime.now().astimezone()
    try:
        active = active_interval()
        day_intervals = parse_intervals(":day")
        week_intervals = parse_intervals(":week")
    except Exception as exc:
        print(json.dumps({"text": f"{ICON_ERROR} timew", "class": ["error"], "tooltip": str(exc)}))
        return 0

    today_total = format_duration(total_seconds(day_intervals, now))
    week_total = format_duration(total_seconds(week_intervals, now))
    bundles = recent_bundles()

    if active is not None:
        elapsed = format_duration(int((now - active.start).total_seconds()))
        tags = compact_tags(active.tags)
        tooltip_lines = [
            f"Tracking: {' '.join(active.tags) or 'untagged'}",
            f"Started: {active.start.strftime('%H:%M')}",
            f"Elapsed: {elapsed}",
            f"Today: {today_total}",
            f"Week: {week_total}",
            "",
            "Left click: stop",
            "Middle click: switch/start tags",
            "Right click: open dashboard",
        ]
        print(json.dumps({"text": f"{ICON_ACTIVE} {tags} {elapsed}", "class": ["active"], "tooltip": "\n".join(tooltip_lines)}))
        return 0

    if day_intervals:
        tooltip_lines = [
            f"Today: {today_total}",
            f"Week: {week_total}",
            "",
            "Left click: continue last interval",
            "Middle click: start tags",
            "Right click: open dashboard",
        ]
        if bundles:
            tooltip_lines.extend(["", "Recent bundles:", *bundles])
        print(json.dumps({"text": f"{ICON_IDLE} {today_total}", "class": ["idle"], "tooltip": "\n".join(tooltip_lines)}))
        return 0

    tooltip_lines = [
        f"Today: {today_total}",
        f"Week: {week_total}",
        "",
        "Left click: continue last interval",
        "Middle click: start tags",
        "Right click: open dashboard",
    ]
    if bundles:
        tooltip_lines.extend(["", "Recent bundles:", *bundles])
    print(json.dumps({"text": f"{ICON_EMPTY} 0:00", "class": ["empty"], "tooltip": "\n".join(tooltip_lines)}))
    return 0


def cmd_toggle() -> int:
    if not is_initialized():
        notify("Timewarrior", "Run timew once in a terminal to finish setup.")
        return 0
    try:
        active = active_interval()
        if active is not None:
            run_timew("stop")
            notify("Timewarrior", f"Stopped {' '.join(active.tags) or 'untagged'}")
            return 0

        export = parse_intervals()
        if not export:
            notify("Timewarrior", "No previous interval to continue. Middle click to start tags.")
            return 0
        run_timew("continue")
        notify("Timewarrior", "Continued last interval")
    except Exception as exc:
        notify("Timewarrior", str(exc))
    return 0


def choose_bundle() -> str | None:
    options = []
    seen: OrderedDict[str, None] = OrderedDict()
    for bundle in load_saved_bundles(limit=24) + recent_bundles(limit=16):
        cleaned = bundle.strip()
        if cleaned and cleaned not in seen:
            seen[cleaned] = None
            options.append(cleaned)

    if shutil.which("fzf"):
        result = subprocess.run(
            ["fzf", "--prompt", "timew > ", "--layout=reverse", "--border", "--print-query"],
            input="\n".join(options) + "\n",
            text=True,
            capture_output=True,
            check=False,
        )
        if result.returncode not in {0, 1}:
            raise RuntimeError(result.stderr.strip() or "fzf failed")
        lines = [line.strip() for line in result.stdout.splitlines() if line.strip()]
        if not lines:
            return None
        if len(lines) == 1:
            return lines[0]
        query, selection = lines[0], lines[-1]
        return selection or query

    print("Recent and preset bundles:")
    for index, bundle in enumerate(options, start=1):
        print(f"{index:>2}: {bundle}")
    raw = input("Tags or item number: ").strip()
    if not raw:
        return None
    if raw.isdigit():
        choice = int(raw)
        if 1 <= choice <= len(options):
            return options[choice - 1]
    return raw


def cmd_prompt() -> int:
    if not is_initialized():
        print("Timewarrior is not initialized yet.")
        print("Run `timew` once to create the default config and database, then retry.")
        return 1

    try:
        bundle = choose_bundle()
        if not bundle:
            return 0
        tags = bundle.split()
        run_timew("start", *tags)
        save_bundle(bundle)
        print(f"Started: {' '.join(tags)}")
        return 0
    except KeyboardInterrupt:
        return 130
    except Exception as exc:
        print(str(exc), file=sys.stderr)
        return 1


def print_dashboard() -> int:
    if not is_initialized():
        print("Timewarrior is not initialized yet.")
        print("Run `timew` once to create the default config and database.")
        return 0

    active = active_interval()
    now = datetime.now().astimezone()
    day_intervals = parse_intervals(":day")
    week_intervals = parse_intervals(":week")
    print("Timewarrior")
    print("===========")
    if active is None:
        print("Current: idle")
    else:
        elapsed = format_duration(int((now - active.start).total_seconds()))
        print(f"Current: {' '.join(active.tags) or 'untagged'} ({elapsed})")
        print(f"Started: {active.start:%Y-%m-%d %H:%M}")
    print()
    print("Today")
    print("-----")
    if day_intervals:
        print(run_timew("summary", ":day").stdout.rstrip())
    else:
        print("0:00 logged today")
    print()
    print("Week")
    print("----")
    if week_intervals:
        print(run_timew("summary", ":week").stdout.rstrip())
    else:
        print("0:00 logged this week")
    bundles = recent_bundles(limit=10)
    if bundles:
        print()
        print("Recent tag bundles")
        print("------------------")
        for bundle in bundles:
            print(bundle)
    print()
    print("Controls")
    print("--------")
    print("Left click: stop or continue last interval")
    print("Middle click: start a tag bundle")
    return 0


def main() -> int:
    command = sys.argv[1] if len(sys.argv) > 1 else "status"
    if command == "status":
        return print_status()
    if command == "toggle":
        return cmd_toggle()
    if command == "prompt":
        return cmd_prompt()
    if command == "dashboard":
        return print_dashboard()
    print(f"Unknown command: {command}", file=sys.stderr)
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
