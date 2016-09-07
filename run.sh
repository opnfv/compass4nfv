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
export YOUR_ISO=/compass4nfv.iso
# YOUR_DHA is your dha.yml's path
export YOUR_DHA=/home/compass4nfv/deploy/conf/hardware_environment/huawei-pod1/dha.yml
# YOUR_NETWORK is your network.yml's path
export YOUR_NETWORK=/home/compass4nfv/deploy/conf/network_cfg.yaml

# configure ip, netmask and gateway for compass-core
export COMPASS_EXTERNAL_IP="10.200.245.30"
export COMPASS_EXTERNAL_MASK="255.255.255.0"
export COMPASS_EXTERNAL_GW="10.200.245.1"

# ENABLE_GUI=1 -> use gui to deploy DC, ENABLE_GUI=0 -> use cli to deploy DC
export ENABLE_GUI=1

##########Ubuntu14.04 Mitaka##########
export OS_VERSION=trusty
export OPENSTACK_VERSION=mitaka

##########Ubuntu16.04 Mitaka##########
#export OS_VERSION=xenial
#export OPENSTACK_VERSION=mitaka_xenial

##########Centos7 Mitaka##########
#export OS_VERSION=centos7
#export OPENSTACK_VERSION=mitaka

##########ISO_URL##########
export ISO_URL=file://${YOUR_ISO}
#export ISO_URL=http://artifacts.opnfv.org/compass4nfv/colorado/opnfv-colorado.1.0.iso

##########Deploy or Expansion##########
export EXPANSION=0
export MANAGEMENT_IP_START="10.1.0.50"
# export VIRT_NUMBER=5

##########DHA and NETWORK##########
export DHA=${YOUR_DHA}
export NETWORK=${YOUR_NETWORK}

##########Hardware_Deploy Jumpserver_NIC##########
export INSTALL_NIC=eth1

##########Deploy or Redeploy##########
#export DEPLOY_HOST=${DEPLOY_HOST-"true"}
#export DEPLOY_FIRST_TIME="false"

./deploy.sh

