#!/bin/bash

for i in `ls /root/compass4nfv/deploy/adapters/ansible | grep "openstack_"`; do
    mkdir -p /root/docker_compose/ansible/$i
    cp -rf /root/compass4nfv/deploy/adapters/ansible/openstack/* /root/docker_compose/ansible/$i
    cp -rf /root/compass4nfv/deploy/adapters/ansible/$i /root/docker_compose/ansible/
done
cp -rf /root/compass4nfv/deploy/adapters/ansible/roles /root/docker_compose/ansible/
