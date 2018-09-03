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
    echo "Not support aarch64, please try quickstart_k8s.sh instead"
    exit 1
fi

sudo apt-get update
sudo apt-get install -y git

git clone https://gerrit.opnfv.org/gerrit/compass4nfv

pushd compass4nfv

CURRENT_DIR=$PWD
SCENARIO=${SCENARIO:-os-nosdn-nofeature-ha.yml}

./build.sh

export TAR_URL=file://$CURRENT_DIR/work/building/compass.tar.gz
export DHA=$CURRENT_DIR/deploy/conf/vm_environment/$SCENARIO
export NETWORK=$CURRENT_DIR/deploy/conf/vm_environment/network.yml

./deploy.sh
