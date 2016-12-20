#!/bin/bash
##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

# ROOT_BUILD_CAUSE DEPLOY_SCENARIO COMPASS_OS_VERSION got from CI

CI_DIR=$(cd $(dirname ${BASH_SOURCE:-$0});pwd)

# FIXME: Some scenarios need to update.
case $DEPLOY_SCENARIO in
os-odl_l3-nofeture-ha)
    echo "os-odl_l3-nofeature-ha scenario supports mitaka only"
    exit 1
    ;;
os-odl_l2-moon-ha)
    echo "os-odl_l2-moon-ha scenario supports xenial mitaka only"
    exit 1
    ;;
os-onos-nofeature-ha)
    echo "os-onos-nofeature-ha scenario supports mitaka only"
    exit 1
    ;;
os-onos-sfc-ha)
    echo "os-onos-sfc-ha scenario supports mitaka only"
    exit 1
    ;;
os-ocl-nofeature-ha)
    echo "os-ocl-nofeature-ha scenario supports liberty only"
    exit 1
    ;;
esac

if [[ $ROOT_BUILD_CAUSE == MANUALTRIGGER ]]; then
# For manual ci trigger build, directly use the value pass from CI
    export COMPASS_OS_VERSION=${COMPASS_OS_VERSION:-xenial}
    export COMPASS_OPENSTACK_VERSION=${COMPASS_OPENSTACK_VERSION:-newton}

else
# For daily build or verify build, adjust COMPASS_OS_VERSION and OPENSTACK_VERSION
# value according to COMPASS_OS_VERSION pass from CI

    if [[ $COMPASS_OS_VERSION == centos7 ]]; then
        export COMPASS_OS_VERSION=${COMPASS_OS_VERSION:-centos7}
        export COMPASS_OPENSTACK_VERSION=${COMPASS_OPENSTACK_VERSION:-newton}
    else
        export COMPASS_OS_VERSION=${COMPASS_OS_VERSION:-xenial}
        export COMPASS_OPENSTACK_VERSION=${COMPASS_OPENSTACK_VERSION:-newton}
    fi
fi

# these variables used by compass
export OS_VERSION=$COMPASS_OS_VERSION
export OPENSTACK_VERSION=$COMPASS_OPENSTACK_VERSION

set +x
echo "#############################################"
echo 'DEPLOY_SCENARIO='$DEPLOY_SCENARIO
echo 'OS_VERSION='$OS_VERSION
echo 'OPENSTACK_VERSION='$OPENSTACK_VERSION
echo "#############################################"
set -x

$CI_DIR/../deploy.sh
