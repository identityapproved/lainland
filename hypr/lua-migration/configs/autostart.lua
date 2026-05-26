local hl = require("lib.runtime").hl

hl.on("hyprland.start", function()
    local exec_once = {
        "wpaperd -d &",
        "wl-gammarelay &",
        "waybar &",
        "mako &",
        "nm-applet --indicator &",
        "bash -c \"mkfifo /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob && tail -f /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob | wob -c ~/.config/hypr/wob.ini & disown\" &",
        "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &",
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP &",
        "hash dbus-update-activation-environment 2>/dev/null &",
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP &",
        "clipse -listen &",
        "hypridle -c ~/.config/hypr/hypridle.conf &",
    }

    for _, cmd in ipairs(exec_once) do
        hl.exec_cmd(cmd)
    end
end)
