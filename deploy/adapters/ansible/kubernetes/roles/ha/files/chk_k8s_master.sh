##############################################################################
# Copyright (c) 2016-2018 compass4nfv and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

#!/bin/bash

count=`ss -tnl | grep 6443 | wc -l`

if [ $count = 0 ]; then
    exit 1
else
    exit 0
fi
