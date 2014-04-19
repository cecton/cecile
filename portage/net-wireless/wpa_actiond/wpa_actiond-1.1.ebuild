# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

DESCRIPTION="emon that connects to wpa_supplicant and handles connect and
disconnect events"
HOMEPAGE="http://projects.archlinux.org/wpa_actiond.git/"
SRC_URI="http://projects.archlinux.org/${PN}.git/snapshot/${PN}-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="net-wireless/wpa_supplicant"
RDEPEND="${DEPEND}"

src_install() {
	dobin wpa_actiond || die
}
