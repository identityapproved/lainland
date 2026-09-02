#!/usr/bin/env bash
# Reconcile ./pkglist and ./services with the live system. Read-only with
# respect to the system: it only ever writes inside void/.
#
#   ./sync-from-system.sh            report drift, change nothing
#   ./sync-from-system.sh --write    append new packages, refresh ./services
#
# pkglist is hand-grouped, so unlike gentoo/sync-from-system.sh this one does
# not overwrite it. --write appends anything newly installed under an "unsorted"
# heading at the end, to be filed into the right section by hand. Removals are
# only ever reported: a package dropped from the host is often a mistake, and
# git should show it as a deliberate edit.
set -euo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
write=0
marker='# --- unsorted (appended by sync-from-system.sh) ------------------------'

case "${1-}" in
--write) write=1 ;;
'') ;;
*) sed -n '2,13p' "${BASH_SOURCE[0]}"; exit 64 ;;
esac

read_list() { sed -e 's/#.*//' -e 's/[[:space:]]\+$//' -e '/^$/d' "$1"; }

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# xbps-query -m prints name-version_revision; the version is the last '-' field.
xbps-query -m | sed 's/-[^-]*$//' | sort -u > "${tmp}/installed"
read_list "${here}/pkglist" | sort -u > "${tmp}/listed"
comm -23 "${tmp}/installed" "${tmp}/listed" > "${tmp}/new"
comm -13 "${tmp}/installed" "${tmp}/listed" > "${tmp}/gone"

if [ -s "${tmp}/new" ]; then
	printf 'installed but not in pkglist (%d):\n' "$(wc -l < "${tmp}/new")"
	sed 's/^/  /' "${tmp}/new"
else
	echo "pkglist covers every explicitly installed package"
fi

if [ -s "${tmp}/gone" ]; then
	printf 'in pkglist but not installed (%d) -- remove by hand if intended:\n' \
		"$(wc -l < "${tmp}/gone")"
	sed 's/^/  /' "${tmp}/gone"
fi

# /var/service, keeping the header comment block at the top of ./services.
command ls -1 /var/service | sort > "${tmp}/svc_system"
read_list "${here}/services" | sort -u > "${tmp}/svc_listed"
if ! diff -q "${tmp}/svc_system" "${tmp}/svc_listed" >/dev/null; then
	echo "services differ from /var/service:"
	# diff exits 1 on a difference, which is the expected case here, and
	# pipefail would take that as a script failure.
	diff -u "${tmp}/svc_listed" "${tmp}/svc_system" | sed -e '1,2d' -e 's/^/  /' || true
else
	echo "services matches /var/service"
fi

if [ "$write" -eq 0 ]; then
	echo "(report only; rerun with --write to apply)"
	exit 0
fi

if [ -s "${tmp}/new" ]; then
	if ! grep -qF "$marker" "${here}/pkglist"; then
		printf '\n%s\n' "$marker" >> "${here}/pkglist"
	fi
	cat "${tmp}/new" >> "${here}/pkglist"
	printf 'appended %d package(s) to pkglist\n' "$(wc -l < "${tmp}/new")"
fi

{
	sed -n '/^[^#]/q;p' "${here}/services"
	cat "${tmp}/svc_system"
} > "${tmp}/services.new"
mv "${tmp}/services.new" "${here}/services"
echo "refreshed services from /var/service"
