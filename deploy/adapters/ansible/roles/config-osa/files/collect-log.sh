#!/bin/bash
##############################################################################
# Copyright (c) 2018 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_PATH="$(dirname $(realpath ${BASH_SOURCE[0]}))"

openstack-ansible $SCRIPT_PATH/collect-log.yml
