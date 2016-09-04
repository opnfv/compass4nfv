#!/bin/bash

#./build.sh
#export OS_VERSION=centos7
export OS_VERSION=trusty
export OPENSTACK_VERSION=mitaka
#export OPENSTACK_VERSION=liberty
export ISO_URL=file:///opt/share/compass4nfv_ci/opnfv-2016-08-30_08-17-30.iso
#export DHA=/opt/share/compass4nfv_test_br/deploy/conf/vm_environment/os-nosdn-nofeature-ha.yml
#export NETWORK=/opt/share/compass4nfv_test_br/deploy/conf/network_cfg_108.yaml

export DHA=/opt/share/compass4nfv_ci/os-nosdn-nofeature-ha.yml
export NETWORK=/opt/share/compass4nfv_ci/network_cfg_108.yaml

export DEPLOY_FIRST_TIME=False

#export DEPLOY_HOST=${DEPLOY_HOST-"true"}

./deploy.sh

