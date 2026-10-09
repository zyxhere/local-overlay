# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN=${PN%-bin}
MY_P=${MY_PN}-${PV}

inherit systemd

DESCRIPTION="ssh-agent for TPMs"
HOMEPAGE="https://github.com/Foxboron/ssh-tpm-agent"
SRC_URI="
	amd64? ( https://github.com/Foxboron/${MY_PN}/releases/download/v${PV}/${MY_PN}-v${PV}-linux-amd64.tar.gz )
	arm?   ( https://github.com/Foxboron/${MY_PN}/releases/download/v${PV}/${MY_PN}-v${PV}-linux-arm.tar.gz   )
	arm64? ( https://github.com/Foxboron/${MY_PN}/releases/download/v${PV}/${MY_PN}-v${PV}-linux-arm64.tar.gz )
"

S="${WORKDIR}"/${MY_PN}

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~amd64"

RDEPEND="
	app-crypt/tpm2-tss
"

src_install() {
	for i in ssh-tpm-{add,agent,hostkeys,keygen}; do
		into /opt
		dobin ${i}
	done

	exeinto /etc/user/init.d
	newexe "${FILESDIR}"/${PN%-bin}.user ${PN%-bin}

	doinitd "${FILESDIR}"/${PN%-bin}
	newconfd "${FILESDIR}"/${PN%-bin}.confd ${PN%-bin}
	doinitd "${FILESDIR}"/${PN%-agent-bin}-genkeys

	# https://github.com/Foxboron/ssh-tpm-agent/tree/master/contrib/services
	systemd_newuserunit "${FILESDIR}"/${PN%-bin}-user.service ${PN%-bin}.service
	systemd_newuserunit "${FILESDIR}"/${PN%-bin}-user.socket ${PN%-bin}.socket

	systemd_dounit "${FILESDIR}"/${PN%-bin}.service
	systemd_dounit "${FILESDIR}"/${PN%-bin}.socket

	systemd_dounit "${FILESDIR}"/${PN%-agent-bin}-genkeys.service
}

pkg_postinst() {
	einfo "To use ${PN%-bin}, add yourself to the tss group e.g:"
	einfo " # usermod -aG tss larry"
	einfo "You might have to reboot for the new tpm udev rules to apply"
}
