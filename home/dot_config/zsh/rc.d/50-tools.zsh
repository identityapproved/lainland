# External tool init and long-lived agents. zoxide lives in 99-zoxide.zsh so it
# always initializes last, whatever gets dropped into rc.d after this file.

# SSH agent — start once, persist env to ~/.ssh/environment, reuse across shells.
SSH_ENV="$HOME/.ssh/environment"
_start_ssh_agent() {
  ssh-agent | sed 's/^echo/#echo/' > "$SSH_ENV"
  chmod 600 "$SSH_ENV"
  source "$SSH_ENV" >/dev/null
}
[ -f "$SSH_ENV" ] && source "$SSH_ENV" >/dev/null
if ! ps -p "${SSH_AGENT_PID:-0}" >/dev/null 2>&1; then
  _start_ssh_agent
fi

# Starship prompt (Lain palette) — must come after OMZ so it wins the prompt.
eval "$(starship init zsh)"

# uv / cargo shims (adds ~/.local/bin to PATH; guarded, harmless re-run).
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# OpenCode shell completion.
if command -v opencode >/dev/null 2>&1; then
  eval "$(opencode completion zsh)"
fi
