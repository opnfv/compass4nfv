##############################################################################
# Copyright (c) 2016 Nokia and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

# TODO compile kernel and qemu in docker container

WORK_PATH=$(cd "$(dirname "$0")"/..; pwd)
CACHE_DIR=$WORK_PATH/work/repo/temp
DST_DIR=$WORK_PATH/work/repo/packages/kvmfornfv/
source $WORK_PATH/build/build.conf

function prepare()
{
    sudo apt-get install -y libtool libglib2.0-dev autoconf automake
    mkdir -p $CACHE_DIR
    mkdir -p $DST_DIR

    if [ git ls-remote $KVMFORNFV ];
    then
	    git clone $KVMFORNFV $CACHE_DIR/kvmfornfv
	    mkdir -p $CACHE_DIR/kvmfornfv/build/{boot,usr}
    fi
}

function make_kernel()
{
    cd $CACHE_DIR/kvmfornfv/kernel
    cp arch/x86/configs/opnfv.config .config
    make -j8
    make -j8 modules
    make INSTALL_PATH=$CACHE_DIR/kvmfornfv/build/boot install
    make INSTALL_MOD_PATH=$CACHE_DIR/kvmfornfv/build modules_install
}

function make_qemu()
{
    mkdir -p $CACHE_DIR/kvmfornfv/qemu/build
    cd $CACHE_DIR/kvmfornfv/qemu/build
    ../configure --prefix=$CACHE_DIR/kvmfornfv/build/usr --enable-system --enable-kvm
    make -j8
    make install
}

function make_kvmfornfv()
{
    pushd .

    prepare
    make_kernel
    make_qemu

    tar -czf $DST_DIR/kvmfornfv.tar.gz \
        -C $CACHE_DIR/kvmfornfv/build .
    cd -

    popd
}

make_kvmfornfv

