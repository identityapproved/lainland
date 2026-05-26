local runtime = require("lib.runtime")

runtime.colors = {
    back_1 = "rgb(000000)",
    back_2 = "rgb(1A1A1A)",
    back_3 = "rgb(2A2A2A)",

    fore_1 = "rgb(CE7688)",
    fore_2 = "rgb(BA6A7B)",
    fore_3 = "rgb(A05969)",
    fore_4 = "rgb(965363)",

    high_1 = "rgb(C1B48E)",
    high_2 = "rgb(B5A985)",
    high_3 = "rgb(A49978)",

    shadow_active = "0xCE768866",
    shadow_inactive = "0x1A1A1Acc",
}

runtime.lain_border_gradient = {
    runtime.colors.fore_4,
    runtime.colors.fore_3,
    runtime.colors.fore_2,
    runtime.colors.fore_1,
    runtime.colors.high_3,
    runtime.colors.high_2,
    runtime.colors.high_1,
    runtime.colors.high_2,
    runtime.colors.fore_1,
    runtime.colors.fore_2,
}

return runtime.colors
