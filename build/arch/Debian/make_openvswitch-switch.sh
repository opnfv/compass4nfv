#!/bin/bash
apt-get update
apt-get install -y build-essential fakeroot debhelper \
         autoconf automake bzip2 libssl-dev \
         openssl graphviz python-all procps \
         python-qt4 python-zopeinterface \
         python-twisted-conch libtool wget

pushd .
cd /tmp
wget http://openvswitch.org/releases/openvswitch-2.3.1.tar.gz
tar -zxvf openvswitch-2.3.1.tar.gz
cd openvswitch-2.3.1
DEB_BUILD_OPTIONS='parallel=8 nocheck' fakeroot debian/rules binary
cd -
cp -f *.deb /var/cache/apt/archives/
popd
