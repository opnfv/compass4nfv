#!/bin/bash
##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

CURRENT_DIR=$PWD
SCENARIO=os-nosdn-nofeature-ha.yml

export TAR_URL=file://$CURRENT_DIR/work/building/compass.tar.gz
export DHA=$CURRENT_DIR/deploy/conf/vm_environment/$SCENARIO
export NETWORK=$CURRENT_DIR/deploy/conf/vm_environment/network.yml
# ISO_URL is your iso's absolute path
# export ISO_URL=file:///home/compass/compass4nfv.iso
# or
# export ISO_URL=http://artifacts.opnfv.org/compass4nfv/colorado/opnfv-colorado.1.0.iso
#export TAR_URL=file:///home/wtw/work/compass4nfv/work/building/compass.tar.gz
#
## DHA is your dha.yml's path
## export DHA=/home/compass4nfv/deploy/conf/vm_environment/os-nosdn-nofeature-ha.yml
#export DHA=/home/wtw/os-nosdn-nofeature-ha.yml
#
## NETWORK is your network.yml's path
## export NETWORK=/home/compass4nfv/deploy/conf/vm_environment/huawei-virtual1/network.yml
#export NETWORK=/home/wtw/network.yml

######################### The environment for Openstack ######################
# Ubuntu16.04
export OS_VERSION=xenial

# Centos7
#export OS_VERSION=centos7

export OPENSTACK_VERSION=pike

######################### Hardware Deploy Jumpserver PXE NIC ################
# You need comment out it when virtual deploy.
#export INSTALL_NIC=eth1

######################### Virtual Deploy Nodes Number ########################
# How many nodes do you need when virtual deploy. The default number is 5.
#export VIRT_NUMBER=2
export VIRT_CPUS=8
######################### Deploy or Expansion ###############################
# Modify network.yml and virtual_cluster_expansion.yml or
# hardware_cluster_expansion.yml.
# Edit the DHA and NETWORK envionment variables.
# External subnet's ip_range and management ip should be changed as the
# first 6 IPs are already taken by the first deployment.
# VIRT_NUMBER decide how many virtual machines needs to expand when virtual expansion

#export EXPANSION="true"
#export MANAGEMENT_IP_START="10.1.0.55"
#export VIRT_NUMBER=1
#export DEPLOY_FIRST_TIME="false"

######################### Deploy Compass ####################################
# If you only need to deploy compass, set this variable.
#export DEPLOY_COMPASS="true"

######################### Deploy or Redeploy Host ###########################
# If you only need to deploy host, set these variables.
#export DEPLOY_HOST="true"
#export REDEPLOY_HOST="true"

######################### Reconvery #########################################
# After restart jumpserver, set these variables and run deploy.sh again.
#export DEPLOY_RECOVERY="true"
#export DEPLOY_FIRST_TIME="false"


#set -x
COMPASS_DIR=`cd ${BASH_SOURCE[0]%/*}/;pwd`
export COMPASS_DIR

#rm -rf /home/wtw/work1/compass4nfv/work/deploy/docker/ansible/run/*
if [[ -z $DEPLOY_COMPASS && -z $DEPLOY_HOST && -z $REDEPLOY_HOST ]]; then
    export DEPLOY_COMPASS="true"
    export DEPLOY_HOST="true"
fi

$COMPASS_DIR/deploy/launch.sh $*

