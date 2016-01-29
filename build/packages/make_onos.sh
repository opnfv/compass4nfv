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

mkdir -p $WORK_PATH/work/repo/packages/onos
for i in repository.tar jdk-8u51-linux-x64.tar.gz; do
    curl --connect-timeout $TIMEOUT -o $WORK_PATH/work/repo/packages/onos/$i $PACKAGE_URL/$i
done

git  clone https://gerrit.opnfv.org/gerrit/onosfw  $WORK_PATH/work/repo/temp/onosfw

pushd .
cd $WORK_PATH/work/repo/temp/onosfw/
. autobuild.sh $WORK_PATH/work/repo/packages/onos
popd
