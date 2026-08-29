# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 go-module

DESCRIPTION="A plain text note-taking assistant"
HOMEPAGE="https://github.com/zk-org/zk"
EGIT_REPO_URI="https://github.com/zk-org/zk.git"

# GPL-3 covers zk itself. The vendored deps are linked statically and carry
# their own terms (mostly MIT/BSD/Apache-2.0); run dev-go/lichen on the built
# binary if you want an exact list here.
LICENSE="GPL-3"
SLOT="0"
IUSE="+fzf"

# Upstream does not vendor, so go-module_live_vendor has to reach the module
# proxy during src_unpack.
RESTRICT="network-sandbox"

RDEPEND="fzf? ( app-shells/fzf )"

src_unpack() {
	git-r3_src_unpack
	go-module_live_vendor
}

src_compile() {
	go-env_set_compile_environment

	# cgo builds the bundled SQLite amalgamation, and the fts5 tag is
	# mandatory: without it the binary dies with "no such module: fts5" on
	# the first "zk init". Gentoo's dev-db/sqlite USE flags are irrelevant.
	export CGO_ENABLED=1

	ego build -mod=vendor -tags fts5 \
		-ldflags "-X=main.Version=${PV}-${EGIT_VERSION:0:12}" \
		-o zk .
}

src_install() {
	dobin zk
	einstalldocs
}
