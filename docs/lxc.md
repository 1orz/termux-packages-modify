# Termux LXC LTS

LXC LTS Termux port

## Prerequisites

Custom Kernel with Docker's necessary options enabled, for GKI kernel reference [gki-custom](https://github.com/TapetalArray/gki-custom)

Status:

|      |       |
|:----:|:-----:|
| lxc  | 6.0.2 |

## Install

```bash
pkg upg
pkg i tsu
pkg i ./lxc-lts-*.deb
```

## Configure after installation

### Basic Configure

#### Mount Cgroup

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

#### Add mount point

```conf
lxc.cgroup.devices.allow = a *:* rwm

# Systemd-binfmt
lxc.mount.entry = /proc/sys/fs/binfmt_misc proc/sys/fs/binfmt_misc none bind,optional,create=dir

# Fuse
lxc.mount.entry = /dev/fuse dev/fuse none bind,optional,create=file
```

#### Mount Systemd-binfmt

```bash
sudo mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
```

#### Configure Network

##### Host Network

```bash
sed -i 's/lxc\.net\.0\.type = veth/lxc.net.0.type = none/g' $PREFIX/etc/lxc/default.conf
```

##### Bridge

Edit iptable, change 192.168.1.1 according to your gateway IP

```bash
pkg i iproute dnsmasq -y

echo "USE_LXC_BRIDGE=\"true\"" > ${PREFIX}/etc/default/lxc-net
sudo ${PREFIX}/libexec/lxc/lxc-net start

sudo ip rule add pref 1 from all lookup main
sudo ip rule add pref 2 from all lookup default
sudo ip route add default via 192.168.1.1 dev wlan0
sudo ip rule add from all lookup main pref 30000
```

### Display, Sound

#### Install Packages

```bash
pkg upg
pkg i x11-repo -y
pkg i tsu pulseaudio termux-x11-nightly -y
```

#### PulseAudio

```bash
pulseaudio --start \
    --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" \
    --exit-idle-time=-1
```

#### Add mount point for X11

```conf
# X11
lxc.mount.entry = /data/data/com.termux/files/usr/tmp tmp none bind,optional,create=dir
lxc.mount.entry = /data/data/com.termux/files/usr/tmp/.X11-unix tmp/.X11-unix none bind,ro,optional,create=dir

# Freedreno Turnip (Only available for Qualcomm Snapdragon)
lxc.mount.entry = /dev/kgsl-3d0 dev/kgsl-3d0 none bind,optional,create=file
lxc.mount.entry = /dev/dri dev/dri none bind,optional,create=dir
lxc.mount.entry = /dev/dma_heap dev/dma_heap none bind,optional,create=dir
```

### Build with Termux-Packages

#### Clone Repo

```bash
git clone https://github.com/TapetalArray/termux-lxc-lts
```

#### Add Packages

```bash
cp -r termux-lxc-lts/packages/lxc-lts termux-packages/packages
```

#### Build

```bash
./build-package.sh -i -a aarch64 lxc-lts
```

## Also See

* [termux-lxd-stable](https://github.com/TapetalArray/termux-lxd-stable)
* [termux-docker-stable](https://github.com/TapetalArray/termux-docker-stable)

## Credits

* [lxc](https://github.com/lxc/lxc)
* [termux-packages](https://github.com/termux/termux-packages)
* [lateautumn233](https://github.com/lateautumn233)
* [Running lxc for android](https://gist.github.com/lateautumn233/939be0528a2cc34af66864bead58e68a) (Chinese)
