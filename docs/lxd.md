# Termux LXD Stable

LXD Termux Port

## Prerequisites

Custom Kernel with Docker's necessary options enabled, for GKI kernel reference [gki-custom](https://github.com/TapetalArray/gki-custom)

## Notice

All data and runtime paths are changed to /data/local/tmp/lxd, Because the termux prefix path length exceeds the unix socket limit

Status:

|            |        |
|:----------:|:------:|
| lxd        | 6.1    |
| dqlite     | 1.18.0 |

## Install

Download Packages

* [lxd](https://github.com/TapetalArray/termux-lxd-stable/releases/)
* [dqlite](https://github.com/TapetalArray/termux-lxd-stable/releases/)
* [lxc-lts](https://github.com/TapetalArray/termux-lxc-lts/releases)
* [eudev](https://github.com/TapetalArray/termux-eudev/releases)
* [squashfs-tools](https://github.com/TapetalArray/termux-squashfs-tools/releases)

```bash
pkg upg
pkg i tsu
pkg i ./*.deb
```

## Usage

### Mount Cgroup

```bash
for cg in blkio cpu cpuacct cpuset devices freezer memory; do
   if [ ! -d "/sys/fs/cgroup/${cg}" ]; then
       sudo mkdir -p "/sys/fs/cgroup/${cg}"
   fi

   if ! sudo mountpoint -q "/sys/fs/cgroup/${cg}"; then
       sudo mount -t cgroup -o "${cg}" cgroup "/sys/fs/cgroup/${cg}" || true
   fi
done
```

#### Start Daemon

Termux not use any init system, just manual start daemon

```bash
sudo mkdir -p /data/local/tmp/lxd/{lib,cache,log}/lxd
# Put this in your .bashrc or .profile
alias lxdstart="sudo lxd &>/dev/null &"
alias lxdstop="sudo pkill lxd"
```

#### Launch Ubuntu

```bash
sudo lxd init
# Privileged Containers
sudo lxc launch ubuntu:24.04 ubuntu -c security.privileged=true
sudo lxc console ubuntu
```

#### Network Bridge

Edit iptable, change 192.168.1.1 according to your gateway IP

```bash
sudo ip route add default via 192.168.1.1 dev wlan0
sudo ip rule add from all lookup main pref 30000
```

#### Proxy

```bash
# Proxy
port="2080"
host="127.0.0.1"
proxy="http://${host}:${port}"

export all_proxy=${proxy}
export ALL_PROXY=${proxy}
export http_proxy=${proxy}
export HTTP_PROXY=${proxy}
export https_proxy=${proxy}
export HTTPS_PROXY=${proxy}
export ftp_proxy=${proxy}
export FTP_PROXY=${proxy}
export no_proxy=localhost,127.0.0.0/8,*.local
export NO_PROXY=localhost,127.0.0.0/8,*.local
```

#### Web UI

Check this [comment](https://github.com/canonical/lxd-ui/issues/417#issuecomment-1636736820)

```bash
pkg i yarn -y
git clone https://github.com/canonical/lxd-ui
cd lxd-ui
yarn & yarn build
pkg uni yarn -y
sudo cp -r build/ui /data/local/tmp/lxd
# Put this in your .bashrc or .profile
alias lxdenv="sudo LXD_UI=/data/local/tmp/lxd/ui"
# Change lxdstart
alias lxdstart="lxdenv lxd &>/dev/null &"
# Before
lxdstart
sudo lxc config set core.https_address :8443
```

### Build With Termux-Packages

#### Clone Repo

```bash
git clone https://github.com/TapetalArray/termux-eudev
git clone https://github.com/TapetalArray/termux-squashfs-tools
git clone https://github.com/TapetalArray/termux-lxc-lts
git clone https://github.com/TapetalArray/termux-lxd-stable
```

#### Add Packages

```bash
cp -r termux-eudev/packages/eudev termux-packages/packages
cp -r termux-squashfs-tools/packages/squashfs-tools termux-packages/packages
cp -r termux-lxc-lts/packages/lxc-lts termux-packages/packages
cp -r termux-lxd-stable/packages/* termux-packages/packages
```

#### Build

```bash
./build-package.sh -i -a aarch64 lxd-stable
```

## Also See

* [termux-lxc-lts](https://github.com/TapetalArray/termux-lxc-lts)
* [termux-docker-stable](https://github.com/TapetalArray/termux-docker-stable)

## Credits

* [LXD](https://github.com/canonical/lxd)
* [dqlite](https://github.com/canonical/dqlite)
* [LXC](https://github.com/lxc/lxc)
* [eudev](https://github.com/eudev-project/eudev)
* [squashfs-tools](https://github.com/plougher/squashfs-tools)
* [termux-packages](https://github.com/termux/termux-packages)
