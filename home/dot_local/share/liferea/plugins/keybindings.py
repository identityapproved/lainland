"""
Keybindings plugin for Liferea.

Liferea ships an accelerator for "Open in external browser" (Ctrl+D) but none
for the two internal-browser actions, even though both exist as app actions:

    app.launch-selected-item-in-browser   "Open In Browser", loads the page
                                          into the existing right-hand pane
    app.launch-selected-item-in-tab       "Open In Tab", spawns a new tab

It also repairs Ctrl+D, which Liferea binds to a misspelled action name that
does not exist, leaving the documented "Open in external browser" shortcut
inert.

GtkApplication accelerators are registered in code via set_accels_for_action,
and Liferea exposes no setting for them, so binding these from outside the
source means doing it from a plugin.

Chosen accels avoid everything in Liferea's own shortcut list (u, d, f, b,
Ctrl+R/U/N/M/T/D/F, Ctrl+plus/minus/0).

It also focuses newly opened tabs. Liferea adds a tab without switching to it
and offers no setting to change that, so opening an item in a tab otherwise
leaves you looking at the previous one.
"""

import sys

import gi

gi.require_version('Gtk', '3.0')

from gi.repository import GLib, GObject, Gtk, Liferea

ACCELS = {
    # "Open In Browser" — loads into the existing right-hand pane.
    'app.launch-selected-item-in-browser': ['<Control>Return'],
    # "Open In Tab" — spawns a new internal tab.
    'app.launch-selected-item-in-tab': ['<Control><Shift>Return'],
    # Repairs Ctrl+D. See BROKEN_ACCEL below.
    'app.launch-selected-item-in-external-browser': ['<Control>d'],
}

# Liferea 1.16.12 registers <Control>d against "launch-item-in-external-browser",
# but no such action exists — the real one is "launch-SELECTED-item-in-...", as
# used by the menu. The accel therefore resolves to nothing and Ctrl+D is dead.
# Confirmed by dumping list_action_descriptions() from a running instance.
# Clear the dead entry so it cannot shadow the correct binding above.
BROKEN_ACCEL = 'app.launch-item-in-external-browser'



def log(message):
    sys.stderr.write('keybindings: %s\n' % message)
    sys.stderr.flush()


class KeybindingsPlugin(GObject.Object, Liferea.Activatable, Liferea.ShellActivatable):
    __gtype_name__ = 'KeybindingsPlugin'

    object = GObject.property(type=GObject.Object)
    shell = GObject.property(type=Liferea.Shell)

    def __init__(self):
        GObject.Object.__init__(self)
        self.previous = {}
        self.handler = None
        self.notebook = None

    def do_activate(self):
        app = Gtk.Application.get_default()
        if app is None:
            log('no GtkApplication; cannot bind accelerators')
            return
        for action, accels in ACCELS.items():
            # Remember what was there so deactivate can put it back rather
            # than blanking an accelerator Liferea itself had set.
            self.previous[action] = app.get_accels_for_action(action)
            app.set_accels_for_action(action, accels)

        self.previous[BROKEN_ACCEL] = app.get_accels_for_action(BROKEN_ACCEL)
        app.set_accels_for_action(BROKEN_ACCEL, [])

        self.notebook = Liferea.Shell.lookup('browsertabs')
        if self.notebook is not None:
            self.handler = self.notebook.connect('page-added', self._on_page_added)

    def do_deactivate(self):
        if self.notebook is not None and self.handler is not None:
            self.notebook.disconnect(self.handler)
        self.notebook = None
        self.handler = None

        app = Gtk.Application.get_default()
        if app is None:
            return
        for action, accels in self.previous.items():
            app.set_accels_for_action(action, accels)
        self.previous = {}

    def _on_page_added(self, notebook, child, page_num):
        # Deferred: the page is not fully added when the signal fires, so
        # switching immediately can land on the wrong index.
        GLib.idle_add(self._focus, notebook, page_num)

    def _focus(self, notebook, page_num):
        notebook.set_current_page(page_num)
        return False
