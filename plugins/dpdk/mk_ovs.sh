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
make
sudo make install

