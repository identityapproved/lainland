# Completion styling. Styles are looked up lazily at completion time, so setting
# them after OMZ's compinit is fine.
#
# The rice's completion dir is placed twice. 00-omz.zsh adds it before compinit
# so its #compdef lines are read; this moves it back to the front, because OMZ
# prepends its own dirs and ~/.oh-my-zsh/completions carries an older _nb that
# would otherwise win when the function autoloads.
_rice_comp="${${(%):-%x}:A:h:h}/completions"
fpath=("$_rice_comp" ${fpath:#$_rice_comp})
unset _rice_comp
zstyle ':completion::complete:*' use-cache 1
