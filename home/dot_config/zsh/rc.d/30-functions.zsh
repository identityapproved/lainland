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

# Local LLM (ollama) on demand. Deliberately not a runit service: this is the
# no-internet fallback for Neovim FIM/chat, wanted occasionally rather than
# always, and a server that is not listening is also not an attack surface.
# Inert on hosts where ollama runs under podman.
# Runbook: ~/zettelnotes/adeg_local-llm-fim-and-chat-in-neovim.md
function ollama-up() {
  local host="${OLLAMA_HOST:-127.0.0.1:11434}"
  if curl -fsS -m 1 "http://${host}" >/dev/null 2>&1; then
    print -r -- "ollama already running on ${host}"
    return 0
  fi
  command -v ollama >/dev/null || { print -ru2 -- "ollama not installed"; return 1; }

  local log="${XDG_STATE_HOME:-$HOME/.local/state}/ollama.log"
  mkdir -p "${log:h}"
  nohup ollama serve >>"$log" 2>&1 &!

  local i
  for i in {1..30}; do
    sleep 0.5
    if curl -fsS -m 1 "http://${host}" >/dev/null 2>&1; then
      print -r -- "ollama up on ${host} (log: ${log})"
      return 0
    fi
  done
  print -ru2 -- "ollama did not come up within 15s; see ${log}"
  return 1
}

# Drop the GPU runtimes ollama's installer ships. None of them can load on a
# machine with no NVIDIA card, and Mesa ANV does not support Gen7 Bay Trail
# graphics either, so the vulkan backend cannot initialise. ~2GB of the 2.1GB
# install. Every upgrade re-deposits all three, so this is re-run after each.
function ollama-prune() {
  local lib="$HOME/.local/lib/ollama"
  [[ -d $lib ]] || { print -ru2 -- "no user ollama runtime at $lib"; return 1; }
  local before="$(du -sh $lib | cut -f1)"
  rm -rf $lib/cuda_v12 $lib/cuda_v13 $lib/vulkan
  print -r -- "ollama runtime: ${before} -> $(du -sh $lib | cut -f1)"
  if [[ ! -e $lib/libggml-cpu-sse42.so ]]; then
    print -ru2 -- "WARNING: libggml-cpu-sse42.so missing -- this build will not run on a CPU without AVX"
  fi
}
