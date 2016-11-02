#!/bin/bash
##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################
set -ex

TEMP_DIR=/work/repo/temp
DST_DIR=/work/repo/packages/kvmfornfv/
export KVMFORNFV=${kvmfornfv:-https://gerrit.opnfv.org/gerrit/p/kvmfornfv.git}


function prepare()
{
    sudo apt-get install -y bc libtool libglib2.0-dev autoconf automake make flex bison
    mkdir -p $TEMP_DIR
    mkdir -p $DST_DIR

    if [ "git ls-remote $KVMFORNFV" ];
    then
	    git clone $KVMFORNFV $TEMP_DIR/kvmfornfv
	    mkdir -p $TEMP_DIR/kvmfornfv/build/{boot,usr}
    fi
}

function make_kernel()
{
    cd $TEMP_DIR/kvmfornfv/kernel
    cp arch/x86/configs/opnfv.config .config
    make -j8
    make -j8 modules
    make INSTALL_PATH=$TEMP_DIR/kvmfornfv/build/boot install
    make INSTALL_MOD_PATH=$TEMP_DIR/kvmfornfv/build modules_install
}

function make_qemu()
{
    mkdir -p $TEMP_DIR/kvmfornfv/qemu/build
    cd $TEMP_DIR/kvmfornfv/qemu/build
    ../configure --prefix=$TEMP_DIR/kvmfornfv/build/usr --enable-system --enable-kvm
    make -j8
    make install
}

function make_kvmfornfv()
{
    pushd .

    prepare
    make_kernel
    make_qemu

    tar -czf /kvmfornfv.tar.gz \
        -C $TEMP_DIR/kvmfornfv/build .
    cd -

    popd
}

make_kvmfornfv

