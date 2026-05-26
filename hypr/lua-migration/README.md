# Hyprland Lua Migration

Hyprland 0.55 supports Lua config, but `hyprland.conf` is still the active config in this repo.

Do not place a `hyprland.lua` file at `~/.config/hypr/hyprland.lua` until the Lua migration is complete. Hyprland gives that file priority over `hyprland.conf` at startup.

The draft in this directory is intentionally non-active. It includes a no-op fallback for the Hyprland `hl` API so it can be syntax-checked and loaded by plain Lua without starting Hyprland.

The Lua migration mirrors the active Hyprlang structure:

- `hypr/lua-migration/hyprland.lua` is the entrypoint.
- `hypr/lua-migration/configs/*.lua` mirrors `hypr/configs/*.conf`.
- `hypr/lua-migration/lib/runtime.lua` contains shared no-op verification helpers and common values used by multiple modules.

## Current Active Source Order

The Lua migration should preserve the behavior currently split across these Hyprlang modules:

1. `autostart.conf`
2. `defaults.conf`
3. `colors.conf`
4. `envars.conf`
5. `monitors.conf`
6. `input.conf`
7. `layout.conf`
8. `misc.conf`
9. `debug.conf`
10. `general.conf`
11. `decoration.conf`
12. `animations.conf`
13. `windowrules.conf`
14. `workspaces.conf`
15. `keybinds.conf`
16. `groupmode.conf`

## Migration Status

- Converted in matching modules: colors, app defaults, monitors, env vars, autostart, input, layouts, `general`, `misc`, `debug`, `decoration`, `animations`, `group`, `cursor`, workspace rules, window rules, layer rules, and binds.
- The draft uses official helpers from `/usr/share/hypr/hyprland.lua` and `/usr/share/hypr/stubs/hl.meta.lua` where available.
- Keep this directory non-active until it has been tested in a disposable Hyprland session.

## Verification

```sh
luac -p hypr/lua-migration/hyprland.lua
find hypr/lua-migration -name '*.lua' -exec luac -p {} \;
lua -e 'assert(loadfile("hypr/lua-migration/hyprland.lua"))()'
test ! -f hypr/hyprland.lua
rg -n '^source = ~/.config/hypr/configs/' hypr/hyprland.conf
rg -n 'dwindle:pseudotile|pseudotile\s*=|decoration:shadow:ignore_window|render:cm_fs_passthrough|misc:vfr' hypr/configs hypr/hyprland.conf hypr/lua-migration/configs hypr/lua-migration/lib hypr/lua-migration/hyprland.lua
```
