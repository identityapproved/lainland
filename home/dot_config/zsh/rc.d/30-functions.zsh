# yazi: cd to the directory yazi was left in on exit.
function yy() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# nvim fuzzy config switcher (NVIM_APPNAME) over ~/.config/nvim-*.
function vff() {
  local config=$(fd --max-depth 1 --glob 'nvim-*' ~/.config | fzf --prompt="Neovim Configs > " --height=15% --layout=reverse --border --exit-0)
  [[ -z "$config" ]] && echo "No config selected" && return
  NVIM_APPNAME=$(basename "$config") nvim "$@"
}
