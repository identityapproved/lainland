# Lainland Dotfiles

> *Let's all love Lain.*

One dotfiles repo for every machine, themed on a cohesive Serial Experiments
Lain palette. Configuration is applied by [chezmoi](https://chezmoi.io); the
only thing that varies per host is which window manager tree gets installed.

Currently: a Gentoo desktop running [mango](https://github.com/DreamMaoMao/mango)
and a Void laptop running sway. Hyprland is kept as a third supported target.

> [!WARNING]
> These dotfiles are still in progress. Use at your own risk.

---

## Screenshots

<p align="center">
  <img src="assets/05-26-2026-4113ec7_full.png" width="49%">
  <img src="assets/05-26-2026-bc8b0e3_full.png" width="49%">
  <img src="assets/05-26-2026-f995975_full.png" width="49%">
  <img src="assets/05-26-2026-05e1ccc_full.png" width="49%">
</p>

---

## Layout

```
.chezmoiroot            -> "home"; everything else here is not $HOME material
home/                   chezmoi source root
  .chezmoi.toml.tmpl    prompts once for wm + host at `chezmoi init`
  .chezmoiignore        template; the per-WM and per-daemon switches
  .chezmoiexternal.toml git repos chezmoi clones: zsh plugins, TPM, lain.tmux
  .chezmoiscripts/      run during apply, never installed: bat cache, GSettings,
                        and the dependency report
  dot_config/...        -> ~/.config/...
  dot_local/share/...   -> ~/.local/share/... (wallpapers, liferea plugins)
  dot_themes/lain/      -> ~/.themes/lain      GTK2/3/4 theme
  dot_icons/lainicons/  -> ~/.icons/lainicons  icon + cursor theme
  dot_zshrc  dot_zshenv  dot_zprofile.tmpl  dot_aliases  dot_gtkrc-2.0
installers/             package installers, one per area (no linking; see below)
gentoo/                 mirror of the Gentoo host's /etc/portage and overlay
void/                   the Void host's package list + installer, udev rules, modules-load.d
monitoring/             auditd rules; host-level, not chezmoi-managed
assets/                 README screenshots
```

## Install

Clone this repo somewhere you want to keep it -- it is the live source tree,
not a staging copy, so `~/github/lainland` rather than chezmoi's default
`~/.local/share/chezmoi`:

```bash
git clone https://github.com/<you>/lainland.git ~/github/lainland
chezmoi init --source ~/github/lainland
chezmoi apply --dry-run --verbose   # read it before the next line
chezmoi apply
```

That is the whole install. There is no post-apply checklist and no linking
script: `.chezmoiexternal.toml` clones the oh-my-zsh plugins, TPM and
`lain.tmux`, and `home/.chezmoiscripts/` handles the steps that are caches or
dconf rather than files --

| Script | Does | Re-runs when |
|---|---|---|
| `10-bat-cache` | `bat cache --build`, registering `bat/themes/Lain.tmTheme` | the theme changes |
| `20-gtk-qt` | runs `installers/setup-gtk-qt.sh` (GSettings; see Toolkits) | `gtk-3.0/settings.ini` changes |
| `90-deps` | prints a grouped report of anything missing, with the exact install command for this host | every apply |

`90-deps` always exits 0 -- a missing optional tool never fails an apply. It is
the only thing that still asks you to run a command, and it hands you that
command rather than a list of names.

The one thing chezmoi does *not* do for you is yazi's plugins. They are tracked
in this repo and symlinked in like any other config, so a fresh apply already
has them -- there is nothing to run to make yazi work. But `ya pkg` writes real
files where chezmoi wants symlinks, so letting it run on every apply would leave
`chezmoi status` permanently dirty. Updating a plugin is therefore deliberate
and manual:

```bash
ya pkg upgrade                        # rewrites the symlinks as real files
chezmoi re-add ~/.config/yazi/plugins # fold the new content back into the repo
chezmoi apply                         # restore the symlinks
```

Adding one is the same shape, with `ya pkg add <owner>/<repo>` first. Note that
`yazi/package.toml` lists only what `ya` installed; `full-border.yazi` predates
it and lives in the repo alone, which is why the repo -- not `package.toml` --
is the source of truth here.

`--source` is recorded in the generated config, so later `chezmoi` commands
need no flags. To answer the prompts non-interactively, note that
`--promptString` is keyed by the prompt *text*, not the variable name:

```bash
chezmoi init --source ~/github/lainland \
  --promptString "Window manager (mango/hyprland/sway)=sway" \
  --promptString "Short host name=$(hostname)"
```

`chezmoi init` asks two questions once and stores the answers in
`~/.config/chezmoi/chezmoi.toml`:

| Prompt | Values | Effect |
|---|---|---|
| `wm` | `mango`, `hyprland`, `sway` | selects which WM tree is applied |
| `host` | short hostname | reserved for per-host rules |

Everything else is applied on every machine. Configs for tools that are not
installed are inert, and are there ready for the machine that does have them —
the same "one branch, true on every host" model as `agentsdots`. Only the three
window-manager trees are mutually exclusive, so only they are switched.

chezmoi runs in **symlink mode**: it links managed *files* back into this repo,
so editing `~/.config/mango/config.conf` edits the repo. Two consequences:

- `~/.config/liferea` and `~/.config/vesktop` stay real directories holding
  their own live state (feed lists, session data), with only the themed files
  linked in. That is deliberate. Vesktop's `settings.json` and the desktop's
  `mimeapps.list` are live state too and are not managed at all -- enable the
  Lain theme once from Vesktop's Themes pane.
- Templates cannot be symlinked. `waybar/config.jsonc.tmpl` is written out as a
  real file — edit the `.tmpl` in the repo and `chezmoi apply`.

Package installation is separate and optional:

```bash
bash installers/installer_menu.sh
```

The installers install packages only. Linking used to live in
`installers/linking/simlinking.sh`; that script is gone and chezmoi does the job.
Dependency checking used to be a `checker` script in the sway repo; that is gone
too, and `.chezmoiscripts/run_after_90-deps.sh.tmpl` reports on every apply.

---

## The WM switch

Three modules have no portable name across compositors, so `waybar` is a
template:

| Module | mango | hyprland | sway |
|---|---|---|---|
| workspaces | `ext/workspaces` | `hyprland/workspaces` | `sway/workspaces` |
| window title | `custom/window` | `hyprland/window` | `sway/window` |
| keyboard layout | `custom/language` | `hyprland/language` | `sway/language` |

mango implements `ext-workspace`, so waybar's generic `ext/workspaces` module
works. It has no window-title or layout module at all, so
`~/.config/scripts/mango-ipc.py` feeds both over `mmsg`.

Three other things vary, and each is switched a different way:

| What | How |
|---|---|
| the compositor tree | `.chezmoiignore` installs one of `.config/{mango,hypr,sway}` |
| the notification daemon | `.chezmoiignore`: sway gets `swaync`, mango and hyprland get `mako` |
| the tty1 exec | `dot_zprofile.tmpl` branches on `.wm` |

Both notification daemons draw layer-shell notifications, so shipping both to
one host would be ambiguous rather than merely inert -- unlike the launcher
configs (`tofi`/`wofi`/`walker`), which stay installed everywhere and simply do
nothing without their binary.

### Starting a session

mango and hyprland set their session environment in their own config
(`env=` lines in `mango/config.conf`, `hypr/configs/envars.conf`), so
`dot_zprofile` execs them directly under `dbus-run-session`. Sway has no
equivalent: its `exec` runs *after* the compositor is already up, which is too
late for `XDG_CURRENT_DESKTOP` (the portal matches it against `UseIn=` in
`wlr.portal`) and too late for the Electron/Qt/Firefox Wayland hints. So sway
goes through `~/.config/sway/start-sway`, which is the sway analogue of those
`env=` blocks and also carries the Bay Trail `LIBVA_DRIVER_NAME=i965` workaround.

Sessions are not logged by default. To debug one that will not start, swap the
exec in `dot_zprofile.tmpl` for the commented line above it, which redirects to
`~/.local/state/sway.log`, then `chezmoi apply` and retry.

### The terminal

The terminal used to be hardcoded seven times over — `kitty` in
`hypr/configs/defaults.conf`, `mango/config.conf` and `tofi/config`, `foot` in
`sway/config` — so a host without that one binary had a rice with no terminal.
They all now call `~/.config/scripts/term`, a small generated script that
chezmoi resolves at apply time with `lookPath`, picking the first installed of
kitty, foot, alacritty.

It also normalises the float flag, which each terminal spells differently
(`--app-id`, `--class`) and each compositor matches differently (hypr and mango
on `title:termfloat`, sway on `app_id="termfloat"`). `term --float` sets *both*
identities, so one window rule per compositor holds whichever terminal is
installed.

---

## Themed Tools (Lain palette)

The palette reference is symlinked in and not tracked here. Every themed
config resolves its colors through its Semantic Role Map rather than picking
hexes by eye.

### WM / desktop

| Tool | Notes |
|---|---|
| `mango` | Border, focus, urgent and window-state colors |
| `hypr` | Colors, borders, shadows, animations, window rules, scripts |
| `sway` | Border colors, keybinds ported from hypr, `start-sway` session launcher |
| `waybar` | Full bar: workspaces, pomodoro, timewarrior, nb, cava, weather, storage |
| `walker` | Launcher; hand-written `themes/lain.{css,toml}` |
| `mako` | Notification daemon (mango, hyprland), per-urgency colors |
| `swaync` | Notification daemon + control center (sway), `$mod+n` |
| `wlogout` | Logout/power menu |
| `awww` | Wallpaper randomizer over the Lain set (mango, hyprland) |
| `swaybg` | Wallpaper setter on sway, via `sway/scripts/set-wallpaper.sh` |
| `gtk` / `qt` | Full Lain GTK2/3/4 theme, icon and cursor set, and Qt palette — see below |

### Toolkits

The desktop is themed at the toolkit level, not just per-app, so GTK and Qt
dialogs, file pickers and menus match the rest of the rice.

| Piece | Target | Notes |
|---|---|---|
| `lain` GTK theme | `~/.themes/lain` | libadwaita recolor; GTK2, GTK3 and GTK4 |
| `lainicons` | `~/.icons/lainicons` | icon overlay on AdwaitaLegacy, plus a full cursor set |
| `gtk-3.0` / `gtk-4.0` / `.gtkrc-2.0` | `~/.config`, `~` | select the theme, icons, cursors, Iosevka |
| `qt5ct` / `qt6ct` | `~/.config` | `colors/Lain.conf` palette, Iosevka, `lainicons` |
| `xsettingsd` | `~/.config` | carries the theme to X11 clients under XWayland |
| `nwg-look` | `~/.config` | GTK settings editor; its exports write back into this repo |
| `xdg-desktop-portal` | `~/.config` | per-WM backend choice; `gtk` first so the Settings portal reaches Flatpak and Electron apps |

One step is not a file. GTK3 apps prefer `org.gnome.desktop.interface`
GSettings keys over `settings.ini` whenever a dconf backend is present, so a
theme set only in `settings.ini` is silently ignored and the old one keeps
rendering. dconf cannot be checked in; `installers/setup-gtk-qt.sh` is the
reproducible record of those keys. Run it once per machine:

```bash
sh installers/setup-gtk-qt.sh
```

Two more details worth knowing. libadwaita ignores `gtk-theme-name` entirely, so
`~/.config/gtk-4.0/gtk.css` is a one-line `@import` of the theme's own sheet —
edit the theme, not that file. And Qt reads none of the GTK settings: the
palette only applies with `QT_QPA_PLATFORMTHEME=qt6ct`, which `mango/config.conf`
and `hypr/configs/envars.conf` both set.

### Terminal / shell

| Tool | Notes |
|---|---|
| `kitty` | Primary terminal, full 16-color ANSI mapping |
| `foot` | Terminal on the sway host, same 16-color mapping |
| `scripts/term` | Resolves whichever terminal is installed — see The WM switch |
| `tmux` | Multiplexer; `lain.tmux` status line, plus resurrect/continuum via TPM |
| `zsh` | Thin `.zshrc` loader over `~/.config/zsh/rc.d/*.zsh`; Lain fzf colors |
| `fish` | Kept for other machines; colorscheme now on-palette |
| `starship` | Powerline gradient down the Fore ramp |
| `dircolors` | `ls` colors, index-based; `EZA_COLORS` layers truecolor over it |

### Dev / CLI

| Tool | Notes |
|---|---|
| `delta` | Diff pager; three profiles, diffs encoded on the ramps not red/green |
| `lazygit` | Git TUI styled to match |
| `bat` | Custom `Lain.tmTheme` |
| `yazi` | File manager, `flavors/lain.yazi` plus plugins |
| `opencode` | TUI theme, `opencode/themes/lain.json` — see its README |
| `btop` | Resource monitor, `themes/lain.theme` |
| `htop` | Resource monitor; colors come from the terminal ANSI palette, see below |

htop has no theme format — `color_scheme` is an integer 0-6 selecting one of six
built-ins, and there is no way to hand it hex values. `htoprc` therefore sets
scheme 0, the one that draws from the terminal's own 16-colour ANSI slots, which
kitty and foot both map to the Lain palette. To recolour htop, change the
terminal palette. Note htop rewrites `htoprc` on exit, so a sort or column change
made in the UI lands in this repo through the symlink.

### Media

| Tool | Notes |
|---|---|
| `rmpc` | MPD client; `themes/lain.ron` |
| `mpd` | Music daemon behind rmpc |
| `ncmpcpp` | **Tracked, not linked** — superseded by rmpc on every host |
| `mpv` | Media player |
| `spotify` | Spicetify `lain` theme (other machines) |

### Productivity

| Tool | Notes |
|---|---|
| `taskwarrior` | `lain-256.theme` |
| `calcurse` | Calendar / todo |
| `zathura` | PDF reader; ochre-on-black document colors |
| `sioyek` | PDF reader (other machines) |
| `aerc` | **Tracked, not linked** — retired; config kept for whenever mail comes back |
| `liferea` | RSS reader; WebKit item view plus a GTK transparency plugin |

### Communication

| Tool | Notes |
|---|---|
| `vesktop` | Discord client with `lain.theme.css` |

### Utilities

| Tool | Notes |
|---|---|
| `clipse` | Clipboard manager |
| `tofi` / `wofi` | Launchers kept for other machines |
| `fontconfig` | Generic families aliased to Iosevka |

Fonts are Iosevka throughout, and the **same set on every host** — no per-host
family, no templated `fonts.conf`. `IosevkaTerm Nerd Font Mono` for terminals and
code, `Iosevka Nerd Font Propo` for UI chrome, `Iosevka Nerd Font` for prose, with
`Symbols Nerd Font` as the glyph fallback.

On Gentoo that is `media-fonts/nerdfonts` with the `iosevka` and `iosevkaterm`
USE flags. Void has no per-family packages — only `nerd-fonts`, a meta package
pulling `nerd-fonts-ttf` (7.4 GB installed) and `nerd-fonts-otf` (968 MB), so
roughly 8.4 GB to obtain three families. There is no cheaper packaged route;
the alternative is dropping the `Iosevka.zip` and `IosevkaTerm.zip` release
archives into `~/.local/share/fonts/` by hand and running `fc-cache -f`.

The deps report checks all four families with `fc-list` and flags them as
required, not optional, because a missing one silently changes every bar,
launcher and terminal at once.

---

## Thanks / Credits / Inspiration

- **[Ascaniolamp/Hyprlain](https://github.com/Ascaniolamp/Hyprlain)** — the original Lain rice that started it all, and the direct source of a good deal of what is here. The waybar layout and much of the theming approach are inspired by it, and the GTK theme (`~/.themes/lain`), the icon and cursor set (`~/.icons/lainicons`) and the Qt color scheme (`qt5ct`/`qt6ct` `colors/Lain.conf`) are vendored from its `src/gtkqtxdg` tree, renamed and lightly adapted. Go star it.
- **[uhm26](https://github.com/uhm26)** — the libadwaita recolor and the recolored Adwaita icons behind that GTK theme, via Hyprlain.
- **[niraletter/waybar-timer](https://github.com/niraletter/waybar-timer)** — pomodoro/timer waybar module.
- **[DreamMaoMao/mango](https://github.com/DreamMaoMao/mango)** — the dwl/wlroots compositor this desktop runs.
- **[b0o/lavi](https://github.com/b0o/lavi)** — its `contrib/opencode` themes are the clearest worked example of an OpenCode theme, and gave `opencode/themes/lain.json` its key set and file layout. None of its colors are used.
- **Serial Experiments Lain** — Yoshitoshi ABe, Yasuyuki Ueda, Ryutaro Nakamura. Watch it.
