#!/bin/bash
# #############################################################################
# Copyright (c) 2018 Intel Corp.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
# #############################################################################

apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
sleep 3

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88

add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt-get update
sleep 3

apt-get install -y docker-ce
sleep 5
