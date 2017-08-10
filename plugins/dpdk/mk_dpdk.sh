#!/bin/bash
set -eux

CUR_DIR=$(cd "$(dirname "$0")";pwd)

#download dpdk package
wget http://fast.dpdk.org/rel/dpdk-16.11.2.tar.xz
tar -xvf dpdk-16.11.2.tar.xz

#prepare for make dpdk
apt-get install -y gcc make cmake -y
apt-get install libpcap0.8 libpcap0.8-dev -y

export DPDK_DIR=$CUR_DIR/dpdk-stable-16.11.2

echo $CUR_DIR
echo $DPDK_DIR

export DPDK_TARGET=x86_64-native-linuxapp-gcc
export DPDK_BUILD=$DPDK_DIR/$DPDK_TARGET

pushd $DPDK_DIR

#pre seting dpdk
make config T=x86_64-native-linuxapp-gcc
sed -ri 's,(PMD_PCAP=).*,\1y,' build/.config

#make dpdk
make install T=$DPDK_TARGET DESTDIR=install

popd
