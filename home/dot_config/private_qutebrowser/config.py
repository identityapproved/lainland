# qutebrowser config. Colors resolve through the role map in lain-colors.md:
# rose on black for chrome, ochre on black for content, black on ochre for
# selection, never rose on ochre.
#
# The repo is the source of truth: :set changes last for the session only.
# A site that renders badly under forced dark mode gets an exception here, e.g.
#   config.set("colors.webpage.darkmode.enabled", False, "*://example.com/*")
# pyright: basic
# pyright: reportUndefinedVariable=false

config.load_autoconfig(False)

# ------------------------------------------------------------- palette ----
backprimary = "#000000"
backsecondary = "#1A1A1A"
backtertiary = "#2A2A2A"
backquaternary = "#3A3A3A"

foreprimary = "#CE7688"
foretertiary = "#A05969"
foresenary = "#804654"
foreundenary = "#2A171B"

highprimary = "#C1B48E"
highsecondary = "#B5A985"
hightertiary = "#A49978"
highquaternary = "#968C6E"
highoctonary = "#5A5341"
highdecenary = "#403C2E"

accent = "#FFB1C3"
success_fg = "#FFDCB9"
success_bg = "#60401D"
error_bg = "#930006"

# --------------------------------------------------------------- fonts ----
c.fonts.default_family = "IosevkaTerm Nerd Font Mono"
c.fonts.default_size = "11pt"

# ---------------------------------------------------------- statusbar ----
c.colors.statusbar.normal.fg = foreprimary
c.colors.statusbar.normal.bg = backsecondary
c.colors.statusbar.insert.fg = backprimary
c.colors.statusbar.insert.bg = foreprimary
c.colors.statusbar.passthrough.fg = backprimary
c.colors.statusbar.passthrough.bg = hightertiary
c.colors.statusbar.caret.fg = backprimary
c.colors.statusbar.caret.bg = highsecondary
c.colors.statusbar.caret.selection.fg = backprimary
c.colors.statusbar.caret.selection.bg = highprimary
c.colors.statusbar.command.fg = foreprimary
c.colors.statusbar.command.bg = backprimary
c.colors.statusbar.private.fg = accent
c.colors.statusbar.private.bg = foreundenary
c.colors.statusbar.command.private.fg = accent
c.colors.statusbar.command.private.bg = foreundenary
c.colors.statusbar.progress.bg = foreprimary
c.colors.statusbar.url.fg = highprimary
c.colors.statusbar.url.success.https.fg = highprimary
c.colors.statusbar.url.success.http.fg = foretertiary
c.colors.statusbar.url.warn.fg = foreprimary
c.colors.statusbar.url.error.fg = accent
c.colors.statusbar.url.hover.fg = accent

# --------------------------------------------------------------- tabs ----
c.colors.tabs.bar.bg = backprimary
c.colors.tabs.odd.fg = foretertiary
c.colors.tabs.odd.bg = backsecondary
c.colors.tabs.even.fg = foretertiary
c.colors.tabs.even.bg = backsecondary
c.colors.tabs.selected.odd.fg = backprimary
c.colors.tabs.selected.odd.bg = foreprimary
c.colors.tabs.selected.even.fg = backprimary
c.colors.tabs.selected.even.bg = foreprimary
c.colors.tabs.pinned.odd.fg = highprimary
c.colors.tabs.pinned.odd.bg = backtertiary
c.colors.tabs.pinned.even.fg = highprimary
c.colors.tabs.pinned.even.bg = backtertiary
c.colors.tabs.pinned.selected.odd.fg = backprimary
c.colors.tabs.pinned.selected.odd.bg = highprimary
c.colors.tabs.pinned.selected.even.fg = backprimary
c.colors.tabs.pinned.selected.even.bg = highprimary
c.colors.tabs.indicator.start = foretertiary
c.colors.tabs.indicator.stop = highprimary
c.colors.tabs.indicator.error = error_bg

