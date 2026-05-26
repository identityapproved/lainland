local runtime = require("lib.runtime")
local hl = runtime.hl

hl.config({
    general = {
        gaps_in = 3,
        gaps_out = 9,
        border_size = 2,
        resize_on_border = true,
        extend_border_grab_area = 23,
        col = {
            active_border = runtime.lain_border_gradient,
            inactive_border = runtime.colors.fore_4,
        },
        layout = "master",
        allow_tearing = false,
    },
})
