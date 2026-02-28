# Lainland Dotfiles

Let's all love Lain.

Lainland is an Arch + Hyprland dotfiles/setup repo focused on a cohesive Lain palette, modular installers, and practical defaults.

## Requirements
Install these first:
- `git`
- `base-devel`

If gaming is needed (Steam + Proton), enable `multilib` first.

Preferred during install:
- In `archinstall` -> `Additional repositories` -> enable `multilib`

Manual way:
```bash
sudo nano /etc/pacman.conf
```

Uncomment:
```ini
[multilib]
Include = /etc/pacman.d/mirrorlist
```

Then sync:
```bash
sudo pacman -Syu
```

## Install Flow

This repo follows a modular installer structure under `installers/`.

Run:
```bash
bash installers/installer_menu.sh
```

## Themed Tools (Lain Palette)
Current repo-managed Lain theming is applied for:
- `hypr` (colors, borders, shadows, animations, scripts)
- `waybar`
- `mako`
- `kitty`
- `wofi`
- `wlogout`
- `yazi` (lain flavor + plugins wiring)
- `delta` + `lazygit` diff styling
- `dircolors`
- `spotify` (spicetify `lain` theme)
- `vesktop` (`lain.theme.css`)
- `sioyek` (single fixed `lain.config`)

