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

PACKAGE_URL=http://205.177.226.237:9999

curl --connect-timeout $TIMEOUT -o /odl.tar.gz $PACKAGE_URL/odl.tar.gz


