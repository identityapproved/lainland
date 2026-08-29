# gentoo

Host configuration for this Gentoo workstation (g33nto, amd64, profile
`default/linux/amd64/23.0/desktop`). Refresh it with `./sync-from-system.sh`,
which mirrors the live system into this directory and touches nothing outside
it.

## What is here

- `portage/` — mirror of `/etc/portage`: `make.conf`, `package.use/` (37 files),
  `package.accept_keywords/` (27), `package.mask/`, `package.env` plus
  `env/lowmem.conf` (webkit-gtk builds at `-j8`), `repos.conf/`,
  `binrepos.conf/`, `savedconfig/` (linux-firmware selection, ipxe) and the
  `postsync.d/50-eix-postsync` symlink into `app-portage/eix`.
- `localrepo/` — the `/var/db/repos/localrepo` overlay: `app-text/zk` and
  `media-sound/carla`, with `metadata/layout.conf` and `profiles/repo_name`.
  `Manifest` files are not tracked; they are regenerated on restore.
- `world` — `/var/lib/portage/world`, the 110 explicitly installed packages.
- `profile` — the selected profile, in `eselect profile` form.

## What is deliberately not here

- `/etc/portage/gnupg/` — the binhost verification keyring, including its
  passphrase file. Regenerated on the host with `getuto`.
- `make.profile` — a symlink into `/var/db/repos/gentoo`; set it with
  `eselect profile set default/linux/amd64/23.0/desktop` (see `profile`).
- `Manifest` files, `metadata/md5-cache/`, editor backups (`*~`).
- Anything under `/var/cache` (distfiles, binpkgs) and the synced ::gentoo /
  guru / brave / steam / xarblu trees, all of which come back from `emerge
  --sync`.

## Restoring onto a fresh install

```bash
doas rsync -rlpt gentoo/portage/ /etc/portage/
doas rsync -rlpt gentoo/localrepo/ /var/db/repos/localrepo/
doas install -m644 gentoo/world /var/lib/portage/world
doas eselect profile set "$(cat gentoo/profile)"
```

The overlays listed in `portage/repos.conf/eselect-repo.conf` need
`emerge --sync` (or `eselect repository enable`) before the keywords in
`package.accept_keywords/` resolve. Then regenerate the local overlay manifests,
since they are not tracked:

```bash
for e in /var/db/repos/localrepo/*/*/*.ebuild; do doas ebuild "$e" manifest; done
```

## Notes

- `app-text/zk` is a live ebuild (git HEAD, deps vendored at build time via
  `go-module_live_vendor`, hence `RESTRICT="network-sandbox"`). It has no
  keywords, so `package.accept_keywords/zk` pins `=app-text/zk-9999 **`.
  `emerge -a1 app-text/zk` re-pulls HEAD.
- The `fts5` build tag in that ebuild is not optional: without it `zk init`
  fails with `no such module: fts5`.
- `sync-from-system.sh` rsyncs with `--delete`, so files removed from the host
  disappear here as well. Review `git status` after running it.
