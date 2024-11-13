TERMUX_PKG_HOMEPAGE=https://github.com/opencontainers/runc
TERMUX_PKG_DESCRIPTION="CLI tool for spawning and running containers according to the OCI specification"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@TapetalArray"
TERMUX_PKG_VERSION=1.2.1
TERMUX_PKG_SRCURL=https://github.com/opencontainers/runc/releases/download/v$TERMUX_PKG_VERSION/runc.tar.xz
TERMUX_PKG_SHA256=bb03d108841f265392b0527a1768d53e6ece325389015e6f2567349bdaa5c5ff
TERMUX_PKG_BUILD_DEPENDS="libseccomp-static"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_NO_STATICSPLIT=true

termux_step_get_source() {
	local PKG_SRCURL=(${TERMUX_PKG_SRCURL[@]})
	local PKG_SHA256=(${TERMUX_PKG_SHA256[@]})

	if [ ${#PKG_SRCURL[@]} != ${#PKG_SHA256[@]} ]; then
		termux_error_exit "Error: length of TERMUX_PKG_SRCURL isn't equal to length of TERMUX_PKG_SHA256."
	fi

	# download and extract packages into its own folder inside $TERMUX_PKG_SRCDIR
	mkdir -p "$TERMUX_PKG_CACHEDIR"
	mkdir -p "$TERMUX_PKG_SRCDIR"
	for i in $(seq 0 $((${#PKG_SRCURL[@]} - 1))); do
		# Archives from moby/moby and docker/cli have same name, so cache them as {moby,cli}-v...
		local file="${TERMUX_PKG_CACHEDIR}/$(echo ${PKG_SRCURL[$i]} | cut -d"/" -f 5)-$(basename ${PKG_SRCURL[$i]})"
		termux_download "${PKG_SRCURL[$i]}" "$file" "${PKG_SHA256[$i]}"
		tar xf "$file" -C "$TERMUX_PKG_SRCDIR"
	done

	# delete trailing -$TERMUX_PKG_VERSION from folder name
	# so patches become portable across different versions
	cd "$TERMUX_PKG_SRCDIR"
	for folder in $(ls); do
		if [ ! $folder == ${folder%%-*} ]; then
			mv $folder ${folder%%-*}
		fi
	done
}

termux_step_configure() {
	cd $TERMUX_PKG_SRCDIR
	mkdir -p src/github.com/opencontainers
	cp -r runc src/github.com/opencontainers/runc

	export GOPATH="$TERMUX_PKG_SRCDIR"
}

termux_step_make() {
	${CC} -c -o stubs.o "$TERMUX_PKG_BUILDER_DIR/stubs.c"
	${AR} rcs liblog.a stubs.o

	export CGO_LDFLAGS="-L$TERMUX_PKG_BUILDDIR"

	cd src/github.com/opencontainers/runc
	make static
	make man
}

termux_step_make_install() {
	cd src/github.com/opencontainers/runc

	install -Dm755 runc "$TERMUX_PREFIX/bin/runc"
	install -Dm644 contrib/completions/bash/runc \
		"$TERMUX_PREFIX/share/bash-completion/completions/runc"

	install -d "$TERMUX_PREFIX/share/man/man8"
	install -m644 man/man8/*.8 "$TERMUX_PREFIX/share/man/man8"
}
