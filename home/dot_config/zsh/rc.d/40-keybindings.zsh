# fzf key-bindings: CTRL-R history, CTRL-T files, ALT-C cd.
# Deferred via zvm_after_init: zsh-vi-mode rebuilds the viins keymap on the first
# prompt and would otherwise clobber fzf's insert-mode CTRL-R (leaving normal mode
# working but insert mode falling back to zsh's default history search).
# Completions (_fzf) come from /usr/share/zsh/site-functions via compinit.
zvm_after_init_commands+=('source /usr/share/fzf/key-bindings.zsh')

# fzf colors -- Lain. Palette: lain-colors.md (private repo).
#   fg/fg+   foreprimary #CE7688     list text, chrome
#   bg+      backtertiary #2A2A2A    cursor row fill (rose text stays legible)
#   hl/hl+   highprimary #C1B48E     search match
#   info     foresenary #804654      counters
#   prompt   highprimary             the ">" itself
#   pointer  accent #FFB1C3          cursor arrow, peak rose
#   marker   success-fg #FFDCB9      multi-select ticks
#   header   foresenary              dimmed
# bg and gutter stay -1 so fzf inherits kitty's translucent background.
export FZF_DEFAULT_OPTS='--reverse --preview="bat {}" --info=inline --color=fg:#CE7688,bg:-1,hl:#C1B48E --color=fg+:#CE7688,bg+:#2A2A2A,gutter:-1,hl+:#C1B48E --color=info:#804654,prompt:#C1B48E,pointer:#FFB1C3 --color=marker:#FFDCB9,spinner:#FFDCB9,header:#804654'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :100 {}'"
export FZF_ALT_C_OPTS="--preview 'ls -1 {}'"
