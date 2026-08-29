local runtime = require("lib.runtime")
local hl = runtime.hl
local bind = runtime.bind
local mainMod = runtime.mainMod
local apps = runtime.apps

bind(mainMod .. " + RETURN", "Opens your preferred terminal emulator", hl.dsp.exec_cmd(apps.terminal))
bind(mainMod .. " + SHIFT + RETURN", "Opens tmux terminal", hl.dsp.exec_cmd(apps.tmux))
bind(mainMod .. " + CTRL + RETURN", "Opens floating terminal", hl.dsp.exec_cmd(apps.termfloat))
bind(mainMod .. " + C", "Opens clipboard history (Clipse)", hl.dsp.exec_cmd("kitty --title termfloat -e clipse"))

bind(mainMod .. " + E", "Opens your preferred file manager", hl.dsp.exec_cmd(apps.fileManager))
bind(mainMod .. " + Q", "Closes current window", hl.dsp.window.close())
bind(mainMod .. " + SHIFT + M", "Exits Hyprland session", hl.dsp.exit())
bind(mainMod .. " + SPACE", "Runs your application launcher", hl.dsp.exec_cmd(apps.menu))
bind(mainMod .. " + SHIFT + SPACE", "Runs your run launcher", hl.dsp.exec_cmd("tofi-run"))
bind(mainMod .. " + F", "Toggles current window fullscreen mode", hl.dsp.window.fullscreen())
bind(mainMod .. " + Y", "Pin current window", hl.dsp.window.pin())
bind(mainMod .. " + T", "Rotates current dwindle split orientation", hl.dsp.layout("rotatesplit"))
bind(mainMod .. " + P", "Pseudotiling", hl.dsp.window.pseudo())
bind(mainMod .. " + SHIFT + T", "Show date/time notification", hl.dsp.exec_cmd('notify-send "  $(date +%H:%M) |   $(date +%d.%m.%y)"'))
bind(mainMod .. " + F12", "Lock the screen", hl.dsp.exec_cmd(apps.locker))
bind(mainMod .. " + SHIFT + F12", "Open power menu", hl.dsp.exec_cmd("wlogout -b 6 -T 340 -B 340"))

bind(mainMod .. " + V", "Switches current window between floating and tiling mode", hl.dsp.window.float({ action = "toggle" }))
bind(mainMod .. " + A", "Focus/cycle floating window", hl.dsp.window.cycle_next("floating"))
bind(mainMod .. " + TAB", "Cycle floating windows forward", hl.dsp.window.cycle_next("floating"))
bind(mainMod .. " + SHIFT + TAB", "Cycle floating windows backward", hl.dsp.window.cycle_next("prev floating"))
bind(mainMod .. " + U", "Bring active window to top", hl.dsp.window.bring_to_top())

bind(mainMod .. " + G", "Toggles current window group mode", hl.dsp.group.toggle())
bind(mainMod .. " + ALT + h", "Move window/group left", hl.dsp.group.move_window("l"))
bind(mainMod .. " + ALT + l", "Move window/group right", hl.dsp.group.move_window("r"))
bind(mainMod .. " + ALT + j", "Change group active backward", hl.dsp.group.prev())
bind(mainMod .. " + ALT + k", "Change group active forward", hl.dsp.group.next())

