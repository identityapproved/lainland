# LS_COLORS from the repo's Lain dircolors profile. Index-based, not truecolor.
# Loads at 15 so it lands before 25-eza.zsh: eza honours LS_COLORS, so this
# recolors coreutils `ls` and every eza alias there. Previously only
# fish/conf.d/dircolors.fish set it, so the profile was inert under zsh.
if command -v dircolors >/dev/null 2>&1; then
  _dc="${XDG_CONFIG_HOME:-$HOME/.config}/dircolors/dircolors"
  if [[ -r $_dc ]]; then
    eval "$(dircolors -b "$_dc")"
  fi
  unset _dc
fi
