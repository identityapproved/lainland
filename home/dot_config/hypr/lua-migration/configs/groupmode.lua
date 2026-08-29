local hl = require("lib.runtime").hl

hl.config({
    group = {
        groupbar = {
            enabled = true,
            height = 18,
            font_size = 15,
            font_family = "Iosevka Nerd Font Propo",
            text_padding = 6,
            middle_click_close = true,
            gradients = false,
            col = {
                active = "rgba(CE7688ff)",
                inactive = "rgba(5D333Cff)",
                locked_active = "rgba(BA6A7Bff)",
                locked_inactive = "rgba(49272Fff)",
            },
            text_color = "rgba(FFDCB9ff)",
        },
    },
})
