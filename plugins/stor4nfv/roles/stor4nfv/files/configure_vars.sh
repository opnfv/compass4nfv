#!/bin/bash

cd $HOME/gopath/src/github.com/stor4nfv/stor4nfv/ci/ansible

sed -i 's/^workplace.*/workplace: \/root/g' group_vars/common.yml

sed -i 's/^enabled_backend.*/enabled_backend: ceph/g' group_vars/osdsdock.yml

sed -i 's/^ceph_pool_name.*/ceph_pool_name: "rbd"/g' group_vars/osdsdock.yml

sed -i 's/^ceph_origin.*/ceph_origin: repository/g' group_vars/ceph/all.yml

sed -i 's/^ceph_repository.*/ceph_repository: community/g' group_vars/ceph/all.yml

sed -i 's/^ceph_stable_release.*/ceph_stable_release: luminous/g' group_vars/ceph/all.yml

sed -i 's/^public_network.*/public_network: 192.16.1.210\/24/g' group_vars/ceph/all.yml

sed -i 's/^monitor_interface.*/monitor_interface: eth1/g' group_vars/ceph/all.yml

sed -i 's/^#osd_auto_discovery.*/osd_auto_discovery: true/g' group_vars/ceph/osds.yml

sed -i 's/^osd_scenario.*/osd_scenario: collocated/g' group_vars/ceph/osds.yml

