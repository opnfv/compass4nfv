##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

#!/bin/bash

rm -rf /home/networking
rm -rf /home/tmp

mkdir -p /home/networking
mkdir -p /home/tmp

cd /home/networking

git clone https://github.com/openstack/networking-odl.git -b stable/ocata

sed -i 's/^Babel.*/Babel!=2.4.0,>=2.3.4/' /home/networking/networking-odl/requirements.txt

pip wheel /home/networking/networking-odl/ -w /home/tmp/

cp /home/tmp/networking* /var/www/repo/os-releases/15.1.4/ubuntu-16.04-x86_64/

sleep 30
