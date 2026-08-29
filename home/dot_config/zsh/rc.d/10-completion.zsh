# Completion styling. Styles are looked up lazily at completion time, so setting
# them after OMZ's compinit is fine.
fpath=("${${(%):-%x}:A:h:h}/completions" $fpath)
zstyle ':completion::complete:*' use-cache 1
