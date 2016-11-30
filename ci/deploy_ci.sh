#!/bin/bash
##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

# ROOT_BUILD_CAUSE DEPLOY_SCENARIO OS_VERSION got from CI

CI_DIR=$(cd $(dirname ${BASH_SOURCE:-$0});pwd)

if [[ $ROOT_BUILD_CAUSE != TIMERTRIGGER ]]; then
    # For manual ci trigger buid or verify build, directly use the value pass from CI
    export OS_VERSION=${OS_VERSION:-trusty}
    export OPENSTACK_VERSION=${OPENSTACK_VERSION:-mitaka}

else
    # For daily build, adjust OS_VERSION and OPENSTACK_VERSION
    # value according to OS_VERSION and DEPLOY_SCENARIO pass from CI

    if [[ $OS_VERSION == centos ]]; then
        case $DEPLOY_SCENARIO in
        os-odl_l2-moon-ha)
            # os-odl_l2-moon-ha scenario supports xenial mitaka only
            export OS_VERSION=xenial
            export OPENSTACK_VERSION=mitaka_xenial
            ;;
        os-ocl-nofeature-ha)
            # os-ocl-nofeature-ha scenario supports liberty only
            export OPENSTACK_VERSION=liberty
            ;;
        *)
            # setup for testing mitaka by default
            export OPENSTACK_VERSION=${OPENSTACK_VERSION:-mitaka}
            ;;
        esac

    else
        case $DEPLOY_SCENARIO in
        os-nosdn-nofeature-ha)
            # temporarily setup for testing newton
            export OS_VERSION=xenial
            export OPENSTACK_VERSION=newton_xenial
            ;;
        os-odl_2-nofeature-ha)
            # temporarily setup for testing newton
            export OS_VERSION=xenial
            export OPENSTACK_VERSION=newton_xenial
            ;;
        os-odl_l2-moon-ha)
            # os-odl_l2-moon-ha scenario supports xenial mitaka only
            export OS_VERSION=xenial
            export OPENSTACK_VERSION=mitaka_xenial
            ;;
        os-ocl-nofeature-ha)
            # os-ocl-nofeature-ha scenario supports liberty only
            export OS_VERSION=trusty
            export OPENSTACK_VERSION=liberty
            ;;
        *)
            # setup for testing mitaka by default
            export OS_VERSION=${OS_VERSION:-trusty}
            export OPENSTACK_VERSION=${OPENSTACK_VERSION:-mitaka}
            ;;
        esac
    fi
fi

echo "########################################"
echo 'DEPLOY_SCENARIO='$DEPLOY_SCENARIO
echo 'OS_VERSION='$OS_VERSION
echo 'OPENSTACK_VERSION='$OPENSTACK_VERSION
echo "########################################"

$CI_DIR/../deploy.sh
