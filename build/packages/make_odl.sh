##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

WORK_PATH=$(cd "$(dirname "$0")"/..; pwd)

source $WORK_PATH/build/build.conf

for i in odl.tar.gz; do
    curl --connect-timeout $TIMEOUT -o $WORK_PATH/work/repo/temp/$i $PACKAGE_URL/$i
    tar -zxvf $WORK_PATH/work/repo/temp/$i -C $WORK_PATH/work/repo/packages
done


