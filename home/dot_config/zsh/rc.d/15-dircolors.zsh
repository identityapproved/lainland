# LS_COLORS from the repo's Lain dircolors profile.
#
# Loads at 15 so it lands before 25-eza.zsh: eza honours LS_COLORS, so this
# recolors both coreutils `ls` and every eza alias defined there. Nothing in
# the zsh tree set this before -- only fish/conf.d/dircolors.fish did -- so the
# themed profile in ~/.config/dircolors/dircolors was inert under zsh.
#
# Index-based, not truecolor: see the 256-color table in lain-colors.md.
if command -v dircolors >/dev/null 2>&1; then
  _dc="${XDG_CONFIG_HOME:-$HOME/.config}/dircolors/dircolors"
  if [[ -r $_dc ]]; then
    eval "$(dircolors -b "$_dc")"
  fi
  unset _dc
fi
