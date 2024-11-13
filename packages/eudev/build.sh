TERMUX_PKG_HOMEPAGE=https://github.com/eudev-project/eudev
TERMUX_PKG_DESCRIPTION="standalone dynamic and persistent device naming support (aka userspace devfs) daemon that runs independently from the init system"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@TapetalArray"
TERMUX_PKG_VERSION=3.2.14
TERMUX_PKG_SRCURL=https://github.com/eudev-project/eudev/releases/download/v3.2.14/eudev-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=8da4319102f24abbf7fff5ce9c416af848df163b29590e666d334cc1927f006f
TERMUX_PKG_NO_STATICSPLIT=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--with-rootrundir=$TERMUX_PREFIX/var/run
"
