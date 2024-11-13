TERMUX_PKG_HOMEPAGE=https://github.com/CanonicalLtd/dqlite
TERMUX_PKG_DESCRIPTION="Distributed SQLite"
TERMUX_PKG_LICENSE="LGPL-3.0"
TERMUX_PKG_MAINTAINER="@TapetalArray"
TERMUX_PKG_VERSION=1.18.0
TERMUX_PKG_SRCURL=https://github.com/canonical/dqlite/archive/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=b0acae69ffef1b3762e8a1a4b02dc8cf52b3c786ae2a75fdce87e1e40a10a12d
TERMUX_PKG_DEPENDS="libuv, libsqlite"
TERMUX_PKG_NO_STATICSPLIT=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--enable-build-raft
"

termux_step_pre_configure() {
	autoreconf -fi
}
