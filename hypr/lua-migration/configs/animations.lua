local hl = require("lib.runtime").hl

hl.config({
    animations = {
        enabled = true,
    },
})

hl.curve("myBezier", { type = "bezier", points = { { 0.14, 0.92 }, { 0.16, 1.00 } } })
hl.curve("flatline", { type = "bezier", points = { { 1.0, 1.0 }, { 0, 0 } } })
hl.curve("flatlinetwo", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("shuff", { type = "bezier", points = { { 0, 0.33 }, { 0.66, 1.0 } } })
hl.curve("BorderRotation", { type = "bezier", points = { { 0.38, 0 }, { 0.62, 1 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "myBezier" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, bezier = "myBezier" })
hl.animation({ leaf = "border", enabled = true, speed = 40, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 64, bezier = "flatlinetwo", style = "loop" })
hl.animation({ leaf = "fade", enabled = true, speed = 4, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "myBezier" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2, bezier = "myBezier", style = "slidevert" })
