# External tool init and long-lived agents. zoxide lives in 99-zoxide.zsh so it
# always initializes last, whatever gets dropped into rc.d after this file.

# SSH agent — one per session on a fixed socket; sway's start-sway usually starts it
# first. Exit 2 from ssh-add means no agent is reachable, so a live one is never replaced.
export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR:-$HOME/.ssh}/ssh-agent.socket"
ssh-add -l >/dev/null 2>&1
[ $? -eq 2 ] && rm -f "$SSH_AUTH_SOCK" && ssh-agent -a "$SSH_AUTH_SOCK" >/dev/null

# Starship prompt (Lain palette) — must come after OMZ so it wins the prompt.
# Guarded on the binary, same as zoxide in 99: an unguarded eval here aborts the
# rest of rc.d on a host where starship is not installed yet.
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
