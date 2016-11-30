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

if [[ $ROOT_BUILD_CAUSE == MANUALTRIGGER ]]; then
    export OS_VERSION=${OS_VERSION:-trusty}
    export OPENSTACK_VERSION=${OPENSTACK_VERSION:-mitaka}
fi

if [[ $OS_VERSION == centos ]]; then
    case $DEPLOY_SCENARIO in
    os-odl_l2-moon-ha)
        export OS_VERSION=xenial
        export OPENSTACK_VERSION=mitaka_xenial
        ;;
    os-ocl-nofeature-ha)
        export OPENSTACK_VERSION=liberty
        ;;
    *)
        export OPENSTACK_VERSION=${OPENSTACK_VERSION:-mitaka}
        ;;
    esac
else
    case $DEPLOY_SCENARIO in
    os-nosdn-nofeature-ha)
        export OS_VERSION=xenial
        export OPENSTACK_VERSION=newton_xenial
        ;;
    os-odl_2-nofeature-ha)
        export OS_VERSION=xenial
        export OPENSTACK_VERSION=newton_xenial
        ;;
    os-odl_l2-moon-ha)
        export OS_VERSION=xenial
        export OPENSTACK_VERSION=mitaka_xenial
        ;;
    os-ocl-nofeature-ha)
        export OS_VERSION=trusty
        export OPENSTACK_VERSION=liberty
        ;;
    *)
        export OS_VERSION=${OS_VERSION:-trusty}
        export OPENSTACK_VERSION=${OPENSTACK_VERSION:-mitaka}
        ;;
    esac
fi

echo "########################################"
echo 'DEPLOY_SCENARIO='$DEPLOY_SCENARIO
echo 'OS_VERSION='$OS_VERSION
echo 'OPENSTACK_VERSION='$OPENSTACK_VERSION
echo "########################################"

$CI_DIR/../deploy.sh
