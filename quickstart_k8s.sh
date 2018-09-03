#!/bin/bash
##############################################################################
# Copyright (c) 2016-2017 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

COMPASS_ARCH=$(uname -m)
if [ "$COMPASS_ARCH" = "aarch64" ]; then
    echo "Running on aarch64 host, make sure your jump host is configured okay"
    echo "Please reference docs/release/installation/k8s-deploy-arm.rst"
    export ADAPTER_OS_PATTERN='(?i)CentOS-7.*arm.*'
    SCENARIO=${SCENARIO:-k8-nosdn-nofeature-noha.yml}
fi

sudo apt-get update
sudo apt-get install -y git

git clone https://gerrit.opnfv.org/gerrit/compass4nfv

pushd compass4nfv

CURRENT_DIR=$PWD

#k8s only support on centos
export OS_VERSION=centos7
export KUBERNETES_VERSION="v1.7.3"
SCENARIO=${SCENARIO:-k8-nosdn-nofeature-ha.yml}

./build.sh

export TAR_URL=file://$CURRENT_DIR/work/building/compass.tar.gz
export DHA=$CURRENT_DIR/deploy/conf/vm_environment/$SCENARIO
export NETWORK=$CURRENT_DIR/deploy/conf/vm_environment/network.yml

./deploy.sh
