TERMUX_PKG_HOMEPAGE=https://github.com/canonical/lxd
TERMUX_PKG_DESCRIPTION="Daemon based on liblxc offering a REST API to manage containers"
TERMUX_PKG_LICENSE="AGPL-V3"
TERMUX_PKG_MAINTAINER="@TapetalArray"
TERMUX_PKG_VERSION=6.1
TERMUX_PKG_SRCURL=https://github.com/canonical/lxd/releases/download/lxd-6.1/lxd-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=ef073f19b5e666f306232d7c086ec1f39bbc14672237f2fd7b65d259caead1b9
TERMUX_PKG_DEPENDS="lxc, dqlite, squashfs-tools, eudev, rsync, libuv, libsqlite, libacl, libcap, dnsmasq"
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
	export GOFLAGS="-buildmode=pie -trimpath"
	export CGO_LDFLAGS_ALLOW="-Wl,-z,now"
}

termux_step_make() {
	cd $TERMUX_PKG_SRCDIR/lxd

	go build -v -tags "agent" -o bin/ ./lxd-agent/...

	go build -v -tags "netgo" -o bin/ ./lxd-migrate/...
	for tool in fuidshift lxc lxc-to-lxd lxd lxd-benchmark lxd-user; do
		go build -v -tags "libsqlite3" -o bin/ ./$tool/...
	done
}

termux_step_make_install() {
	cd "$TERMUX_PKG_SRCDIR/lxd"

	for tool in fuidshift lxc lxc-to-lxd lxd lxd-agent lxd-benchmark lxd-migrate lxd-user; do
		install -v -p -Dm755 "bin/$tool" "${TERMUX_PREFIX}/bin/$tool"
	done

	install -d "${TERMUX_PREFIX}/share/doc/lxd/"
	rm -rf doc/html
	cp -vr doc/* "${TERMUX_PREFIX}/share/doc/lxd/"
}
