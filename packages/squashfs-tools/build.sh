TERMUX_PKG_HOMEPAGE=https://github.com/plougher/squashfs-tools
TERMUX_PKG_DESCRIPTION="Tools for squashfs, a highly compressed read-only filesystem for Linux"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="@TapetalArray"
TERMUX_PKG_VERSION=4.6.1
TERMUX_PKG_SRCURL=https://github.com/plougher/squashfs-tools/archive/$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=94201754b36121a9f022a190c75f718441df15402df32c2b520ca331a107511c
TERMUX_PKG_NO_STATICSPLIT=true
TERMUX_PKG_DEPENDS="zlib, liblzma, liblzo, liblz4, zstd"

termux_step_make() {
	local make_options=(
		GZIP_SUPPORT=1
		LZ4_SUPPORT=1
		LZMA_XZ_SUPPORT=1
		LZO_SUPPORT=1
		XATTR_SUPPORT=1
		XZ_SUPPORT=1
		ZSTD_SUPPORT=1
		-C $TERMUX_PKG_SRCDIR/squashfs-tools
	)

	make "${make_options[@]}"
}

termux_step_make_install() {
	local make_options=(
		INSTALL_PREFIX="$TERMUX_PREFIX"
		INSTALL_MANPAGES_DIR='$(INSTALL_PREFIX)/share/man/man1'
		install
		-C $TERMUX_PKG_SRCDIR/squashfs-tools
	)

	make "${make_options[@]}"
	install -vDm 644 $TERMUX_PKG_SRCDIR/{ACTIONS-README,CHANGES,"README-$TERMUX_PKG_VERSION",USAGE*} -t "$TERMUX_PREFIX/usr/share/doc/squashfs-tools"
}
