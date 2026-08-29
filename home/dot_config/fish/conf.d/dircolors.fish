if command -q dircolors
    set -l dcfile "$HOME/.config/dircolors/dircolors"
    if test -f "$dcfile"
        # Convert csh-style output from dircolors into fish exports.
        eval (dircolors -c "$dcfile" | sed 's/^setenv /set -gx /; s/;$/ /')
    end
end
