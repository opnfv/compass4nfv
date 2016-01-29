#!/bin/bash
##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################
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
