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
.chezmoiroot           -> "home"; everything else here is not $HOME material
home/                  chezmoi source root
  .chezmoi.toml.tmpl   prompts once for wm + host at `chezmoi init`
  .chezmoiignore       template; the per-WM switch
  dot_config/...       -> ~/.config/...
  dot_local/share/...  -> ~/.local/share/... (wallpapers, liferea plugins)
  dot_themes/lain/     -> ~/.themes/lain      GTK2/3/4 theme
  dot_icons/lainicons/ -> ~/.icons/lainicons  icon + cursor theme
  dot_zshrc  dot_zshenv  dot_zprofile  dot_aliases  dot_gtkrc-2.0
installers/            package installers, one per area (no linking; see below)
gentoo/                mirror of this host's /etc/portage and local overlay
monitoring/            auditd rules; host-level, not chezmoi-managed
assets/                README screenshots
```

## Install

```bash
chezmoi init --apply https://github.com/<you>/lainland.git
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

---

## Themed Tools (Lain palette)

The palette itself lives in a private repo and is symlinked in as
`lain-colors.md` (gitignored here). Every themed config resolves its colors
through that document's Semantic Role Map rather than picking hexes by eye.

### WM / desktop

| Tool | Notes |
|---|---|
| `mango` | Border, focus, urgent and window-state colors |
| `hypr` | Colors, borders, shadows, animations, window rules, scripts |
| `waybar` | Full bar: workspaces, pomodoro, timewarrior, nb, cava, weather, storage |
| `walker` | Launcher; hand-written `themes/lain.{css,toml}` |
| `mako` | Notification daemon, per-urgency colors |
| `wlogout` | Logout/power menu |
| `awww` | Wallpaper randomizer over the Lain set |
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

Two details worth knowing. libadwaita ignores `gtk-theme-name` entirely, so
`~/.config/gtk-4.0/gtk.css` is a one-line `@import` of the theme's own sheet —
edit the theme, not that file. And Qt reads none of the GTK settings: the
palette only applies with `QT_QPA_PLATFORMTHEME=qt6ct`, which `mango/config.conf`
and `hypr/configs/envars.conf` both set.

### Terminal / shell

| Tool | Notes |
|---|---|
| `kitty` | Primary terminal, full 16-color ANSI mapping |
| `tmux` | Multiplexer with a hand-written Lain status line |
| `zsh` | Thin `.zshrc` loader over `~/.config/zsh/rc.d/*.zsh`; Lain fzf colors |
| `fish` | Kept for other machines; colorscheme now on-palette |
| `starship` | Powerline gradient down the Fore ramp |
| `dircolors` | `ls` and `eza` colors, index-based |

### Dev / CLI

| Tool | Notes |
|---|---|
| `delta` | Diff pager; three profiles, diffs encoded on the ramps not red/green |
| `lazygit` | Git TUI styled to match |
| `bat` | Custom `Lain.tmTheme` |
| `yazi` | File manager, `flavors/lain.yazi` plus plugins |

### Media

| Tool | Notes |
|---|---|
| `rmpc` | MPD client; `themes/lain.ron` |
| `ncmpcpp` / `mpd` | Music daemon and second client |
| `mpv` | Media player |
| `spotify` | Spicetify `lain` theme (other machines) |

### Productivity

| Tool | Notes |
|---|---|
| `taskwarrior` | `lain-256.theme` |
| `calcurse` | Calendar / todo |
| `zathura` | PDF reader; ochre-on-black document colors |
| `sioyek` | PDF reader (other machines) |
| `aerc` | Mail client |
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

Fonts are Iosevka throughout, via `media-fonts/nerdfonts` with the `iosevka`
and `iosevkaterm` USE flags: `IosevkaTerm Nerd Font Mono` for terminals and
code, `Iosevka Nerd Font Propo` for UI chrome, `Iosevka Nerd Font` for prose.

---

## Thanks / Credits / Inspiration

- **[Ascaniolamp/Hyprlain](https://github.com/Ascaniolamp/Hyprlain)** — the original Lain rice that started it all, and the direct source of a good deal of what is here. The waybar layout and much of the theming approach are inspired by it, and the GTK theme (`~/.themes/lain`), the icon and cursor set (`~/.icons/lainicons`) and the Qt color scheme (`qt5ct`/`qt6ct` `colors/Lain.conf`) are vendored from its `src/gtkqtxdg` tree, renamed and lightly adapted. Go star it.
- **[uhm26](https://github.com/uhm26)** — the libadwaita recolor and the recolored Adwaita icons behind that GTK theme, via Hyprlain.
- **[niraletter/waybar-timer](https://github.com/niraletter/waybar-timer)** — pomodoro/timer waybar module.
- **[DreamMaoMao/mango](https://github.com/DreamMaoMao/mango)** — the dwl/wlroots compositor this desktop runs.
- **Serial Experiments Lain** — Yoshitoshi ABe, Yasuyuki Ueda, Ryutaro Nakamura. Watch it.
