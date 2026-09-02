# void

Host configuration for the Void Linux laptop (voidbox, x86_64, runit + elogind,
sway). The counterpart to `gentoo/` — system-level state that lives outside
`$HOME` and is therefore not chezmoi-managed. Nothing here is applied by
`chezmoi apply`; the deps hook reports what is missing and prints the install
lines.

## What is here

- `pkglist` — the explicitly installed packages (`xbps-query -m`), names only,
  grouped by role with comments. Directly consumable: comments and blanks are
  stripped by both scripts below.
- `services` — the runit services linked into `/var/service`.
- `install.sh` — installs every missing package and links every missing service.
  Idempotent, so it converges a drifted host as well as seeding a new one.
- `sync-from-system.sh` — reconciles the two lists with the live system.
- `system/modules-load.d/usb-hotplug.conf` — driver preload, see below.
- `system/udev/71-usb-serial-uaccess.rules` — serial device ACLs, see below.
- `keymaps/us-swapescape.map` — console keymap with Caps swapped to Escape,
  matching `input type:keyboard { xkb_options caps:swapescape }` in the sway
  config. Install to `/usr/share/kbd/keymaps/` or set `KEYMAP=` in
  `/etc/rc.conf`.

## USB hotplug (Arduino / ESP / USB drives)

**`kernel.modules_disabled=1` is the thing that breaks USB hotplug here.**
`/etc/runit/2` sets it at the end of stage 2, which permanently locks kernel
module loading until the next boot. Devices still enumerate — `lsusb` shows
them — but their driver can never load, so no `/dev/ttyACM*`, `/dev/ttyUSB*`
or `/dev/sd*` node appears. That is why hardware only ever worked "after a
reboot": whatever loaded during boot worked, nothing plugged in later did.

The lock is one-way; it cannot be cleared at runtime. The fix keeps the
hardening and preloads the drivers *before* the lock, using the
`/etc/modules-load.d` hook `/etc/runit/2` already has.

`/etc/runit/2` also needs a one-word fix: its loader runs
`grep -v '^#' "$f" | xargs -r modprobe`, which passes every module after the
first as a *parameter* to the first one. Every stock conf holds a single module,
which is why nobody noticed.

```sh
doas install -Dm 644 void/system/modules-load.d/usb-hotplug.conf /etc/modules-load.d/usb-hotplug.conf
doas sed -i 's/xargs -r modprobe/xargs -rn1 modprobe/' /etc/runit/2
doas reboot
```

After the reboot, `lsmod | grep -E 'cdc_acm|usb_storage'` should list them, and
boards and drives appear on plug-in with no further action.

To drop the hardening instead, comment out line 23 of `/etc/runit/2`
(`sysctl -w kernel.modules_disabled=1`) and reboot; module autoloading then
behaves normally. Note `/etc/sysctl.d/99-hardened.conf` *looks* like it sets
this to 0, but that line has an inline `#` comment, which `sysctl.d` does not
support — it is not the thing setting the value.

## Serial device permissions

USB serial boards are `root:dialout 0660` on Void, and the shipped
`70-uaccess.rules` only covers ttyACM devices flagged as signal analyzers — so
a plain board is unreadable unless you are in `dialout`. Group changes only
apply to a *new login*, which is why boards appeared to work only after a
reboot.

`system/udev/71-usb-serial-uaccess.rules` fixes it with `TAG+="uaccess"`, so
elogind attaches an ACL for the active seat user at hotplug time — no group, no
re-login, no reboot. It covers USB ttys plus the raw-USB vendor IDs that
flashing tools need (CH340, CP210x, FTDI, Espressif, Arduino, SparkFun, Prolific).

This is the *second* half of the problem — it only matters once the driver can
actually load, so apply the module fix above as well.

```sh
# -D creates /etc/udev/rules.d, which Void does not ship until you add a rule.
# The 71- prefix matters: 73-seat-late.rules is what acts on TAG=="uaccess",
# and udev reads rules in lexical order, so a 99- rule tags too late.
doas install -Dm 644 void/system/udev/71-usb-serial-uaccess.rules /etc/udev/rules.d/71-usb-serial-uaccess.rules
doas udevadm control --reload-rules
doas udevadm trigger --subsystem-match=tty --subsystem-match=usb
```

## Services installed but deliberately not enabled

podman and libvirt/virt-manager are installed here so the shell functions that
call them resolve (`pstart`/`pstop`/`prm` and the `virsh` alias in
`home/dot_aliases`), but their daemons are **not** linked into `/var/service`.
This laptop is too weak to host containers or VMs; the real workloads run on the
Gentoo desktop or a VPS, and this machine is a client.

So: no `ln -s /etc/sv/libvirtd /var/service`, no `ln -s /etc/sv/virtlogd
/var/service`. podman is rootless and needs no service at all. If a session ever
does need libvirt locally, start it for that session only and take it down after:

```sh
doas ln -s /etc/sv/libvirtd /var/service   # persists across reboots -- avoid
doas sv up libvirtd                        # or just this, for one session
doas sv down libvirtd
```

The same reasoning applies to any other heavy daemon that arrives through the
Gentoo package convergence: install for the CLI, leave the service down.

## Installing

```sh
./void/install.sh -n     # show the plan, change nothing
./void/install.sh        # plan, confirm, then install and enable
./void/install.sh -y     # unattended
```

It asks for root through `doas`, falls back to `sudo`, and runs the commands
directly when already root. Packages already installed and services already
linked are skipped, so re-running it is cheap and safe.

Two things it does in a specific order, both of which matter on a fresh install:

- `void-repo-nonfree` is installed on its own and followed by an `xbps-install
  -S`, because `broadcom-wl-dkms` and `broadcom-bt-firmware` do not resolve
  until that repo's index is on disk. On a laptop whose only network card is
  the broadcom one, install these from a wired connection or a phone tether.
- A service whose package ships no `/etc/sv` entry is reported and skipped
  rather than symlinked, so `runsvdir` never gets a dangling directory to spin
  on.

Before the first run on a machine that still has `sudo`, keep it from coming
back with the rest of base-system:

```sh
doas install -Dm 644 /dev/stdin /etc/xbps.d/20-ignorepkg-sudo.conf <<< 'ignorepkg=sudo'
```

`install.sh` does not touch `system/` or `keymaps/` — the udev rule, the
modules-load.d conf and the console keymap are one-time, reboot-adjacent
changes and stay manual, under the sections above.

## Not from xbps

The rice also expects a handful of tools this list cannot install, because they
come from somewhere else. On a fresh machine they are the remaining gap:

- `rustup` (and through it cargo, rust-analyzer, clippy) — rustup.rs installer.
- `uv` / `uvx` in `~/.local/bin` — the Python toolchain, per the global agent
  rules.
- `claude` and `opencode` — their own installers, under `~/.local` and
  `~/.opencode`.
- neovim's Mason language servers, which `.zprofile` puts on `PATH` and
  symlinks `pyright-langserver` at.
- `ollama` and `proton-authenticator` in `/usr/local/bin` — vendor tarballs.
- Everything chezmoi clones itself (`.chezmoiexternal.toml`): TPM, the tmux
  theme, resurrect and continuum.

## Refreshing the lists

```sh
./void/sync-from-system.sh           # report drift only
./void/sync-from-system.sh --write   # append new packages, refresh services
```

`pkglist` is hand-grouped, so `--write` never rewrites it: newly installed
packages are appended under an `unsorted` heading at the end, to be filed into
the right section by hand. Packages listed but no longer installed are only
ever reported — removing one is a deliberate edit, and git should show it as
such. `services` has no such structure and is regenerated wholesale, header
comments kept.
