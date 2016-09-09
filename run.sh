#!/bin/bash
##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

# ISO_URL is your iso's absolute path
# export ISO_URL=file:///home/compass/compass4nfv.iso
# or
# export ISO_URL=http://artifacts.opnfv.org/compass4nfv/colorado/opnfv-colorado.1.0.iso
export ISO_URL=

# DHA is your dha.yml's path
# export DHA=/home/compass4nfv/deploy/conf/vm_environment/os-nosdn-nofeature-ha.yml
export DHA=

# NETWORK is your network.yml's path
# export NETWORK=/home/compass4nfv/deploy/conf/vm_environment/huawei-virtual1/network.yml
export NETWORK=

# node number when you virtual deploy
# export VIRT_NUMBER=5

########## Ubuntu14.04 Mitaka ##########
export OS_VERSION=trusty
export OPENSTACK_VERSION=mitaka

########## Ubuntu16.04 Mitaka ##########
# export OS_VERSION=xenial
# export OPENSTACK_VERSION=mitaka_xenial

########## Centos7 Mitaka ##########
# export OS_VERSION=centos7
# export OPENSTACK_VERSION=mitaka

########## Hardware Deploy Jumpserver PXE NIC ##########
# you need comment out it when virtual deploy
# export INSTALL_NIC=eth1

########## Deploy or Redeploy ##########
# export DEPLOY_HOST="true"
# export DEPLOY_FIRST_TIME="false"

./deploy.sh

