#!/bin/bash

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
export ISO_URL=file:///${YOUR_OWN}/opnfv-colorado.1.0.iso
#export ISO_URL=http://artifacts.opnfv.org/compass4nfv/colorado/opnfv-colorado.1.0.iso

##########Deploy or Expansion##########
export EXPANSION=0
export MANAGEMENT_IP_START="10.1.0.50"
export VIRT_NUMBER=5

##########DHA and NETWORK##########
export DHA=${YOUR_OWN}/[dha].yml
export NETWORK=${YOUR_OWN}/network.yml

##########Hardware_Deploy Jumpserver_NIC##########
#export INSTALL_NIC=${INSTALL_NIC:-p1p1}

##########Deploy or Redeploy##########
#export DEPLOY_HOST=${DEPLOY_HOST-"true"}
#export DEPLOY_FIRST_TIME="false"

./deploy.sh