bind("XF86AudioRaiseVolume", "Raise volume", hl.dsp.exec_cmd('wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+ && notify-send "$(wpctl get-volume @DEFAULT_AUDIO_SINK@)"'), { locked = true, repeating = true })
bind("XF86AudioLowerVolume", "Lower volume", hl.dsp.exec_cmd('wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && notify-send "$(wpctl get-volume @DEFAULT_AUDIO_SINK@)"'), { locked = true, repeating = true })
bind("XF86AudioMute", "Toggle audio mute", hl.dsp.exec_cmd('wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && notify-send "$(wpctl get-volume @DEFAULT_AUDIO_SINK@)"'), { locked = true, repeating = true })
bind("XF86AudioMicMute", "Toggle microphone mute", hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle_mic.sh"), { locked = true, repeating = true })
bind(mainMod .. " + M", "Toggle microphone mute", hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle_mic.sh"))

bind("XF86AudioPlay", "Toggles play/pause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
bind("XF86AudioNext", "Next track", hl.dsp.exec_cmd("playerctl next"), { locked = true })
bind("XF86AudioPrev", "Previous track", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
bind("XF86MonBrightnessUp", "Increase brightness", hl.dsp.exec_cmd("brightnessctl s +5%"), { locked = true, repeating = true })
bind("XF86MonBrightnessDown", "Decrease brightness", hl.dsp.exec_cmd("brightnessctl s 5%-"), { locked = true, repeating = true })

bind(mainMod .. " + CTRL + SHIFT + F11", "Set screen temperature 6500K", hl.dsp.exec_cmd("busctl --user -- set-property rs.wl-gammarelay / rs.wl.gammarelay Temperature q 6500"))
bind(mainMod .. " + CTRL + SHIFT + F10", "Set screen temperature 4500K", hl.dsp.exec_cmd("busctl --user -- set-property rs.wl-gammarelay / rs.wl.gammarelay Temperature q 4500"))
bind(mainMod .. " + CTRL + SHIFT + F9", "Set screen temperature 2500K", hl.dsp.exec_cmd("busctl --user -- set-property rs.wl-gammarelay / rs.wl.gammarelay Temperature q 2500"))

bind(mainMod .. " + B", "Toggle Waybar", hl.dsp.exec_cmd("pkill waybar || waybar"))
bind(mainMod .. " + O", "Reload Waybar", hl.dsp.exec_cmd("killall -SIGUSR2 waybar"))

bind(mainMod .. " + h", "Move focus to the left", hl.dsp.focus({ direction = "left" }))
bind(mainMod .. " + l", "Move focus to the right", hl.dsp.focus({ direction = "right" }))
bind(mainMod .. " + k", "Move focus upwards", hl.dsp.focus({ direction = "up" }))
bind(mainMod .. " + j", "Move focus downwards", hl.dsp.focus({ direction = "down" }))

bind(mainMod .. " + SHIFT + h", "Move active window left on current monitor", hl.dsp.window.move({ direction = "left" }))
bind(mainMod .. " + SHIFT + l", "Move active window right on current monitor", hl.dsp.window.move({ direction = "right" }))
bind(mainMod .. " + SHIFT + k", "Move active window upwards", hl.dsp.window.move({ direction = "up" }))
bind(mainMod .. " + SHIFT + j", "Move active window downwards", hl.dsp.window.move({ direction = "down" }))
bind(mainMod .. " + CTRL + h", "Move active window to DVI monitor", hl.dsp.window.move({ monitor = "DVI-D-1" }))
bind(mainMod .. " + CTRL + l", "Move active window to HDMI monitor", hl.dsp.window.move({ monitor = "HDMI-A-1" }))

bind(mainMod .. " + mouse:272", "Move window with mouse", hl.dsp.window.drag(), { mouse = true })
bind(mainMod .. " + mouse:273", "Resize window with mouse", hl.dsp.window.resize(), { mouse = true })

hl.define_submap("resize", "reset", function()
    bind("right", "Resize to the right", hl.dsp.window.resize("32 0"))
    bind("left", "Resize to the left", hl.dsp.window.resize("-32 0"))
    bind("up", "Resize upwards", hl.dsp.window.resize("0 -32"))
    bind("down", "Resize downwards", hl.dsp.window.resize("0 32"))
    bind("l", "Resize to the right", hl.dsp.window.resize("32 0"))
    bind("h", "Resize to the left", hl.dsp.window.resize("-32 0"))
    bind("k", "Resize upwards", hl.dsp.window.resize("0 -32"))
    bind("j", "Resize downwards", hl.dsp.window.resize("0 32"))
    bind("escape", "Ends window resizing mode", hl.dsp.submap("reset"))
    bind("return", "Ends window resizing mode", hl.dsp.submap("reset"))
end)
bind(mainMod .. " + R", "Activates window resizing mode", hl.dsp.submap("resize"))

bind(mainMod .. " + CTRL + SHIFT + right", "Resize to the right", hl.dsp.window.resize("23 0"))
bind(mainMod .. " + CTRL + SHIFT + left", "Resize to the left", hl.dsp.window.resize("-23 0"))
bind(mainMod .. " + CTRL + SHIFT + up", "Resize upwards", hl.dsp.window.resize("0 -23"))
bind(mainMod .. " + CTRL + SHIFT + down", "Resize downwards", hl.dsp.window.resize("0 23"))
bind(mainMod .. " + CTRL + SHIFT + l", "Resize to the right", hl.dsp.window.resize("23 0"))
bind(mainMod .. " + CTRL + SHIFT + h", "Resize to the left", hl.dsp.window.resize("-23 0"))
bind(mainMod .. " + CTRL + SHIFT + k", "Resize upwards", hl.dsp.window.resize("0 -23"))
bind(mainMod .. " + CTRL + SHIFT + j", "Resize downwards", hl.dsp.window.resize("0 23"))

for workspace = 1, 10 do
    local key = workspace % 10
    bind(mainMod .. " + " .. key, "Switch to workspace " .. workspace, hl.dsp.focus({ workspace = workspace }))
    bind(mainMod .. " + CTRL + " .. key, "Move window and switch to workspace " .. workspace, hl.dsp.window.move({ workspace = workspace }))
    bind(mainMod .. " + SHIFT + " .. key, "Move window silently to workspace " .. workspace, hl.dsp.window.move({ workspace = workspace, silent = true }))
end

bind(mainMod .. " + PERIOD", "Scroll through workspaces incrementally", hl.dsp.focus({ workspace = "e+1" }))
bind(mainMod .. " + COMMA", "Scroll through workspaces decrementally", hl.dsp.focus({ workspace = "e-1" }))
bind(mainMod .. " + mouse_down", "Scroll through workspaces incrementally", hl.dsp.focus({ workspace = "e+1" }))
bind(mainMod .. " + mouse_up", "Scroll through workspaces decrementally", hl.dsp.focus({ workspace = "e-1" }))
bind(mainMod .. " + slash", "Switch to the previous workspace", hl.dsp.focus({ workspace = "previous" }))
bind(mainMod .. " + minus", "Move active window to Special workspace", hl.dsp.window.move({ workspace = "special" }))
bind(mainMod .. " + equal", "Toggles the Special workspace", hl.dsp.workspace.toggle_special("special"))
bind(mainMod .. " + F1", "Call special workspace scratchpad", hl.dsp.workspace.toggle_special("scratchpad"))
bind(mainMod .. " + ALT + SHIFT + F1", "Move active window to scratchpad", hl.dsp.window.move({ workspace = "special:scratchpad", silent = true }))

bind(mainMod .. " + ALT + F3", "Disable DVI-D-1 monitor", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/toggle_monitor.sh DVI-D-1"))
bind(mainMod .. " + ALT + F4", "Restart DVI-D-1 monitor", hl.dsp.exec_cmd('$HOME/.config/hypr/scripts/restart_monitor.sh DVI-D-1 "preferred, auto-left, 1"'))
bind(mainMod .. " + S", "Swap active workspaces between monitors", hl.dsp.workspace.swap_monitors("HDMI-A-1 DVI-D-1"))
bind("PRINT", "Full screenshot (grim + swappy)", hl.dsp.exec_cmd(apps.captureFull))
bind(mainMod .. " + PRINT", "Output screenshot (slurp output + swappy)", hl.dsp.exec_cmd(apps.captureOutput))
bind(mainMod .. " + SHIFT + PRINT", "Region screenshot (grim + slurp + swappy)", hl.dsp.exec_cmd(apps.capturing))
