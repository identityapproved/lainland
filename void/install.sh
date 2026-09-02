#!/usr/bin/env bash
# Install everything this host runs: the packages in ./pkglist and the runit
# services in ./services. Idempotent -- already-installed packages and
# already-linked services are skipped, so it doubles as a converge script on a
# host that has drifted.
#
#   ./install.sh          show the plan, then ask before touching anything
#   ./install.sh -n       plan only, change nothing
#   ./install.sh -y       no prompt (unattended)
#   ./install.sh -p       packages only, leave /var/service alone
#   ./install.sh -s       services only
#
# Nothing here reaches the network except xbps-install, which is the point.
set -euo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
dry=0 yes=0 do_pkgs=1 do_svcs=1

while getopts 'nypsh' opt; do
	case $opt in
	n) dry=1 ;;
	y) yes=1 ;;
	p) do_svcs=0 ;;
	s) do_pkgs=0 ;;
	h) sed -n '2,13p' "${BASH_SOURCE[0]}"; exit 0 ;;
	*) exit 64 ;;
	esac
done

# Root helper. This host installs opendoas and ignores sudo, but a fresh
# install may have neither yet, in which case run the script as root.
if [ "$(id -u)" -eq 0 ]; then
	as_root=()
elif command -v doas >/dev/null 2>&1; then
	as_root=(doas)
elif command -v sudo >/dev/null 2>&1; then
	as_root=(sudo)
else
	echo "install.sh: need root: no doas, no sudo -- rerun as root" >&2
	exit 1
fi

# Strip comments and blanks. Both list files use the same format.
read_list() { sed -e 's/#.*//' -e 's/[[:space:]]\+$//' -e '/^$/d' "$1"; }

run() {
	printf '  %s\n' "$*"
	[ "$dry" -eq 1 ] && return 0
	"$@"
}

confirm() {
	if [ "$yes" -eq 1 ] || [ "$dry" -eq 1 ]; then
		return 0
	fi
	printf 'proceed? [y/N] '
	read -r reply
	case $reply in y | Y | yes) return 0 ;; *) echo "aborted"; exit 1 ;; esac
}

# --- packages -----------------------------------------------------------
missing=()
if [ "$do_pkgs" -eq 1 ]; then
	while read -r pkg; do
		xbps-query -p pkgver "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
	done < <(read_list "${here}/pkglist")
fi

# --- services -----------------------------------------------------------
unlinked=()
if [ "$do_svcs" -eq 1 ]; then
	while read -r svc; do
		[ -e "/var/service/${svc}" ] || unlinked+=("$svc")
	done < <(read_list "${here}/services")
fi

if [ ${#missing[@]} -eq 0 ] && [ ${#unlinked[@]} -eq 0 ]; then
	echo "nothing to do: every package is installed and every service is linked"
	exit 0
fi

if [ ${#missing[@]} -gt 0 ]; then
	printf 'packages to install (%d):\n  %s\n' "${#missing[@]}" "${missing[*]}"
fi
if [ ${#unlinked[@]} -gt 0 ]; then
	printf 'services to enable (%d):\n  %s\n' "${#unlinked[@]}" "${unlinked[*]}"
fi
confirm

# void-repo-nonfree first, on its own, with a sync after it: broadcom-wl-dkms
# and broadcom-bt-firmware live in that repo and do not resolve until its
# plist is on disk.
for i in "${!missing[@]}"; do
	if [ "${missing[$i]}" = "void-repo-nonfree" ]; then
		echo "installing the nonfree repo first:"
		run "${as_root[@]}" xbps-install -Sy void-repo-nonfree
		run "${as_root[@]}" xbps-install -S
		unset 'missing[i]'
		missing=("${missing[@]}")
		break
	fi
done

if [ ${#missing[@]} -gt 0 ]; then
	echo "installing packages:"
	run "${as_root[@]}" xbps-install -Sy "${missing[@]}"
fi

# Services. A name with no /etc/sv entry means its package did not ship one --
# report it rather than creating a dangling symlink runsvdir would spin on.
if [ ${#unlinked[@]} -gt 0 ]; then
	echo "enabling services:"
	for svc in "${unlinked[@]}"; do
		if [ ! -d "/etc/sv/${svc}" ]; then
			echo "  skipped ${svc}: no /etc/sv/${svc}" >&2
			continue
		fi
		run "${as_root[@]}" ln -sfn "/etc/sv/${svc}" "/var/service/${svc}"
	done
fi

if [ "$dry" -eq 1 ]; then
	echo "(dry run: nothing was changed)"
fi
exit 0
