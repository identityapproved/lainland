"""
Transparency plugin for Liferea.

Makes the whole window translucent, reading pane included. Two things have to
happen, and neither works the obvious way — details below, since both were
established by testing against Liferea 1.16.12 rather than from documentation.

1. The WebKit view.
   Liferea never calls webkit_web_view_set_background_color (the symbol is
   absent from its dynamic imports), and WebKitGTK's default base is opaque
   white. So the view needs an RGBA background set from outside — here.

2. The GTK chrome.
   The widgets stacked above the window paint over its alpha, so gtk.css turns
   them transparent. Note the window is renamed first: GtkBuilder ids are not
   GTK3 widget names, so the window arrives called "GtkApplicationWindow" and
   a `#mainwindow` selector silently matches nothing.

The CSS provider is installed with add_provider_for_screen, which is
process-local — it reaches Liferea only, so nothing has to be dropped into the
shared ~/.config/gtk-3.0/gtk.css.

The item view's own colours are not set here; Liferea loads those itself from
~/.config/liferea/liferea.css.
"""

import os
import sys

import gi

gi.require_version('Gtk', '3.0')
gi.require_version('WebKit2', '4.1')

from gi.repository import Gdk, GLib, GObject, Gtk, Liferea, WebKit2

CONFIG_DIR = os.path.join(GLib.get_user_config_dir(), 'liferea')
GTK_CSS = os.path.join(CONFIG_DIR, 'gtk.css')

# Selectors in gtk.css hang off this; see note 2 above.
WINDOW_NAME = 'liferea-transparent'

TRANSPARENT = Gdk.RGBA(0.0, 0.0, 0.0, 0.0)
# WebKitGTK's own default, restored on deactivate.
OPAQUE_WHITE = Gdk.RGBA(1.0, 1.0, 1.0, 1.0)

# Notebooks that build additional WebKit views after startup (browser tabs).
TAB_CONTAINERS = ('browsertabs', 'itemtabs')


def log(message):
    sys.stderr.write('transparency: %s\n' % message)
    sys.stderr.flush()


def webviews(widget):
    """Yield every WebKit view at or below widget."""
    if isinstance(widget, WebKit2.WebView):
        yield widget
    if isinstance(widget, Gtk.Container):
        for child in widget.get_children():
            yield from webviews(child)


class TransparencyPlugin(GObject.Object, Liferea.Activatable, Liferea.ShellActivatable):
    __gtype_name__ = 'TransparencyPlugin'

    object = GObject.property(type=GObject.Object)
    shell = GObject.property(type=Liferea.Shell)

    def __init__(self):
        GObject.Object.__init__(self)
        self.provider = None
        self.handlers = []
        self.patched = []

    def do_activate(self):
        window = Liferea.Shell.get_window()
        if window is None:
            log('no main window; giving up')
            return

        window.set_name(WINDOW_NAME)
        self._ensure_rgba_visual(window)
        self._load_gtk_css(window)
        self._patch(window)

        # Browser tabs build their view when the page is added, after the tree
        # has already been walked once.
        for name in TAB_CONTAINERS:
            notebook = Liferea.Shell.lookup(name)
            if notebook is not None:
                handler = notebook.connect('page-added', self._on_page_added)
                self.handlers.append((notebook, handler))

    def do_deactivate(self):
        for notebook, handler in self.handlers:
            notebook.disconnect(handler)
        self.handlers = []

        for view in self.patched:
            view.set_background_color(OPAQUE_WHITE)
        self.patched = []

        if self.provider is not None:
            Gtk.StyleContext.remove_provider_for_screen(
                Gdk.Screen.get_default(), self.provider)
            self.provider = None

        window = Liferea.Shell.get_window()
        if window is not None:
            window.set_name('GtkApplicationWindow')

    def _ensure_rgba_visual(self, window):
        """
        Needed on X11 only. The Wayland GDK backend has a single ARGB32 visual
        so the window can already carry alpha; X11's default visual is opaque
        and must be swapped before realize or the alpha is dropped.
        """
        if window.get_realized():
            return
        screen = window.get_screen()
        visual = screen.get_rgba_visual() if screen is not None else None
        if visual is not None:
            window.set_visual(visual)

    def _load_gtk_css(self, window):
        if not os.path.exists(GTK_CSS):
            log('no stylesheet at %s' % GTK_CSS)
            return
        provider = Gtk.CssProvider()
        try:
            provider.load_from_path(GTK_CSS)
        except GLib.Error as err:
            log('failed to parse %s: %s' % (GTK_CSS, err.message))
            return
        Gtk.StyleContext.add_provider_for_screen(
            window.get_screen(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)
        self.provider = provider

    def _patch(self, widget):
        for view in webviews(widget):
            if view in self.patched:
                continue
            view.set_background_color(TRANSPARENT)
            self.patched.append(view)

    def _on_page_added(self, notebook, child, page_num):
        # The view is not always built by the time the signal fires.
        GLib.idle_add(self._patch, child)
