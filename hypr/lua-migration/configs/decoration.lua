local runtime = require("lib.runtime")
local hl = runtime.hl

hl.config({
    decoration = {
        rounding = 0,
        fullscreen_opacity = 1,
        blur = {
            enabled = true,
            xray = true,
            size = 2,
            passes = 1,
            new_optimizations = true,
            noise = 0.05,
            contrast = 1.0,
            brightness = 0.9,
            special = false,
            ignore_opacity = true,
        },
        shadow = {
            enabled = true,
            range = 20,
            render_power = 3,
            color = runtime.colors.shadow_active,
            color_inactive = runtime.colors.shadow_inactive,
        },
    },
})
