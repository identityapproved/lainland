#!/bin/bash

ZSH_CUSTOM_PLUGINS=${ZSH_CUSTOM:-~/.oh-my-zsh/custom/plugins}

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM_PLUGINS/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM_PLUGINS/zsh-autosuggestions
git clone https://github.com/zshzoo/cd-ls $ZSH_CUSTOM_PLUGINS/cd-ls
git clone https://github.com/jeffreytse/zsh-vi-mode $ZSH_CUSTOM_PLUGINS/zsh-vi-mode
git clone https://github.com/djui/alias-tips.git $ZSH_CUSTOM_PLUGINS/alias-tips
git clone https://github.com/thirteen37/fzf-alias.git $ZSH_CUSTOM_PLUGINS/fzf-alias
git clone https://github.com/wbingli/zsh-wakatime.git $ZSH_CUSTOM_PLUGINS/zsh-wakatime
wget -q https://raw.githubusercontent.com/alexiszamanidis/zsh-git-fzf/master/install -O install && chmod +x install && ./install && rm -rf ./install

