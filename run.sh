#!/bin/bash
##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

# YOUR_ISO is your iso's absolute path
# export YOUR_ISO=file:///home/compass/compass4nfv.iso
# or
# export YOUR_ISO=http://artifacts.opnfv.org/compass4nfv/colorado/opnfv-colorado.1.0.iso

# YOUR_DHA is your dha.yml's path
# export YOUR_DHA=/home/compass4nfv/deploy/conf/vm_environment/os-nosdn-nofeature-ha.yml

# YOUR_NETWORK is your network.yml's path
# export YOUR_NETWORK=/home/compass4nfv/deploy/conf/vm_environment/huawei-virtual1/network.yml

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

########## ISO_URL ##########
export ISO_URL=${YOUR_ISO}

########## Deploy or Expansion ##########
export EXPANSION=0
export MANAGEMENT_IP_START="10.1.0.50"

########## DHA and NETWORK ##########
export DHA=${YOUR_DHA}
export NETWORK=${YOUR_NETWORK}

########## Hardware_Deploy Jumpserver_NIC ##########
# you need comment out it when virtual deploy
# export INSTALL_NIC=eth1

########## Deploy or Redeploy ##########
# export DEPLOY_HOST="true"
# export DEPLOY_FIRST_TIME="false"

./deploy.sh

