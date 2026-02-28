#!/usr/bin/env python3
"""
Switch Sioyek themes safely (no restarts) and persist the selection by updating
`~/.config/sioyek/current_theme.config` which is sourced from prefs_user.config.

Usage:
  theme_switcher.py random
  theme_switcher.py next
  theme_switcher.py prev
  theme_switcher.py <substring|basename|/absolute/path/to/theme.config>

Optional:
  Provide the current file path as the 2nd argument to relaunch it after switching:
    theme_switcher.py random "%{file_path}"
"""

from __future__ import annotations

import os
import random
import shutil
import subprocess
import sys
import time
from pathlib import Path

from sioyek.sioyek import Sioyek

CONFIG_DIR = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config")) / "sioyek"
THEMES_DIR = CONFIG_DIR / "themes"
CURRENT_THEME = CONFIG_DIR / "current_theme.config"


def list_themes() -> list[Path]:
    return sorted(THEMES_DIR.glob("*.config"))


def read_current_theme_name() -> str | None:
    try:
        first_line = CURRENT_THEME.read_text(encoding="utf-8", errors="ignore").splitlines()[0].strip()
    except Exception:
        return None
    if first_line.lower().startswith("# theme:"):
        return first_line.split(":", 1)[1].strip() or None
    return None


def resolve_theme(arg: str | None, themes: list[Path]) -> Path:
    if not themes:
        raise SystemExit(f"No theme configs found in {THEMES_DIR}")

    if not arg:
        return random.choice(themes)

    lowered = arg.lower()
    if lowered == "random":
        return random.choice(themes)

    if lowered in {"next", "prev"}:
        current_name = read_current_theme_name()
        if not current_name:
            return themes[0] if lowered == "next" else themes[-1]
        stems = [t.stem for t in themes]
        try:
            idx = stems.index(current_name)
        except ValueError:
            return themes[0] if lowered == "next" else themes[-1]
        return themes[(idx + 1) % len(themes)] if lowered == "next" else themes[(idx - 1) % len(themes)]

    maybe_path = Path(arg)
    if maybe_path.is_absolute() and maybe_path.exists():
        return maybe_path

    needle = lowered
    for theme in themes:
        if theme.stem.lower() == needle:
            return theme
    partial = [t for t in themes if needle in t.stem.lower()]
    if partial:
        return partial[0]

    raise SystemExit(f"No theme matched '{arg}'")


def write_current_theme(theme_file: Path) -> None:
    theme_text = theme_file.read_text(encoding="utf-8", errors="ignore")
    CURRENT_THEME.write_text(f"# theme: {theme_file.stem}\n{theme_text}", encoding="utf-8")


def apply_theme_in_running_sioyek() -> None:
    sioyek_bin = shutil.which("sioyek") or "sioyek"
    client = Sioyek(sioyek_bin)
    # On some builds/configs, theme-related colors only become visible after a full restart.
    # Try applying to the running instance for best UX, but we also do a graceful restart
    # if a file path was provided.
    client.run_command("source_config", str(CURRENT_THEME), focus=False)
    client.run_command("reload", None, focus=False)
    client.set_status_string(f"Theme: {read_current_theme_name() or 'unknown'}", focus=False)


def restart_sioyek(current_file: str | None, chosen_stem: str) -> None:
    sioyek_bin = shutil.which("sioyek") or "sioyek"
    client = Sioyek(sioyek_bin)
    client.run_command("quit", None, focus=False)
    time.sleep(0.4)
    if current_file:
        subprocess.Popen([sioyek_bin, current_file])
    else:
        subprocess.Popen([sioyek_bin])

    # Best-effort: once the new instance is up, set the status string to the chosen theme.
    for _ in range(15):
        time.sleep(0.2)
        try:
            subprocess.run(
                [
                    sioyek_bin,
                    "--execute-command",
                    "set_status_string",
                    "--execute-command-data",
                    f"Theme: {chosen_stem}",
                    "--nofocus",
                ],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                check=False,
            )
            break
        except Exception:
            continue


def main() -> None:
    themes = list_themes()
    chosen = resolve_theme(sys.argv[1] if len(sys.argv) > 1 else None, themes)
    write_current_theme(chosen)
    current_file = sys.argv[2] if len(sys.argv) > 2 and sys.argv[2].strip() else None

    # If you pass the current file, we restart to guarantee theme visibility.
    if current_file is not None:
        restart_sioyek(current_file, chosen.stem)
    else:
        apply_theme_in_running_sioyek()


if __name__ == "__main__":
    main()
