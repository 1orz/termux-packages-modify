TERMUX_PKG_HOMEPAGE=https://github.com/containerd/containerd
TERMUX_PKG_DESCRIPTION="An open and reliable container runtime"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@TepatalArray"
TERMUX_PKG_VERSION=2.0.0
TERMUX_PKG_REVISION=3
TERMUX_PKG_SRCURL=git+https://github.com/containerd/containerd
TERMUX_PKG_DEPENDS="runc"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_NO_STATICSPLIT=true

termux_step_make() {
	export BUILDTAGS=no_btrfs
	export SHIM_CGO_ENABLED=1
	make VERSION=v$TERMUX_PKG_VERSION -j${TERMUX_PKG_MAKE_PROCESSES}
	unset GOOS GOARCH CGO_LDFLAGS CFLAGS CXXFLAGS LDFLAGS
	export CC=/usr/bin/clang CXX=/usr/bin/clang++
	make VERSION=v$TERMUX_PKG_VERSION man
}

termux_step_make_install() {
	DESTDIR= make install
	DESTDIR= make install-man
}
