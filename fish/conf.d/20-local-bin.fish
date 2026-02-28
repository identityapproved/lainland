# Ensure user-local commands (including linked workflow scripts) are discoverable.
if test -d $HOME/.local/bin
    if not contains -- $HOME/.local/bin $PATH
        set -gx PATH $HOME/.local/bin $PATH
    end
end
