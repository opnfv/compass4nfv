#!/bin/bash
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
