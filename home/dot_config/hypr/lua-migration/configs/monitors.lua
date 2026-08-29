local hl = require("lib.runtime").hl

hl.monitor({
    output = "HDMI-A-1",
    mode = "preferred",
    position = "auto",
    scale = 1,
})

hl.monitor({
    output = "DVI-D-1",
    disabled = true,
})

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})
