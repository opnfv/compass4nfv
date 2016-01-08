
WORK_PATH=$(cd "$(dirname "$0")"/..; pwd)

source $WORK_PATH/build/build.conf

for i in odl.tar.gz; do
    curl --connect-timeout $TIMEOUT -o $WORK_PATH/work/repo/temp/$i $PACKAGE_URL/$i
    tar -zxvf $WORK_PATH/work/repo/temp/$i -C $WORK_PATH/work/repo/packages
done


