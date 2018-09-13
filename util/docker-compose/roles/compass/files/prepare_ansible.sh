##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

#!/bin/bash

for i in `ls /root/compass4nfv/deploy/adapters/ansible | grep "openstack_"`; do
    mkdir -p /root/docker_compose/ansible/$i
    cp -rf /root/compass4nfv/deploy/adapters/ansible/openstack/* /root/docker_compose/ansible/$i
    cp -rf /root/compass4nfv/deploy/adapters/ansible/$i /root/docker_compose/ansible/
done
cp -rf /root/compass4nfv/deploy/adapters/ansible/roles /root/docker_compose/ansible/
