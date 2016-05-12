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

BUILD_PATH=$(cd "$(dirname "$0")"; pwd)
WORK_PATH=$(cd "$(dirname "$0")"/..; pwd)

if [[ -d $WORK_PATH/work/repo/packages ]]; then
    rm -rf $WORK_PATH/work/repo/packages
fi

if [[  -d $WORK_PATH/work/repo/temp ]]; then
    rm -rf $WORK_PATH/work/repo/temp
fi

mkdir -p $WORK_PATH/work/repo/packages
mkdir -p $WORK_PATH/work/repo/temp

for i in `ls $WORK_PATH/build/packages`; do
    . $WORK_PATH/build/packages/$i $WORK_PATH/repo/packages
done

tar -zcvf $WORK_PATH/repo/packages.tar.gz $WORK_PATH/work/repo/packages
