local hl = require("lib.runtime").hl

local env = {
    { "QT_QPA_PLATFORMTHEME", "qt6ct" },
    { "GDK_BACKEND", "wayland" },
    { "QT_QPA_PLATFORM", "wayland;xcb" },
    { "CLUTTER_BACKEND", "wayland" },
    { "XDG_CURRENT_DESKTOP", "Hyprland" },
    { "XDG_SESSION_DESKTOP", "Hyprland" },
    { "QT_AUTO_SCREEN_SCALE_FACTOR", "1" },
    { "XDG_SESSION_TYPE", "wayland" },
    { "QT_WAYLAND_DISABLE_WINDOWDECORATION", "1" },
    { "ELECTRON_OZONE_PLATFORM_HINT", "wayland" },
    { "SWAPPY_DIR", "$HOME/drives/kodak/pics/screenshots" },
    { "XCURSOR_SIZE", "24" },
    { "XCURSOR_THEME", "lainicons" },
    { "WLR_NO_HARDWARE_CURSORS", "0" },
    { "GTK_THEME", "lain" },
    { "MOZ_ENABLE_WAYLAND", "1" },
    { "MOZ_DBUS_REMOTE", "1" },
}

for _, item in ipairs(env) do
    hl.env(item[1], item[2])
end
