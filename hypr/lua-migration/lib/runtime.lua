local function make_noop_table()
    local proxy = {}

    setmetatable(proxy, {
        __call = function()
            return proxy
        end,
        __index = function()
            return proxy
        end,
    })

    return proxy
end

local runtime = {}

runtime.hl = rawget(_G, "hl") or make_noop_table()
runtime.mainMod = "SUPER"

runtime.apps = {
    terminal = "kitty",
    tmux = "kitty -e tmux",
    termfloat = "kitty --title termfloat",
    fileManager = "kitty -e yazi",
    menu = "tofi-drun",
    locker = "hyprlock",
    captureFull = "$HOME/.config/hypr/scripts/screenshot_swappy.sh full",
    captureOutput = "$HOME/.config/hypr/scripts/screenshot_swappy.sh output",
    capturing = "$HOME/.config/hypr/scripts/screenshot_swappy.sh region",
}

function runtime.window_rule(name, match, props)
    local rule = {
        name = name,
        match = match,
    }

    for key, value in pairs(props) do
        rule[key] = value
    end

    runtime.hl.window_rule(rule)
end

function runtime.bind(keys, description, dispatcher, opts)
    opts = opts or {}
    opts.description = description
    runtime.hl.bind(keys, dispatcher, opts)
end

return runtime
