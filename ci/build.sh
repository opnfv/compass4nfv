#!/bin/bash
set -ex
SCRIPT_DIR=`cd ${BASH_SOURCE[0]%/*};pwd`
WORK_DIR=$SCRIPT_DIR/work

sudo rm -rf $WORK_DIR
mkdir -p $WORK_DIR

COMPASS_CORE=${COMPASS_CORE:-http://github.com/baigk/compass-core.git}
COMPASS_WEB=${COMPASS_WEB:-http://github.com/baigk/compass-web.git}
COMPASS_INSTALL=${COMPASS_INSTALL:-http://github.com/baigk/compass-install.git}
COMPASS_ADAPTERS=${COMPASS_ADAPTERS:-http://github.com/baigk/compass-adapters.git}
PACKAGE_URL=${PACKAGE_URL:-http://192.168.127.11:9999/xh/work/package}

cd $WORK_DIR

# get base iso
wget -O centos_base.iso $PACKAGE_URL/centos_base.iso

# get ubuntu ppa package
#wget -O ubuntu_ppa.tar.gz $PACKAGE_URL/ubuntu_ppa.tar.gz

# generate repo from deloyment script
./make_repo.sh ../deploy/adapters/ansible/

# get ubuntu iso
wget -O Ubuntu-14.04-x86_64.iso $PACKAGE_URL/Ubuntu-14.04-x86_64.iso

# get centos iso
wget -O CentOS-7-x86_64-Minimal-1503-01.iso $PACKAGE_URL/CentOS-7-x86_64-Minimal-1503-01.iso

# get cenos common ppa package
wget -O centos_7_1_common_ppa_repo.tar.gz $PACKAGE_URL/centos_7_1_common_ppa_repo.tar.gz

# get centos openstack ppa package
wget -O centos_7_1_openstack_juno_ppa_repo.tar.gz $PACKAGE_URL/centos_7_1_openstack_juno_ppa_repo.tar.gz

wget -O loaders.tar.gz $PACKAGE_URL/loaders.tar.gz
# mount base iso
mkdir -p base
sudo mount -o loop centos_base.iso base
cd base;find .|cpio -pd ../new;cd -
sudo umount base
chmod 755 ./new -R

# main process
mkdir -p new/repos new/compass new/bootstrap new/pip new/guestimg
cp ./repo/trusty-juno-ppa.tar.gz new/repos
cp Ubuntu-14.04-x86_64.iso new/repos
cp CentOS-7-x86_64-Minimal-1503-01.iso new/repos
cp centos_7_1_common_ppa_repo.tar.gz new/repos
cp centos_7_1_openstack_juno_ppa_repo.tar.gz new/repos
cp loaders.tar.gz new
wget -O new/guestimg/cirros-0.3.3-x86_64-disk.img $PACKAGE_URL/cirros-0.3.3-x86_64-disk.img
wget -O new/pip/pexpect-3.3.tar.gz https://pypi.python.org/packages/source/p/pexpect/pexpect-3.3.tar.gz#md5=0de72541d3f1374b795472fed841dce8

cd new/compass
git clone ${COMPASS_CORE}
git clone ${COMPASS_INSTALL}
git clone ${COMPASS_ADAPTERS}
git clone ${COMPASS_WEB}

find . -name ".git" |xargs rm -rf

cd $WORK_DIR
cp -rf $SCRIPT_DIR/ks.cfg new/isolinux/ks.cfg
rm -rf new/.rr_moved
sudo mkisofs -quiet -r -J -R -b isolinux/isolinux.bin  -no-emul-boot -boot-load-size 4 -boot-info-table -hide-rr-moved -x "lost+found:" -o compass.iso new/

# delete tmp file
sudo rm -rf new base trusty-juno-ppa.tar.gz centos_base.iso Ubuntu-14.04-x86_64.iso
