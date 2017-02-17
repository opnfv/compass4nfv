#!/bin/bash
##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################
set -ex

TIMEOUT=10

for i in REPLACE_ONOS_PKG; do
    mkdir -p /pkg/onos
    curl --connect-timeout $TIMEOUT -o /pkg/onos/${i##*/} $i
done
