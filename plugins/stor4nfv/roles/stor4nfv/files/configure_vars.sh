#!/bin/bash
# #############################################################################
# Copyright (c) 2018 Intel Corp.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
# #############################################################################

cd $HOME/gopath/src/github.com/stor4nfv/stor4nfv/ci/ansible

sed -i 's/^workplace.*/workplace: \/root/g' group_vars/common.yml

sed -i 's/^enabled_backend.*/enabled_backend: ceph/g' group_vars/osdsdock.yml

sed -i 's/^ceph_pool_name.*/ceph_pool_name: "rbd"/g' group_vars/osdsdock.yml

sed -i 's/^ceph_origin.*/ceph_origin: repository/g' group_vars/ceph/all.yml

sed -i 's/^ceph_repository.*/ceph_repository: community/g' group_vars/ceph/all.yml

sed -i 's/^ceph_stable_release.*/ceph_stable_release: luminous/g' group_vars/ceph/all.yml

sed -i 's|^public_network.*|public_network: '"$1"'|g' group_vars/ceph/all.yml

sed -i 's|^cluster_network.*|cluster_network: '"$2"'|g' group_vars/ceph/all.yml

sed -i 's/^monitor_interface.*/monitor_interface: eth0/g' group_vars/ceph/all.yml

sed -i 's/^devices:.*/devices: [\/dev\/loop0, \/dev\/loop1, \/dev\/loop2]/g' group_vars/ceph/osds.yml

sed -i 's/^osd_scenario.*/osd_scenario: collocated/g' group_vars/ceph/osds.yml

sed -i 's/^db_endpoint.*/db_endpoint: localhost:62379,localhost:62380/g' group_vars/osdsdb.yml

sed -i 's/^etcd_port.*/etcd_port: 62379/g' group_vars/osdsdb.yml

sed -i 's/^etcd_peer_port.*/etcd_peer_port: 62380/g' group_vars/osdsdb.yml
