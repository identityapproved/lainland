local runtime = require("lib.runtime")
local hl = runtime.hl
local window_rule = runtime.window_rule

window_rule("suppress-maximize-events", { class = ".*" }, { suppress_event = "maximize" })
window_rule("fix-xwayland-drags", {
    class = "^$",
    title = "^$",
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
}, { no_focus = true })

window_rule("rofi-float", { class = "^(Rofi)$" }, { float = true })
window_rule("pavucontrol-float", { class = "^(org.pulseaudio.pavucontrol)" }, { float = true })
window_rule("pip-float", { class = "^$", title = "^(Picture in picture)$" }, { float = true })
window_rule("save-file-float", { class = "^$", title = "^(Save File)$" }, { float = true })
window_rule("open-file-float", { class = "^$", title = "^(Open File)$" }, { float = true })
window_rule("vivaldi-pip-float", { class = "^(vivaldi)$", title = "^(Picture-in-Picture)$" }, { float = true })
window_rule("blueman-float", { class = "^(blueman-manager)$" }, { float = true })
window_rule("portal-float", { class = "^(xdg-desktop-portal-gtk|xdg-desktop-portal-kde|xdg-desktop-portal-hyprland)(.*)$" }, { float = true })
window_rule("polkit-float", { class = "^(polkit-gnome-authentication-agent-1|hyprpolkitagent|org.org.kde.polkit-kde-authentication-agent-1)(.*)$" }, { float = true })
window_rule("zenity-float", { class = "^(zenity)$" }, { float = true })
window_rule("steam-updater-float", { class = "^$", title = "^(Steam - Self Updater)$" }, { float = true })

window_rule("virtualbox-opacity", { class = "^(VirtualBox Manager)" }, { opacity = 0.46 })
window_rule("file-manager-opacity", { class = "^(thunar|nemo)$" }, { opacity = 0.92 })
window_rule("reader-opacity", { class = "^(obsidian|sioyek|zathura|Zathura|org.pwmt.zathura)$" }, { opacity = 0.92 })
window_rule("zed-opacity", { class = "^(dev.zed.Zed)$" }, { opacity = 0.92 })
window_rule("spotify-opacity", { class = "^(spotify|Spotify)$" }, { opacity = 0.92 })
window_rule("chat-opacity", { class = "^(discord|armcord|webcord|vesktop)$" }, { opacity = 0.92 })
window_rule("signal-opacity", { title = "^(Signal)$" }, { opacity = 0.90 })
window_rule("firefox-opacity", { class = "^(firefox)$" }, { opacity = 0.92 })

window_rule("scratch-media-chat", { class = "^(signal|Signal|signal-desktop)$" }, {
    workspace = "special silent",
    pseudo = true,
})
window_rule("spotify-workspace", { class = "^(spotify|Spotify)$" }, {
    workspace = "9 silent",
    float = false,
    pseudo = false,
})
window_rule("games-confine-pointer", { class = "^(steam_app_.*|gamescope|lutris|heroic|osu!)$" }, {
    confine_pointer = true,
})
window_rule("scratch-signal-title-fallback", { title = "^(Signal)$" }, {
    workspace = "special silent",
    pseudo = true,
})
window_rule("bitwarden-workspace", { class = "^(Bitwarden|bitwarden)$" }, {
    workspace = "10 silent",
})

window_rule("picture-in-picture", { title = "^(Picture-in-Picture)$" }, {
    float = true,
    size = "320 180",
    move = "monitor_w-360 monitor_h-230",
    pin = true,
})
window_rule("media-float", { class = "^(imv|mpv|nemo|ncmpcpp)$" }, {
    float = true,
    size = "960 540",
    center = true,
})
window_rule("termfloat", { title = "^(termfloat)$" }, {
    float = true,
    size = "960 540",
    rounding = 5,
    center = true,
})
window_rule("termfloat-rounding", { title = "^(termfloat)$" }, { rounding = 5 })
window_rule("termfloat-sensors", { title = "^(termfloat-sensors)$" }, {
    float = true,
    size = "760 420",
    move = "monitor_w-790 40",
    pin = true,
    rounding = 0,
})
window_rule("termfloat-calendar", { title = "^(termfloat-calendar)$" }, {
    float = true,
    size = "760 520",
    move = "monitor_w-790 54",
    pin = true,
    rounding = 0,
})
window_rule("terminal-animation", { class = "^(kitty|Alacritty)$" }, { animation = "slide right" })
window_rule("firefox-no-blur", { class = "^(org.mozilla.firefox)$" }, { no_blur = true })

window_rule("idle-screensaver", { class = "^(screensaver)$" }, {
    float = false,
    pin = false,
    fullscreen = true,
    fullscreen_state = "2 2",
    no_anim = true,
    border_size = 0,
    rounding = 0,
    opacity = 1.0,
})
window_rule("idle-screensaver-hdmi", { title = "^(screensaver-HDMI-A-1)$" }, { monitor = "HDMI-A-1" })
window_rule("idle-screensaver-dvi", { title = "^(screensaver-DVI-D-1)$" }, { monitor = "DVI-D-1" })
window_rule("danmufloat", { title = "^(danmufloat)$" }, {
    float = true,
    size = "420 240",
    move = "20 100%-260",
    monitor = "DVI-D-1",
    workspace = "6 silent",
    pin = true,
    rounding = 5,
})
window_rule("floating-decorations", { float = true, workspace = "w[fv1-10]" }, {
    border_size = 2,
    rounding = 8,
})
window_rule("tiling-decorations", { float = false, workspace = "f[1-10]" }, {
    border_size = 3,
    rounding = 4,
})
window_rule("fullscreen-opacity", { fullscreen = 1 }, { opacity = 1 })

hl.layer_rule({
    name = "logout-dialog-animation",
    match = { namespace = "logout_dialog" },
    animation = "popin 70%",
})
hl.layer_rule({
    name = "waybar-animation",
    match = { namespace = "waybar" },
    animation = "popin 92%",
})
hl.layer_rule({
    name = "wallpaper-animation",
    match = { namespace = "wallpaper" },
    animation = "fade",
})
