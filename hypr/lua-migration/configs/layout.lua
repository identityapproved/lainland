local hl = require("lib.runtime").hl

hl.config({
    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
        mfact = 0.6,
        new_on_active = "after",
    },
})
