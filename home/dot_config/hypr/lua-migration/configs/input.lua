local hl = require("lib.runtime").hl

hl.config({
    input = {
        kb_layout = "us,ua",
        kb_options = "grp:alt_shift_toggle",
        follow_mouse = 1,
        mouse_refocus = false,
        touchpad = {
            natural_scroll = false,
        },
        sensitivity = 0,
    },

    cursor = {
        inactive_timeout = 1,
        hide_on_key_press = true,
        no_hardware_cursors = true,
    },
})

hl.device({
    name = "epic-mouse-v1",
})
