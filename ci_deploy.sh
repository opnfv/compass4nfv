#!/bin/bash
##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

DHA_SET=$DHA
DHA_SET=${DHA_SET##*/}

if [[ $DHA_SET == os-nosdn-nofeature-ha.yml ]]; then
    export OS_VERSION=xenial
    export OPENSTACK_VERSION=newton_xenial
fi

if [[ $DHA_SET == os-odl_l2-moon-ha.yml ]]; then
    export OS_VERSION=xenial
    export OPENSTACK_VERSION=mitaka_xenial
fi

if [[ $DHA_SET == os-ocl-nofeature-ha.yml ]]; then
    export OS_VERSION=trusty
    export OPENSTACK_VERSION=liberty
fi

echo 'DHA='$DHA
echo 'OS_VERSION='$OS_VERSION
echo 'OPENSTACK_VERSION='$OPENSTACK_VERSION

./deploy.sh
