# fish colors — Lain. Palette: lain-colors.md (private repo).
#
# This file was the palette doc's one listed deviation: it carried a
# magenta/cyan/yellow scheme (ff00f6, 00fbfd, f9f972, 7f7094) unrelated to Lain.
# Now on the ramps: rose (Fore) for command chrome, ochre (High) for values and
# matches, greys for structure.
#
# `set -U` writes to the universal variable store (~/.config/fish/fish_variables),
# which shadows this file on later runs. fish_variables is tracked in this repo,
# so the two stay in step; if they ever disagree, the store wins and this file
# needs re-running with `source`.

if status is-interactive
    set -U fish_color_normal CE7688          # foreprimary
    set -U fish_color_command C1B48E         # highprimary
    set -U fish_color_keyword FFB1C3         # accent
    set -U fish_color_quote A49978           # hightertiary
    set -U fish_color_redirection BA6A7B     # foresecondary
    set -U fish_color_end 965363             # forequaternary
    set -U fish_color_error FFB1C3           # accent (error-bg is a fill, not text)
    set -U fish_color_param CE7688           # foreprimary
    set -U fish_color_comment 804654         # foresenary
    set -U fish_color_selection --background=C1B48E 000000  # black on ochre
    set -U fish_color_operator B5A985        # highsecondary
    set -U fish_color_escape FFDCB9          # success-fg
    set -U fish_color_autosuggestion 5A5A5A  # backsenary
    set -U fish_color_cwd C1B48E             # highprimary
    set -U fish_color_user CE7688            # foreprimary
    set -U fish_color_host CE7688            # foreprimary
    set -U fish_color_host_remote FFB1C3     # accent — remote reads as urgent
    set -U fish_color_cancel 804654          # foresenary
    set -U fish_color_search_match --background=C1B48E 000000
    set -U fish_pager_color_progress 804654
    set -U fish_pager_color_background --background=normal
    set -U fish_pager_color_prefix C1B48E --underline
    set -U fish_pager_color_completion CE7688
    set -U fish_pager_color_description 804654
    set -U fish_pager_color_selected_background --background=2A2A2A
    set -U fish_pager_color_selected_prefix FFB1C3 --bold --underline
    set -U fish_pager_color_selected_completion FFDCB9
    set -U fish_pager_color_selected_description A49978
    set -U fish_pager_color_secondary_background normal
    set -U fish_pager_color_secondary_prefix A49978 --underline
    set -U fish_pager_color_secondary_completion 965363
    set -U fish_pager_color_secondary_description 804654
end
