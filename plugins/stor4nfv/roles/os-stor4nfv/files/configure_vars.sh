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

# auth
sed -i 's/^opensds_auth_strategy.*/opensds_auth_strategy: noauth/g' group_vars/auth.yml

# opensds_endpoint
sed -i 's/^opensds_endpoint.*/opensds_endpoint: http:\/\/'"$1"':50040/g' group_vars/common.yml

# backend
sed -i 's/^enabled_backend.*/enabled_backend: lvm/g' group_vars/osdsdock.yml

# lvm
sed -i 's/^tgtBindIp.*/tgtBindIp: '"$1"'/g' group_vars/lvm/lvm.yaml

