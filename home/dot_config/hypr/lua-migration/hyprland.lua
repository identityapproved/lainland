-- Non-active Hyprland Lua migration entrypoint.
-- Do not symlink or copy this file to ~/.config/hypr/hyprland.lua yet.

local source = debug.getinfo(1, "S").source
local root = source:sub(1, 1) == "@" and source:sub(2):match("(.*/)") or "./"
package.path = root .. "?.lua;" .. root .. "?/init.lua;" .. package.path

local modules = {
    "configs.autostart",
    "configs.defaults",
    "configs.colors",
    "configs.envars",
    "configs.monitors",
    "configs.input",
    "configs.layout",
    "configs.misc",
    "configs.debug",
    "configs.general",
    "configs.decoration",
    "configs.animations",
    "configs.windowrules",
    "configs.workspaces",
    "configs.keybinds",
    "configs.groupmode",
}

for _, module in ipairs(modules) do
    require(module)
end
