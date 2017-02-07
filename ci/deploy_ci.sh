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

case $DEPLOY_SCENARIO in
    os-odl_l2-moon-ha)
        export COMPASS_OS_VERSION=xenial
        export COMPASS_OPENSTACK_VERSION=mitaka_xenial 
        ;;  
    os-ocl-nofeature-ha)
        export COMPASS_OS_VERSION=trusty
        export COMPASS_OPENSTACK_VERSION=liberty
        ;;  
    *)
        if [[ $COMPASS_OS_VERSION == centos7 ]]; then
            export COMPASS_OS_VERSION=${COMPASS_OS_VERSION:-centos7}
            export COMPASS_OPENSTACK_VERSION=${COMPASS_OPENSTACK_VERSION:-mitaka}
        else
            export COMPASS_OS_VERSION=${COMPASS_OS_VERSION:-trusty}
            export COMPASS_OPENSTACK_VERSION=${COMPASS_OPENSTACK_VERSION:-mitaka}
        fi
        ;;  
esac

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
