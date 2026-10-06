# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd

DESCRIPTION="Modern, secure, all-in-on email server"
HOMEPAGE="https://www.xmox.nl/"

# there are bunch more arches available but you have to manually start
# the at https://beta.gobuilds.org/github.com/mjl-/mox@latest/linux-$ARCH-latest/
# not doing it myself since this package isn't keyworded
SRC_URI="
	amd64? ( https://beta.gobuilds.org/github.com/mjl-/mox@v0.0.17/linux-amd64-go1.27.1/0BcooIyz1Z91f8-dFhIsp6fMzqxY/mox-v0.0.17-go1.27.1.gz
		   -> ${PN}-amd64-${PV}.gz )
	arm?   ( https://beta.gobuilds.org/github.com/mjl-/mox@v0.0.17/linux-arm-go1.27.1/0InYsnI7ONfijs8Qn7_rgbKzyrr4/mox-v0.0.17-go1.27.1.gz
		   -> ${PN}-arm-${PV}.gz   )
	arm64? ( https://beta.gobuilds.org/github.com/mjl-/mox@v0.0.17/linux-arm64-go1.27.1/0ANmovaWTUEfqUE9-EpSMipF4nGo/mox-v0.0.17-go1.27.1.gz
		   -> ${PN}-arm64-${PV}.gz )
	x86?   ( https://beta.gobuilds.org/github.com/mjl-/mox@v0.0.17/linux-386-go1.27.1/0ZD9BC_IjUx_PfJ4IOLqIFYbiomw/mox-v0.0.17-go1.27.1.gz
		   -> ${PN}-x86-${PV}.gz   )
"

S="${WORKDIR}"

LICENSE="|| ( MIT MPL-2.0 )"
# bundled project licenses ( run `mox licenses` )
LICENSE+=" MIT BSD Apache-2.0 BSD-2"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64 ~x86"

RDEPEND="
	acct-user/mox
	acct-group/mox
	!!net-mail/mox
"

src_install() {
	newbin ${PN}-${ARCH}-${PV} ${PN%-bin}

	doinitd "${FILESDIR}"/${PN%-bin}
	systemd_dounit "${FILESDIR}"/${PN%-bin}.service
	newconfd "${FILESDIR}"/${PN%-bin}.confd ${PN%-bin}
}

pkg_postinst() {
	ewarn "Mox uses /var/lib/mox as the home directory"
	ewarn "Do not change it in mox.conf unless"
	ewarn "you know what you're doing"
}
