Vendored from [Ascaniolamp/Hyprlain](https://github.com/Ascaniolamp/Hyprlain),
`src/gtkqtxdg/src/`. The GTK theme is a libadwaita recolor by
[uhm26](https://github.com/uhm26), who also recolored the Adwaita icons.

Both projects are GPL-3.0, same as this repo.

Changes made here:

- renamed `hyprlain` -> `lain` and `hyprlaicons` -> `lainicons`, in
  `index.theme` and every config that selects them
- `gtk-4.0/libadwaita-tweaks.css`: `--accent-bg-color` pointed at highprimary
  `#c1b48e` with black text, instead of upstream's leftover `--accent-blue`
- `lainicons/index.theme`: `Hidden=false`, so theme pickers can see it

Everything else is upstream, unmodified.

## Added here

- `scalable/actions/lain-eye.svg` — U+1F441 EYE, the walker search prompt. Not
  from upstream: outlined from Noto Emoji Bold with Pango/cairo and stored as
  flattened path data, so the icon needs no font at runtime and renders on a
  machine without that font installed. Regenerate by re-running the outline step
  if the glyph or size ever changes; there is no build system for it.

  It briefly used EGYPTIAN HIEROGLYPH D005 (U+1307A) instead. That glyph is fine
  strokes and put only 15% ink in an 18px box, so it read as a smudge; the eye
  is 38%. If more weight is ever wanted, Font Awesome 6 Free Solid carries the
  same codepoint as a filled eye at 59%.
