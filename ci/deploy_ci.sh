#!/bin/bash
##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

CI_DIR=$(cd $(dirname ${BASH_SOURCE:-$0});pwd)

if [[ $DEPLOY_SCENARIO == os-nosdn-nofeature-ha ]]; then
    export OS_VERSION=xenial
    export OPENSTACK_VERSION=newton_xenial
fi

if [[ $DEPLOY_SCENARIO == os-odl_l2-moon-ha ]]; then
    export OS_VERSION=xenial
    export OPENSTACK_VERSION=mitaka_xenial
fi

if [[ $DEPLOY_SCENARIO == os-ocl-nofeature-ha ]]; then
    export OS_VERSION=trusty
    export OPENSTACK_VERSION=liberty
fi

echo 'DEPLOY_SCENARIO='$DEPLOY_SCENARIO
echo 'OS_VERSION='$OS_VERSION
echo 'OPENSTACK_VERSION='$OPENSTACK_VERSION

$CI_DIR/../deploy.sh
