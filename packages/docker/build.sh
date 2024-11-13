TERMUX_PKG_HOMEPAGE=https://www.docker.com/
TERMUX_PKG_DESCRIPTION="Pack, ship and run any application as a lightweight container"
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@TapetalArray"
TERMUX_PKG_VERSION=27.3.1
TINI_VERSION=0.19.0
TERMUX_PKG_SRCURL=(
	"https://github.com/moby/moby/archive/v${TERMUX_PKG_VERSION}.tar.gz"
	"https://github.com/docker/cli/archive/v${TERMUX_PKG_VERSION}.tar.gz"
	"https://github.com/krallin/tini/archive/v${TINI_VERSION}.tar.gz"
)
TERMUX_PKG_SHA256=(
	"d18208d9e0b6421307342cdef266193984c97c87177b9262b1113e6e9e7e020e"
	"df7d44387166d90954e290dfbe0a278649bf71d0e89933615bdc0757580b68e4"
	"0fd35a7030052acd9f58948d1d900fe1e432ee37103c5561554408bdac6bbf0d"
)
TERMUX_PKG_DEPENDS="containerd, runc, iproute2, libsqlite, libtool"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_NO_STATICSPLIT=true
DOCKER_GITCOMMIT=41ca978a0a

_fake_gopath_pushd() {
	mkdir -p "$GOPATH/src/${2%/*}"
	rm -f "$GOPATH/src/$2"
	ln -rsT "$1" "$GOPATH/src/$2"
	pushd "$GOPATH/src/$2" >/dev/null
}

_fake_gopath_popd() {
	popd >/dev/null
}

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
	export GOPATH="$TERMUX_PKG_SRCDIR"
	export DISABLE_WARN_OUTSIDE_CONTAINER=1
	export GO111MODULE=auto
}

termux_step_make() {
	### daemon
	echo "Building daemon"
	_fake_gopath_pushd moby github.com/docker/docker
	export DOCKER_GITCOMMIT
	export DOCKER_BUILDTAGS='exclude_graphdriver_btrfs exclude_graphdriver_devicemapper exclude_graphdriver_quota selinux exclude_graphdriver_aufs'
	export VERSION=$TERMUX_PKG_VERSION
	AUTO_GOPATH=1 PREFIX='' hack/make.sh dynbinary
	_fake_gopath_popd
	echo "Done"

	### docker-init
	echo 'Building docker-init'
	_fake_gopath_pushd tini github.com/krallin/tini
	cmake .
	make
	_fake_gopath_popd
	echo "Done"

	### cli
	echo "Building cli"
	_fake_gopath_pushd cli github.com/docker/cli
	make VERSION=$TERMUX_PKG_VERSION dynbinary
	export CC=/usr/bin/clang CXX=/usr/bin/clang++
	unset GOOS GOARCH CGO_LDFLAGS CFLAGS CXXFLAGS LDFLAGS
	make manpages
	_fake_gopath_popd
	echo "Done"
}

termux_step_make_install() {
	### init
	install -Dm755 tini/tini "$TERMUX_PREFIX/bin/docker-init"
	### dockerd
	install -Dm755 moby/bundles/dynbinary-daemon/dockerd "$TERMUX_PREFIX"/bin/dockerd
	install -Dm755 moby/bundles/dynbinary-daemon/docker-proxy "$TERMUX_PREFIX/bin/docker-proxy"
	### cli
	cd "$TERMUX_PKG_SRCDIR"/cli
	# binary
	install -Dm755 build/docker "$TERMUX_PREFIX/bin/docker"
	# man
	install -dm755 "$TERMUX_PREFIX/share/man"
	cp -r man/man* "$TERMUX_PREFIX/share/man"
	# fake os-release
	install $TERMUX_PKG_BUILDER_DIR/fake-os-release "$TERMUX_PREFIX/lib/os-release"
	ln -s $TERMUX_PREFIX/lib/os-release $TERMUX_PREFIX/etc/os-release
}
