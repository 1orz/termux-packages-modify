TERMUX_PKG_HOMEPAGE=https://github.com/docker/compose
TERMUX_PKG_DESCRIPTION="Define and run multi-container applications with Docker"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@TapetalArray"
TERMUX_PKG_VERSION=2.30.3
TERMUX_PKG_SRCURL=https://github.com/docker/compose/archive/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=b9b6f45ccad892a3f9353a03b6bdf3f79ea15ee2076f98bf013ef1db40034378
TERMUX_PKG_DEPENDS="docker"
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
	cd "compose"
	export CGO_CPPFLAGS="${CPPFLAGS}"
	export CGO_CFLAGS="${CFLAGS}"
	export CGO_CXXFLAGS="${CXXFLAGS}"
	export CGO_LDFLAGS="${LDFLAGS}"
	export GOPATH="$TERMUX_PKG_SRCDIR/compose"
	export GOFLAGS="-buildmode=pie -trimpath -mod=readonly -modcacherw"
}

termux_step_make() {
	cd "compose"
	GO_LDFLAGS="-linkmode=external -compressdwarf=false -X=github.com/docker/compose/v2/internal.Version=${TERMUX_PKG_VERSION}"
	go build -ldflags "${GO_LDFLAGS}" -trimpath -tags "e2e,kube" -o compose ./cmd
}

termux_step_make_install() {
	cd "compose"
	install -Dm644 LICENSE "$TERMUX_PREFIX"/share/licenses/docker-compose/LICENSE
	install -Dm755 compose "$TERMUX_PREFIX"/lib/docker/cli-plugins/docker-compose
	install -d "$TERMUX_PREFIX/bin"
	ln -sf $TERMUX_PREFIX/lib/docker/cli-plugins/docker-compose "$TERMUX_PREFIX/bin/docker-compose"
}
