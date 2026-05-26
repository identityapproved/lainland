local hl = require("lib.runtime").hl

local workspaces = {
    { workspace = "1", monitor = "HDMI-A-1", default = true, layout = "dwindle" },
    { workspace = "2", monitor = "HDMI-A-1", layout = "master" },
    { workspace = "3", monitor = "HDMI-A-1", layout = "master" },
    { workspace = "4", monitor = "HDMI-A-1", layout = "master" },
    { workspace = "5", monitor = "HDMI-A-1", layout = "dwindle" },
    { workspace = "6", monitor = "DVI-D-1", default = true, layout = "master" },
    { workspace = "7", monitor = "DVI-D-1", layout = "dwindle" },
    { workspace = "8", monitor = "DVI-D-1", layout = "master" },
    { workspace = "9", monitor = "DVI-D-1", layout = "dwindle" },
    { workspace = "10", monitor = "DVI-D-1", layout = "master" },
    { workspace = "w[tv1-10]", gaps_out = 5, gaps_in = 3 },
    { workspace = "f[1]", gaps_out = 5, gaps_in = 3 },
}

for _, rule in ipairs(workspaces) do
    hl.workspace_rule(rule)
end
