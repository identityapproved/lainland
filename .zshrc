# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export EDITOR="/usr/bin/nvim"
export PATH="$HOME/.emacs.d/bin:$PATH"
# export EMACS="$HOME/.config/emacs/bin"
export GOPATH="$HOME/go"
export XDG_DATA_HOME=$HOME/.local/share

ZSH_THEME="random"

zstyle ':omz:update' mode auto      # update automatically without asking

HIST_STAMPS="dd.mm.yyyy"

# Plugins
# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md
# https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md
# https://github.com/zshzoo/cd-ls
# https://github.com/alexiszamanidis/zsh-git-fzf
# https://github.com/jeffreytse/zsh-vi-mode
# https://github.com/djui/alias-tips
# https://github.com/thirteen37/fzf-alias
plugins=(git gitignore web-search pip python zsh-syntax-highlighting zsh-autosuggestions docker docker-compose zsh-vi-mode cd-ls zsh-git-fzf zsh-wakatime alias-tips ufw themes fzf-alias archlinux emacs)

source $ZSH/oh-my-zsh.sh
source $HOME/.aliases

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS='--reverse --preview="bat {}" --info=inline --color=fg:#f8f8f2,bg:-1,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:-1,gutter:-1,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'

# Loads FZF keybindings, replacing native reverse search etc with FZF
[[ -e "/usr/share/fzf/key-bindings.zsh" ]] \
  && source "/usr/share/fzf/key-bindings.zsh"

function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# nVim Fuzy Find
function vff() {
  # All config paths are prefixed with ~/.config/nvim-
  local config=$(fd --max-depth 1 --glob 'nvim-*' ~/.config | fzf --prompt="Neovim Configs > " --height=15% --layout=reverse --border --exit-0)

  [[ -z $config ]] && echo "No config selected, Neovim not starting" && return

  # Open Neovim with selected config
  NVIM_APPNAME=$(basename $config) nvim $@
}

eval "$(zoxide init --cmd cd zsh)"

eval $(thefuck --alias)

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

krabby random -i

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"
