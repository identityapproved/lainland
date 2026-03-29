# Ensure user-local commands (including linked workflow scripts) are discoverable.
if test -d $HOME/.local/bin
    if not contains -- $HOME/.local/bin $PATH
        set -gx PATH $HOME/.local/bin $PATH
    end
end

# Ensure Nimble-installed commands are available.
if test -d $HOME/.nimble/bin
    if not contains -- $HOME/.nimble/bin $PATH
        set -gx PATH $HOME/.nimble/bin $PATH
    end
end
