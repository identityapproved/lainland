# oh-my-zsh core. Everything OMZ reads at load time (update mode, HIST_STAMPS,
# plugins) must be set BEFORE sourcing oh-my-zsh.sh — hence it all lives here.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""                       # prompt is Starship, configured in 50-tools.zsh

zstyle ':omz:update' mode auto
HIST_STAMPS="dd.mm.yyyy"

# extract (x <archive>), history (h/hs/hsi) and zsh-completions are OMZ-side
# additions; zsh-completions extends fpath before OMZ's own compinit, so it does
# not clash with 10-completion.zsh, which runs after.
#
# Deliberately NOT here: the `fzf` plugin. It sources
# /usr/share/fzf/key-bindings.zsh at plugin-load time, while 40-keybindings.zsh
# defers that same source into zvm_after_init_commands -- because zsh-vi-mode
# rebuilds the viins keymap on the first prompt and would clobber fzf's CTRL-R.
# Loading both double-binds and reintroduces exactly that bug.
plugins=(
  git
  gitignore
  web-search
  pip
  python
  extract
  history
  zsh-completions
  zsh-syntax-highlighting
  zsh-autosuggestions
  zsh-vi-mode
  zsh-git-fzf
  alias-tips
)

# zsh-vi-mode draws its own cursor shapes, which fights the terminfo-based
# _zsh_vi_cursor in 40-keybindings.zsh -- both would write an escape sequence on
# every keymap change. Ours wraps the escape in a tmux DCS passthrough, which is
# what makes the beam/block switch actually reach the terminal from inside a
# pane, so ours wins and the plugin's is turned off. Must be set before the
# plugin loads, hence here rather than in 40.
ZVM_CURSOR_STYLE_ENABLED=false

# History. OMZ's lib/history.zsh runs inside oh-my-zsh.sh below and caps SAVEHIST
# at 10000 (`[ "$SAVEHIST" -lt 10000 ] && SAVEHIST=10000` -- a floor, not a
# ceiling, so a larger value set here survives). It sets extended_history,
# hist_expire_dups_first, hist_ignore_dups, hist_ignore_space, hist_verify and
# share_history; the four below are the ones it does not.
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS   # not just consecutive duplicates
setopt HIST_REDUCE_BLANKS
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY     # write as each command runs, not on exit

source "$ZSH/oh-my-zsh.sh"
