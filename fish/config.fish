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
        --color=fg:#CE7688,bg:#000000,hl:#C1B48E \
        --color=fg+:#FFB1C3,bg+:#1A1A1A,hl+:#C1B48E \
        --color=info:#804654,prompt:#FFB1C3,pointer:#C1B48E \
        --color=marker:#FFB1C3,spinner:#C1B48E,header:#B5A985 \
        --color=border:#3A3A3A,gutter:#000000,separator:#2A2A2A \
        --color=preview-fg:#CE7688,preview-bg:#000000,preview-border:#3A3A3A"

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
        set -l cmd (complete -C "" | string replace -r '\t.*' '' | sort -u | fzf --height 40% --layout reverse --border --no-preview)
        test -n "$cmd"; and man $cmd
    end

    function ftldr
        if test (count $argv) -gt 0
            tldr $argv
            return
        end

        set -l cmd (complete -C "" | string replace -r '\t.*' '' | sort -u | fzf --height 40% --layout reverse --border --no-preview)
        test -n "$cmd"; and tldr $cmd
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
    alias twl="task list"
    alias auds="sudo auditctl -s"
    alias audl="sudo auditctl -l"
    alias audroot="sudo ausearch -k root_action -i"
    alias audmods="sudo ausearch -k kernel_modules -i"
    alias audnet="sudo ausearch -k network_outbound -i"
    alias audjson="sudo ausearch --format json -ts recent | jq | bat -l json"

    function tws
        if not type -q fzf
            echo "tws requires fzf"
            return 1
        end

        set -l query (string join ' ' -- $argv)
        set -l selected (
            task rc.color=off rc._forcecolor=no rc.defaultwidth=1000 list | awk '
                NR <= 3 { next }
                /^[[:space:]]*$/ { next }
                /^[[:space:]]*[0-9]+ tasks?[[:space:]]*$/ { next }
                { print }
            ' | fzf --query="$query" --height 80% --layout=reverse --border \
                --header="Taskwarrior search"
        )
        or return

        set -l id (printf '%s\n' "$selected" | awk '{print $1}')
        test -n "$id"; and task "$id" info
    end

    alias t="trans"
    alias cr="codex resume"
    alias kssh="kitty +kitten ssh"

    function mpvpl
        find . -type d | fzf | xargs -I{} find "{}" -type f | sort -V | mpv --playlist=-
    end

    function fbook
        find ~/* -type d \( -name books \) -exec find {} -type f \( -name "*.pdf" -o -name "*.epub" -o -name "*.mobi" -o -name "*.cbz" -o -name "*.cbr" \) \; \
            | fzf --height 40% --layout reverse --border --no-preview \
            | xargs -r -I {} sh -c "zathura \"{}\" &"
    end

    function wptui-default-sink
        set -l candidates

        for line in (wpctl status --name \
            | awk '
                /Sinks:/   { in_audio_sinks=1; next }
                /Sources:/ { in_audio_sinks=0 }
                /Filters:/ { in_filters=1; next }
                /Streams:/ { in_filters=0 }

                (in_audio_sinks || in_filters) && /[0-9]+\./
            ' \
            | sed -E 's/.* ([0-9]+)\.[[:space:]]+(.*)/\1 \2/')

            set -l id (string split -m1 ' ' -- $line)[1]

            if wpctl inspect $id 2>/dev/null | rg -q 'media.class = "Audio/Sink"'
                set candidates $candidates $line
            end
        end

        set -l selected (printf '%s\n' $candidates | fzf --prompt='Select sink > ')
        or return

        set -l id (string split -m1 ' ' -- $selected)[1]
        test -n "$id"; and wpctl set-default $id
    end

    function fzf-history-preview
        if not type -q fzf
            return 1
        end

        set -l cmd (
            history | fzf --tac \
                --height 80% \
                --layout=reverse \
                --border \
                --preview 'echo {}' \
                --preview-window=down:3:wrap
        )
        or return

        test -n "$cmd"; and commandline --replace -- "$cmd"
        commandline -f repaint
    end

    bind \cr fzf-history-preview

    alias rmpkg="sudo pacman -Rsn"
    alias cleanch="sudo pacman -Scc"
    alias fixpacman="sudo rm /var/lib/pacman/db.lck"
    alias update="sudo pacman -Syu"
    alias cleanup="sudo pacman -Rsn (pacman -Qtdq)"
    alias virsh="virsh -c qemu:///system"

    alias wlpn="wpaperctl next"
    alias clipc="wl-copy </dev/null"

    # Podman + fzf helpers
    function pstart
        set -l selected (podman ps -a --format "{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}" | \
            fzf --height 40% --reverse --border --header "select container to start")
        test -z "$selected"; and return
        podman start (echo "$selected" | awk '{print $1}')
    end

    function pstop
        set -l selected (podman ps --format "{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}" | \
            fzf --height 40% --reverse --border --header "select container to stop")
        test -z "$selected"; and return
        podman stop (echo "$selected" | awk '{print $1}')
    end

    function prm
        set -l selected (podman ps -a --format "{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}" | \
            fzf --height 40% --reverse --border --header "select container to remove")
        test -z "$selected"; and return
        podman rm (echo "$selected" | awk '{print $1}')
    end

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
