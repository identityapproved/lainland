# OpenCode themes

`lain.json` puts OpenCode's TUI on the same Lain palette as the rest of this
repo. Colors resolve through the palette's Semantic Role Map rather than being
picked by eye; `lain-colors.md` itself is a symlink into a private repo and is
gitignored here.

Installed by chezmoi to `~/.config/opencode/themes/lain.json`. Selecting it is
the other repo's job: [agentsdots](https://github.com/identityapproved/agentsdots)
sets `"theme": "lain"` in `config/tui.json`, which it links to
`~/.config/opencode/tui.json`. That split is deliberate — colors live with the
rice, agent behaviour lives with the agent config.

`~/.config/opencode` therefore ends up a real directory holding links from both
repos. They never touch the same path.

## Where the shape came from

The 53-key schema and the file layout follow
[b0o/lavi](https://github.com/b0o/lavi)'s `contrib/opencode` themes, which are
the clearest worked example of an OpenCode theme. None of lavi's colors are
used — only its key set and structure.

## Notes on a few choices

- **`text` is ochre, not rose.** The palette's rule is "rose on black for
  chrome, ochre on black for content". The TUI is mostly a reading pane, so body
  text takes `highprimary` and chrome accents take the Fore ramp.
- **Diffs follow `delta/themes.gitconfig`** rather than red/green: additions
  fill `backsecondary`, removals fill `foreundenary`, gutter `foresenary`. That
  keeps a diff in OpenCode looking like a diff in lazygit or `git diff`.
- **`error` is `accent` #FFB1C3, not `error-bg` #930006.** The palette marks
  #930006 fill-only — as text on black it sits at 2.24:1 and fails contrast.
- **Syntax slots mirror `kitty/themes/lain-theme.conf`.** Nothing in this
  palette is green or blue, so `syntaxVariable` and `syntaxPunctuation` fall
  back to the neutral Back ramp instead of inventing hues.
- **`dark` and `light` carry the same value.** Lain is a dark-only palette;
  claiming a light variant would be a lie.
