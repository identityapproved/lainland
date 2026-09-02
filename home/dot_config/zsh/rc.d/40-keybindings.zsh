# fzf key-bindings: CTRL-R history, CTRL-T files, ALT-C cd.
# Deferred via zvm_after_init: zsh-vi-mode rebuilds the viins keymap on the
# first prompt and would otherwise clobber fzf's insert-mode CTRL-R.
# Completions (_fzf) come from /usr/share/zsh/site-functions via compinit.
zvm_after_init_commands+=('source /usr/share/fzf/key-bindings.zsh')

# fzf colors -- Lain. fg/fg+ #CE7688, bg+ #2A2A2A, hl/hl+ #C1B48E,
# info/header #804654, prompt #C1B48E, pointer #FFB1C3, marker #FFDCB9.
# bg and gutter stay -1 so fzf inherits kitty's translucent background.
export FZF_DEFAULT_OPTS='--reverse --preview="bat {}" --info=inline --color=fg:#CE7688,bg:-1,hl:#C1B48E --color=fg+:#CE7688,bg+:#2A2A2A,gutter:-1,hl+:#C1B48E --color=info:#804654,prompt:#C1B48E,pointer:#FFB1C3 --color=marker:#FFDCB9,spinner:#FFDCB9,header:#804654'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :100 {}'"
export FZF_ALT_C_OPTS="--preview 'ls -1 {}'"

# Cursor shape per vi mode: beam in insert, block in command. zsh-vi-mode's own
# version is disabled in 00-omz.zsh (ZVM_CURSOR_STYLE_ENABLED=false) in favour of
# this one, for the tmux branch below: inside a pane the escape has to be wrapped
# in a DCS passthrough or tmux swallows it and the shape never changes.
#
# echoti is avoided deliberately -- terminfo has no Ss/Se capability on either
# terminal here, so the sequence is written raw.
_zsh_vi_cursor() {
  local shape
  case "$KEYMAP" in
    vicmd)      shape=2 ;;  # block
    viins|main) shape=6 ;;  # beam
  esac
  [[ -n $TMUX ]] && printf '\ePtmux;\e\e[%d q\e\\' "$shape" \
                 || printf '\e[%d q' "$shape"
}

zle -N zle-keymap-select _zsh_vi_cursor
zle -N zle-line-init     _zsh_vi_cursor

autoload -Uz add-zsh-hook
add-zsh-hook precmd _zsh_vi_cursor
