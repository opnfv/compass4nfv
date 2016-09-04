#!/bin/bash

virsh destroy host6
virsh undefine host6
rm -rf work/deploy/vm/host6/

sshpass -p root ssh -o StrictHostKeyChecking=no root@192.168.200.2 "
cat << EOF | mysql
use compass
select * from clusterhost;
delete from clusterhost where host_id = 6;
delete from host_network where host_id = 6;
EOF
"
echo \'00:00:13:11:53:f5\' \'00:00:e0:b2:27:86\' \'00:00:03:a4:93:6d\' \'00:00:6e:e3:0a:ab\' \'00:00:52:bb:cb:9d\' > work/deploy/switch_machines
#./build.sh
#export OS_VERSION=centos7
export OS_VERSION=trusty
export OPENSTACK_VERSION=mitaka
#export OPENSTACK_VERSION=liberty
export ISO_URL=file:///opt/share/compass4nfv_ci/opnfv-2016-08-30_08-17-30.iso
#export DHA=/opt/share/compass4nfv_test_br/deploy/conf/vm_environment/os-nosdn-nofeature-ha.yml
#export NETWORK=/opt/share/compass4nfv_test_br/deploy/conf/network_cfg_108.yaml

#export DHA=/opt/share/compass4nfv_recovery/os-nosdn-nofeature-ha.yml
#export NETWORK=/opt/share/compass4nfv_recovery/network_cfg_108.yaml
export DHA=/opt/share/compass4nfv_ci/expansion_dha.yml
export NETWORK=/opt/share/compass4nfv_ci/expansion_network.yml

export DEPLOY_FIRST_TIME=False

#export DEPLOY_HOST=${DEPLOY_HOST-"true"}

export VIRT_NUMBER=1
export EXPANSION=1
export MANAGEMENT_IP_START="10.1.0.56"

./deploy.sh

