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
    export OS_VERSION=${OS_VERSION:-xenial}
    export OPENSTACK_VERSION=${OPENSTACK_VERSION:-newton_xenial}

elif [[ $DEPLOY_SCENARIO == os-odl_2-nofeature-ha ]]; then
    export OS_VERSION=${OS_VERSION:-xenial}
    export OPENSTACK_VERSION=${OPENSTACK_VERSION:-newton_xenial}

elif [[ $DEPLOY_SCENARIO == os-odl_l2-moon-ha ]]; then
    export OS_VERSION=${OS_VERSION:-xenial}
    export OPENSTACK_VERSION=${OPENSTACK_VERSION:-mitaka_xenial}

elif [[ $DEPLOY_SCENARIO == os-ocl-nofeature-ha ]]; then
    export OS_VERSION=${OS_VERSION:-trusty}
    export OPENSTACK_VERSION=${OPENSTACK_VERSION:-liberty}

else
    export OS_VERSION=${OS_VERSION:-trusty}
    export OPENSTACK_VERSION=${OPENSTACK_VERSION:-mitaka}
fi

echo "########################################"
echo 'DEPLOY_SCENARIO='$DEPLOY_SCENARIO
echo 'OS_VERSION='$OS_VERSION
echo 'OPENSTACK_VERSION='$OPENSTACK_VERSION
echo "########################################"

#$CI_DIR/../deploy.sh
