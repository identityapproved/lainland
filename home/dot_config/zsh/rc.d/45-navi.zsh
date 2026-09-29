# navi -- CTRL-G opens the cheatsheet picker and replaces the current line with
# the chosen snippet, prompting for each <placeholder> on the way.
#
# Cheats are not configured here and are not in this repo. They live in
# $XDG_DATA_HOME/navi/cheats, populated per host with `navi repo add <url>`;
# which repos a machine has is what decides what its picker offers.
#
# Guarded on the binary, same as starship in 50-tools.zsh and zoxide in 99:
# navi comes from the guru overlay on Gentoo and from `cargo install` everywhere
# else, so a host is easily one shell restart ahead of its install, and an
# unguarded eval would abort the rest of rc.d.
if command -v navi >/dev/null 2>&1; then
  export NAVI_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/navi/config.yaml"

  # Deferred through zvm_after_init for the same reason as fzf's CTRL-R in
  # 40-keybindings.zsh: `navi widget zsh` ends in `bindkey '^g' _navi_widget`,
  # and zsh-vi-mode rebuilds the viins keymap on the first prompt, silently
  # dropping bindings made before it runs. A bare eval here produces a widget
  # that looks installed and never fires.
  #
  # ^G was zsh's default send-break; CTRL-C covers that, and ^G is navi's
  # upstream binding.
  zvm_after_init_commands+=('eval "$(navi widget zsh)"')
fi
