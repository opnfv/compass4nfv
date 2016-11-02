#!/bin/bash
##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

"""OS version of the Docker container used for downloading PPA packages."""

# OS mapping
os_map = {
    'trusty': '14.04.3',
    'xenial': '16.04',
    'rhel7': '7.2.1511',
    'redhat7': 'rhel7.2'}
