#!/bin/bash
##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

# Set OS version for target hosts
# Ubuntu16.04 or CentOS7
#export OS_VERSION=xenial/centos7

# Set ISO image corresponding to your code
# export TAR_URL=file:///home/compass/compass4nfv.iso
#export TAR_URL=

#export DEPLOY_HARBOR="true"
#export HABOR_VERSION="1.5.0"

# Set url for download the tar file of harbor
#export HABOR_DOWNLOAD_URL=https://storage.googleapis.com/harbor-releases/release-$HABOR_VERSION/harbor-offline-installer-v$HABOR_VERSION.tgz
# Set hardware deploy jumpserver PXE NIC
# You need to comment out it when virtual deploy.
#export INSTALL_NIC=eth1

# DHA is your dha.yml's path
# export DHA=/home/compass4nfv/deploy/conf/vm_environment/os-nosdn-nofeature-ha.yml
#export DHA=

# NETWORK is your network.yml's path
# export NETWORK=/home/compass4nfv/deploy/conf/vm_environment/huawei-virtual1/network.yml
#export NETWORK=

#export OPENSTACK_VERSION=${OPENSTACK_VERSION:-ocata}

export OPENSTACK_VERSION=queens

export COMPASS_ARCH=$(uname -m)

if [[ "x"$KUBERNETES_VERSION != "x" ]]; then
   unset OPENSTACK_VERSION
fi

COMPASS_DIR=`cd ${BASH_SOURCE[0]%/*}/;pwd`
export COMPASS_DIR

if [[ -z $DEPLOY_COMPASS && -z $DEPLOY_HOST && -z $REDEPLOY_HOST ]]; then
    export DEPLOY_COMPASS="true"
    export DEPLOY_HOST="true"
fi

LOG_DIR=$COMPASS_DIR/work/deploy/log
export LOG_DIR

mkdir -p $LOG_DIR

$COMPASS_DIR/deploy/launch.sh $* 2>&1 | tee $LOG_DIR/compass-deploy.log

if [[ $(tail -1 $LOG_DIR/compass-deploy.log) != 'compass deploy success' ]]; then
    exit 1
fi
