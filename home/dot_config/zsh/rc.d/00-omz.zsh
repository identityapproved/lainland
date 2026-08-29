# oh-my-zsh core. Everything OMZ reads at load time (update mode, HIST_STAMPS,
# plugins) must be set BEFORE sourcing oh-my-zsh.sh — hence it all lives here.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""                       # prompt is Starship, configured in 50-tools.zsh

zstyle ':omz:update' mode auto
HIST_STAMPS="dd.mm.yyyy"

plugins=(
  git
  gitignore
  web-search
  pip
  python
  zsh-syntax-highlighting
  zsh-autosuggestions
  zsh-vi-mode
  zsh-git-fzf
  alias-tips
)

source "$ZSH/oh-my-zsh.sh"
