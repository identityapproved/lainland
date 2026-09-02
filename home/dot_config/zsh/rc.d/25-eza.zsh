# eza — listing and tree. There is no sys-apps/tree on this host, so the -T
# family below is the tree command.
#
# Loads at 25, i.e. after 00-omz.zsh (whose lib/directories.zsh defines
# l/ll/la/lsa in terms of coreutils ls) and after 20-aliases.zsh, so these win.
# Without eza nothing is touched and OMZ's ls aliases stay in effect.
#
# All names are lowercase. Every alias takes extra flags and paths, so the
# variants are composable: `ldirs -a`, `lt --git-ignore src`, `ll -s size`.

if command -v eza >/dev/null 2>&1; then
  # Colour. 15-dircolors.zsh already set LS_COLORS from the repo's indexed Lain
  # profile, and eza reads LS_COLORS first; EZA_COLORS then overrides the keys
  # below with the truecolor hexes, which the 256-colour cube cannot express.
  # Roles resolved through the Semantic Role Map in lain-colors.md:
  #
  #   ur/gr/tr  read bits    hightertiary  #A49978
  #   uw/gw/tw  write bits   foreprimary   #CE7688
  #   ux/gx/tx  exec bits    accent        #FFB1C3
  #   ue        setuid       accent        #FFB1C3
  #   sn        size number  highprimary   #C1B48E
  #   sb        size unit    highsenary    #7A7158
  #   da        date         foresenary    #804654
  #   di        directory    highprimary   #C1B48E
  #   ln        symlink      foreprimary   #CE7688
  #   ex        executable   accent        #FFB1C3
  export EZA_COLORS="\
ur=38;2;164;153;120:\
uw=38;2;206;118;136:\
ux=38;2;255;177;195:\
ue=38;2;255;177;195:\
gr=38;2;164;153;120:\
gw=38;2;206;118;136:\
gx=38;2;255;177;195:\
tr=38;2;164;153;120:\
tw=38;2;206;118;136:\
tx=38;2;255;177;195:\
sn=38;2;193;180;142:\
sb=38;2;122;113;88:\
da=38;2;128;70;84:\
di=38;2;193;180;142:\
ln=38;2;206;118;136:\
ex=38;2;255;177;195"

  # Flags every listing gets. --icons=auto and --color=auto draw glyphs/colour
  # only on a tty, so piping stays parseable. --no-quotes drops the quoting eza
  # adds around names with spaces.
  #
  # The array stays defined: the aliases below bake it in at definition time,
  # but the functions at the bottom read it when they run.
  typeset -ga _eza_flags=(
    --group-directories-first
    --icons=auto
    --color=auto
    --no-quotes
  )
  _eza="eza ${_eza_flags}"

  # Long form: --smart-group hides the group column when it matches the owner,
  # --git annotates tracked files, relative times read faster than timestamps.
  _eza_l="$_eza --long --header --smart-group --git --time-style=relative"

  # --- core listings ------------------------------------------------------
  alias ls="$_eza"
  alias l="$_eza_l --all"                  # OMZ muscle memory: was ls -lah
  alias ll="$_eza_l"
  alias la="$_eza_l --all"
  alias lla="$_eza_l --all"
  alias lsa="$_eza_l --all"
  alias laa="$_eza_l --all --all"          # -aa also shows . and ..
  alias l1="$_eza --oneline"
  alias lg="$_eza_l --git-repos"           # + repo state on directories
  alias lgi="$_eza --git-ignore"           # hide what .gitignore hides
  # Spelled out rather than `ld`, which is /usr/bin/ld, the linker.
  alias ldirs="$_eza_l --only-dirs"
  alias lfiles="$_eza_l --only-files"
  alias ldot="$_eza_l --list-dirs .*"      # dotfiles/dirs themselves

  # --- sorting ------------------------------------------------------------
  alias lm="$_eza_l --sort=modified"                 # oldest first
  alias lmr="$_eza_l --sort=modified --reverse"      # newest first
  alias lsz="$_eza_l --sort=size --reverse"          # biggest first
  alias lx="$_eza_l --sort=extension"
  alias lu="$_eza_l --accessed --sort=accessed --reverse"
  alias lc="$_eza_l --created --sort=created --reverse"  # birth time; "-" if the fs has none

  # --- detail views -------------------------------------------------------
  alias lo="$_eza_l --octal-permissions"
  alias li="$_eza_l --inode"
  alias lb="$_eza_l --binary"              # KiB/MiB instead of kB/MB
  alias ltot="$_eza_l --only-dirs --total-size"  # du-ish: walks each dir
  alias lr="$_eza_l --recurse"
  alias lrec="$_eza --recurse"             # same, grid instead of long

  # --- trees --------------------------------------------------------------
  alias tree="$_eza --tree"
  alias lt="$_eza --tree --level=2"
  alias lt1="$_eza --tree --level=1"
  alias lt2="$_eza --tree --level=2"
  alias lt3="$_eza --tree --level=3"
  alias lt4="$_eza --tree --level=4"
  alias lt5="$_eza --tree --level=5"
  alias lta="$_eza --tree --level=2 --all"
  alias ltl="$_eza_l --tree --level=2"
  alias ltd="$_eza --tree --only-dirs"     # directory skeleton, full depth
  alias ltgi="$_eza --tree --git-ignore"   # tree of a repo without the junk
  alias lts="$_eza --tree --level=2 --long --no-permissions --no-user --no-time"  # sizes only

  # Arbitrary depth: ltn 3 [path…]
  ltn() {
    local lvl=${1:-2}
    shift 2>/dev/null
    eza $_eza_flags --tree --level="$lvl" "$@"
  }

  # List after every cd. This is zsh's own chpwd hook — it replaces the cd-ls
  # plugin, which did the same thing through `eval ${CD_LS_COMMAND:-ls}`.
  # add-zsh-hook refuses duplicates, so re-sourcing this file is safe.
  # The explicit "." matters: no-arg eza lists nothing in a non-tty shell.
  _eza_chpwd() { eza $_eza_flags . }
  autoload -Uz add-zsh-hook
  add-zsh-hook chpwd _eza_chpwd

  unset _eza _eza_l
fi
