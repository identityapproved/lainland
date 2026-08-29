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
