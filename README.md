# Termux Packages Modified

This repository contains the modified packages for Termux. The original packages are from the [Termux packages repository](https://github.com/termux/termux-packages)

## Document

+ [Docker](docs/docker.md)
+ [lxc](docs/lxc.md)
+ [lxd](docs/lxd.md)

## Supported Packages List

+ containerd
+ docker
+ docker-compose
+ dqlite
+ eudev
+ lxc
+ lxd
+ runc
+ squashfs-tools
  
## Build a package

```bash
# Clone the repository
git clone --depth=1 https://github.com/1orz/termux-packages-modify

# Clone the termux-packages official repository
git clone --depth=1 https://github.com/termux/termux-packages

# Copy the package to the termux-packages repository
cp -r termux-packages-modify/packages/<package> termux-packages/packages/
## Example
cp -r termux-packages-modify/packages/docker termux-packages/packages/

# Prepare environment for building
cd termux-packages
./scripts/setup-android-sdk.sh
# if your os is archlinux, you should use the following command
./scripts/setup-archlinux.sh

# Build the package
./build-package.sh -a aarch64 <package>
## Example
./build-package.sh -a aarch64 docker

```

## Install the package

You can find the built package in the `termux-packages/output` directory.

## Credits

+ [Termux](https://github.com/termux/termux-app)
+ [Termux Packages](https://github.com/termux/termux-packages)

## History Maintainer

+ [TapetalArray](https://t.me/TapetalArray)

## License

License: [GPLv3](https://www.gnu.org/licenses/gpl-3.0.html)