# --------------------------------------------------------- completion ----
c.colors.completion.fg = highprimary
c.colors.completion.odd.bg = backprimary
c.colors.completion.even.bg = backprimary
c.colors.completion.category.fg = foreprimary
c.colors.completion.category.bg = backsecondary
c.colors.completion.category.border.top = backquaternary
c.colors.completion.category.border.bottom = backquaternary
c.colors.completion.item.selected.fg = backprimary
c.colors.completion.item.selected.bg = highprimary
c.colors.completion.item.selected.border.top = highprimary
c.colors.completion.item.selected.border.bottom = highprimary
c.colors.completion.item.selected.match.fg = highdecenary
c.colors.completion.match.fg = foreprimary
c.colors.completion.scrollbar.fg = backquaternary
c.colors.completion.scrollbar.bg = backprimary

# -------------------------------------------------------------- hints ----
c.colors.hints.fg = backprimary
c.colors.hints.bg = highprimary
c.colors.hints.match.fg = highoctonary
c.hints.border = "1px solid " + backprimary
c.colors.keyhint.fg = highprimary
c.colors.keyhint.suffix.fg = accent
c.colors.keyhint.bg = backsecondary

# --------------------------------------------- messages and prompts ----
c.colors.messages.error.fg = accent
c.colors.messages.error.bg = error_bg
c.colors.messages.error.border = error_bg
c.colors.messages.warning.fg = success_bg
c.colors.messages.warning.bg = success_fg
c.colors.messages.warning.border = success_fg
c.colors.messages.info.fg = highprimary
c.colors.messages.info.bg = backsecondary
c.colors.messages.info.border = backquaternary
c.colors.prompts.fg = highprimary
c.colors.prompts.bg = backsecondary
c.colors.prompts.border = "1px solid " + backquaternary
c.colors.prompts.selected.fg = backprimary
c.colors.prompts.selected.bg = highprimary
c.colors.contextmenu.menu.fg = highprimary
c.colors.contextmenu.menu.bg = backsecondary
c.colors.contextmenu.selected.fg = backprimary
c.colors.contextmenu.selected.bg = highprimary
c.colors.contextmenu.disabled.fg = foresenary
c.colors.contextmenu.disabled.bg = backsecondary
c.colors.tooltip.fg = highprimary
c.colors.tooltip.bg = backsecondary

# ---------------------------------------------------------- downloads ----
c.colors.downloads.bar.bg = backprimary
c.colors.downloads.start.fg = highprimary
c.colors.downloads.start.bg = foresenary
c.colors.downloads.stop.fg = backprimary
c.colors.downloads.stop.bg = highquaternary
c.colors.downloads.error.fg = accent
c.colors.downloads.error.bg = error_bg
c.colors.downloads.system.fg = "none"
c.colors.downloads.system.bg = "none"

# ------------------------------------------------------------ webpage ----
c.colors.webpage.bg = backprimary
c.colors.webpage.preferred_color_scheme = "dark"
c.colors.webpage.darkmode.enabled = True
c.colors.webpage.darkmode.policy.images = "never"

# ----------------------------------------------------------- blocking ----
# "both" needs the python adblock module; without it qutebrowser silently
# falls back to hosts-only. Lists refresh with :adblock-update.
c.content.blocking.method = "both"
c.content.blocking.adblock.lists = [
    "https://easylist.to/easylist/easylist.txt",
    "https://easylist.to/easylist/easyprivacy.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/privacy.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/badware.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/quick-fixes.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/annoyances-cookies.txt",
]

# ---------------------------------------------------------- hardening ----
# Balanced: sites keep working and logins persist. There is no HTTPS-only
# mode in qutebrowser, so that one is not here.
c.content.cookies.accept = "no-3rdparty"
c.content.cookies.store = True
c.content.webrtc_ip_handling_policy = "default-public-interface-only"
c.content.dns_prefetch = False
c.content.autoplay = False

# Deny outright instead of prompting.
c.content.geolocation = False
c.content.notifications.enabled = False
c.content.media.audio_capture = False
c.content.media.video_capture = False
c.content.media.audio_video_capture = False
c.content.desktop_capture = False
c.content.mouse_lock = False
c.content.persistent_storage = False
c.content.register_protocol_handler = False

# ------------------------------------------------------------ binding ----
c.url.searchengines = {
    "DEFAULT": "https://duckduckgo.com/?q={}",
    "r": "https://old.reddit.com/search?q={}",
}

# Reddit and YouTube video through mpv, which hands the URL to yt-dlp.
config.bind(",m", "spawn mpv {url}")
config.bind(",M", "hint links spawn mpv {hint-url}")
