# OpenCode themes

`lain.json` puts OpenCode's TUI on the same Lain palette as the rest of this
repo. Colors resolve through the palette's Semantic Role Map rather than being
picked by eye; the palette reference itself is symlinked in and not tracked
here.

Installed by chezmoi to `~/.config/opencode/themes/lain.json`. Selecting it is
the other repo's job: [agentsdots](https://github.com/identityapproved/agentsdots)
sets `"theme": "lain"` in `config/tui.json`, which it links to
`~/.config/opencode/tui.json`. That split is deliberate — colors live with the
rice, agent behaviour lives with the agent config.

`~/.config/opencode` therefore ends up a real directory holding links from both
repos. They never touch the same path.

## Where the shape came from

The 53-key set comes from [b0o/lavi](https://github.com/b0o/lavi)'s
`contrib/opencode` themes, the clearest worked example of an OpenCode theme.
None of lavi's colors are used — only the list of keys.

The file *form* is OpenCode's own: its built-in themes are `defs` plus scalar
values, which is what this uses. lavi writes `{"dark": …, "light": …}` objects
instead; both are valid, but the scalar form suits a dark-only palette and lets
the palette tokens be named directly.

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
- **No light variant, and no `dark`/`light` pairs at all.** OpenCode's own
  built-in themes use scalar values, so every key here is a single color.
  Lain is dark-only; a light variant would have been a lie.
- **Values are `defs` names, not raw hex.** The `defs` block is the palette's
  own token table — `foreprimary`, `highprimary`, `backquaternary` — so each
  role in `theme` reads as the decision it is, and a ramp change is one edit.
  The one rename is `accent` -> `accentpeak`, because `accent` is also a theme
  key and a self-referencing value is an assumption not worth making.
