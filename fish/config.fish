if test -f /usr/share/cachyos-fish-config/cachyos-config.fish
    source /usr/share/cachyos-fish-config/cachyos-config.fish
end

# overwrite greeting
# potentially disabling fastfetch
function fish_greeting
    # smth smth
end
# Put system-wide fish configuration entries here
# or in .fish files in conf.d/
# Files in conf.d can be overridden by the user
# by files with the same name in $XDG_CONFIG_HOME/fish/conf.d

# This file is run by all fish instances.
# To include configuration only for login shells, use
# if status is-login
#    ...
# end
# To include configuration only for interactive shells, use
# if status is-interactive
#   ...
# end

if status is-interactive
    fish_vi_key_bindings

    set -gx FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS \
        --color=fg:#7f7094,bg:-1,hl:#b9b1bc \
        --color=fg+:#00986c,bg+:#241b30,hl+:#0ae4a4 \
        --color=info:#aa54f9,prompt:#0ae4a4,pointer:#241b30 \
        --color=marker:#ff00f6,spinner:#aa54f9,header:#f9f972"

    set -gx ZK_NOTEBOOK_DIR $HOME/drives/kodak/zettelnotes

    # SSH agent setup
    set -l ssh_env $HOME/.ssh/environment

    if test -f $ssh_env
        source $ssh_env >/dev/null
    end

    if not ps -p $SSH_AGENT_PID >/dev/null 2>&1
        ssh-agent -c | sed 's/^setenv/set -gx/' >$ssh_env
        source $ssh_env >/dev/null
    end

    #or
    # Start ssh-agent if not already running
    # if not set -q SSH_AUTH_SOCK; or not test -S $SSH_AUTH_SOCK
    #     eval (ssh-agent -c)
    # end

    # Config shortcuts
    alias aliasconfig="nvim ~/.config/fish/config.fish"
    alias tmuxconfig="nvim ~/.config/tmux/tmux.conf"

    function falias
        alias | fzf
    end

    function galias
        git config --get-regexp '^alias\.' | fzf
    end

    # Shell basics
    alias q="exit"
    alias rf="rm -rfi"
    alias c="clear"
    alias ..="cd .."
    alias ...="cd ../../"
    alias ....="cd ../../../"
    alias .....="cd ../../../../"

    function fman
        compgen -c | fzf --height 40% --layout reverse --border --no-preview | xargs man
    end

    function ftldr
        compgen -c | fzf --height 40% --layout reverse --border --no-preview | xargs tldr
    end

    function fcd
        cd ~
        cd (fzf | sed 's/\/[^\/]*$//')
    end

    alias v="nvim"
    function fv
        nvim (fzf)
    end

    function fcat
        set -l file (find . -type f | fzf)
        if test -n "$file"
            cat "$file"
        end
    end

    function fbat
        set -l file (find . -type f | fzf)
        if test -n "$file"
            bat "$file"
        end
    end

    function vt
        nvim (mktemp /tmp/vt-XXXXXX.md)
    end

    alias em="emacsclient -c -a 'emacs'"

    alias yz="yazi"
    alias lz="lazygit"
    alias tl="task list"
    alias t="trans"
    alias cr="codex resume"

    function mpvpl
        find . -type d | fzf | xargs -I{} find "{}" -type f | sort -V | mpv --playlist=-
    end

    function fbook
        find ~/* -type d \( -name books \) -exec find {} -type f \( -name "*.pdf" -o -name "*.epub" -o -name "*.mobi" -o -name "*.cbz" -o -name "*.cbr" \) \; \
            | fzf --height 40% --layout reverse --border --no-preview \
            | xargs -r -I {} sh -c "zathura \"{}\" &"
    end

    alias rmpkg="sudo pacman -Rsn"
    alias cleanch="sudo pacman -Scc"
    alias fixpacman="sudo rm /var/lib/pacman/db.lck"
    alias update="sudo pacman -Syu"
    alias cleanup="sudo pacman -Rsn (pacman -Qtdq)"
    alias virsh="virsh -c qemu:///system"

    alias wlpn="wpaperctl next"
    alias clipc="wl-copy </dev/null"

    # ls replacement
    if type -q eza
        alias ls="eza --group-directories-first --icons"
        alias ll="eza -l --group-directories-first --icons"
        alias la="eza -la --group-directories-first --icons"
        alias l="eza -lart --group-directories-first --icons"
        alias lt="eza --tree --group-directories-first --icons"
        alias l2="eza --tree --level=2 --group-directories-first --icons"
        alias l3="eza --tree --level=3 --group-directories-first --icons"
        alias lg="eza -l --git --group-directories-first --icons"
        alias lga="eza -la --git --group-directories-first --icons"
    else
        alias ls="ls --color=auto"
        alias ll="ls -lh"
        alias la="ls -lha"
        alias l="ls -lart"
    end

    alias make="make -j(nproc)"
    alias ninja="ninja -j(nproc)"
    alias n="ninja"

    alias tb="nc termbin.com 9999"
    alias jctl="journalctl -p 3 -xb"
    alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"

    function pz
        set -l sort_option
        set -l header "Search processes"
        set -l action view

        while test (count $argv) -gt 0
            switch $argv[1]
                case -m --mem
                    set sort_option "--sort=-%mem"
                    set header "Search by memory usage"
                case -k --kill
                    set action kill
                    set header "Kill process"
                case -h --help
                    echo "Usage: pz [-m|--mem] [-k|--kill]"
                    echo "  -m  Sort by memory usage"
                    echo "  -k  Kill selected process"
                    return 0
            end
            set -e argv[1]
        end

        set -l selection (ps aux $sort_option | fzf --ansi --header="$header" \
      --layout=reverse --height=80% \
      --preview='pid=$(echo {} | awk "{print \$2}"); \
      ps -p $pid -o pid= -o ppid= -o user= -o %cpu= -o %mem= -o etime= -o cmd= | \
      awk "{printf \"PID: %s\nPPID: %s\nUSER: %s\nCPU: %s%%\nMEM: %s%%\nELAPSED: %s\nCMD: %s\n\", \$1, \$2, \$3, \$4, \$5, \$6, \$7}"')
        or return

        set -l pid (echo "$selection" | awk '{print $2}')
        test -z "$pid"; and return 1

        if test "$action" = kill
            read -l -P "Kill process PID $pid? [y/N]: " confirm
            if string match -qr '^[Yy]$' -- "$confirm"
                sudo kill -9 "$pid"; and echo "Process $pid killed."
            else
                echo "Canceled."
            end
        else
            echo -n "$pid" | wl-copy
            echo "PID $pid copied to clipboard."
        end
    end

    # Zoxide for smarter directory jumps (replace cd).
    zoxide init fish --cmd cd | source
end
fish_vi_key_bindings
