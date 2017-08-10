set -eux

CUR_DIR=$(cd "$(dirname "$0")";pwd)
export DPDK_DIR=$CUR_DIR/dpdk-stable-16.11.2
export OVS_DIR=$CUR_DIR/openvswitch-2.7.2

#download openvswitch
wget http://openvswitch.org/releases/openvswitch-2.7.2.tar.gz
tar -zxvf openvswitch-2.7.2.tar.gz

#prepare
apt-get install libnuma-dev -y
sudo apt-get install dh-autoreconf -y

echo $CUR_DIR
echo $DPDK_DIR
echo $OVS_DIR

export DPDK_TARGET=x86_64-native-linuxapp-gcc
export DPDK_BUILD=$DPDK_DIR/$DPDK_TARGET

#config ovs
pushd $OVS_DIR
./boot.sh
./configure --with-dpdk=$DPDK_BUILD  --with-linux=/lib/modules/$(uname -r)/build

#install ovs
make -j 8
sudo make install

lsmod | grep openvswitch
sudo modprobe openvswitch
lsmod | grep openvswitch
modinfo /lib/modules/$(uname -r)/kernel/net/openvswitch/openvswitch.ko
modinfo /lib/modules/$(uname -r)/kernel/net/bridge/bridge.ko

#verify hugepage
grep HugePages_ /proc/meminfo
#mount hugepage
sudo  mount -t hugetlbfs none /dev/hugepages``

#verify vt-d
dmesg | grep -e DMAR -e IOMMU

# install vfio-pci driver
sudo modprobe vfio-pci
sudo chmod a+x /dev/vfio
sudo chmod 0666 /dev/vfio/*
# Bind phyysical network to be used by DPDK
sudo $DPDK_DIR/tools/dpdk-devbind.py --bind=vfio-pci enp1s0f0
sudo $DPDK_DIR/tools/dpdk-devbind.py --bind=vfio-pci enp1s0f1
$DPDK_DIR/tools/dpdk-devbind.py --status

#setup openswitch db server
sudo mkdir -p /usr/local/etc/openvswitch
sudo ovsdb-tool create /usr/local/etc/openvswitch/conf.db \
    vswitchd/vswitch.ovsschema

sudo mkdir -p /usr/local/var/run/openvswitch
sudo ovsdb-server --remote=punix:/usr/local/var/run/openvswitch/db.sock \
    --remote=db:Open_vSwitch,Open_vSwitch,manager_options \
    --pidfile --detach --log-file


export DB_SOCK=/usr/local/var/run/openvswitch/db.sock
sudo ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-init=true
sudo ovs-vswitchd unix:$DB_SOCK --pidfile --detach

# Validating
sudo ovs-vsctl add-br ovsbr0 -- set bridge ovsbr0 datapath_type=netdev
sudo ovs-vsctl add-port ovsbr0 myportnameone -- set Interface myportnameone \
    type=dpdk options:dpdk-devargs=0000:01:00.0
sudo ovs-vsctl add-port ovsbr0 myportnametwo -- set Interface myportnametwo \
    type=dpdk options:dpdk-devargs=0000:01:00.1

#verify openvswitch up and running
sudo ovs-vsctl show

popd
