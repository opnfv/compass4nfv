#!/bin/bash
##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

####################
set -ex

#COMPASS_PATH=$(cd "$(dirname "$0")"/..; pwd)
COMPASS_PATH=`cd ${BASH_SOURCE[0]%/*};pwd`
WORK_DIR=$COMPASS_PATH/work/building

echo $COMPASS_PATH

# REPO related setting
REPO_PATH=$COMPASS_PATH/repo
WORK_PATH=$COMPASS_PATH

PACKAGES="fuse fuseiso createrepo genisoimage curl"

# PACKAGE_URL will be reset in Jenkins for different branch
export PACKAGE_URL=${PACKAGE_URL:-http://205.177.226.237:9999}

mkdir -p $WORK_DIR

cd $WORK_DIR
function prepare_env()
{
    set +e
    for i in $PACKAGES; do
        if ! apt --installed list 2>/dev/null |grep "\<$i\>"
        then
            sudo apt-get install  -y --force-yes  $i
        fi
    done
    set -e

    if [[ ! -d $CACHE_DIR ]]; then
        mkdir -p $CACHE_DIR
    fi
}

function download_git()
{
    file_dir=$CACHE_DIR/${1%.*}
    if [[ -d $file_dir/.git ]]; then
        cd $file_dir
        source=`git remote -v | head -n 1  | awk '{print $2}'`
        if [[ $2 == $source ]]; then
            git pull origin master
            if [[ $? -eq 0 ]]; then
                cd -
                return
            fi
        fi
        cd -
    fi
    rm -rf $CACHE_DIR/${1%.*}
    git clone $2 $file_dir
}

function download_url()
{
    rm -f $CACHE_DIR/$1.md5
    curl --connect-timeout 10 -o $CACHE_DIR/$1.md5 $2.md5 2>/dev/null
    if [[ -f $CACHE_DIR/$1 ]]; then
        local_md5=`md5sum $CACHE_DIR/$1 | cut -d ' ' -f 1`
        repo_md5=`cat $CACHE_DIR/$1.md5 | cut -d ' ' -f 1`
        if [[ $local_md5 == $repo_md5 ]]; then
            return
        fi
    fi

    curl --connect-timeout 10 -o $CACHE_DIR/$1 $2
}

function download_local()
{
    if [[ $2 != $CACHE_DIR/$1 ]]; then
       cp $2 $CACHE_DIR/ -rf
    fi
}

function download_packages()
{
     for i in $CENTOS_BASE $COMPASS_CORE $COMPASS_WEB $COMPASS_INSTALL \
              $TRUSTY_JUNO_PPA $TRUSTY_LIBERTY_PPA $TRUSTY_MITAKA_PPA $XENIAL_MITAKA_PPA $XENIAL_NEWTON_PPA \
              $UBUNTU_ISO $UBUNTU_ISO1 $REDHAT7_ISO $REDHAT7_OSP9_PPA \
              $CENTOS_ISO $CENTOS7_JUNO_PPA $CENTOS7_KILO_PPA $CENTOS7_LIBERTY_PPA $CENTOS7_MITAKA_PPA \
              $LOADERS $CIRROS $APP_PACKAGE $COMPASS_PKG $PIP_REPO $PIP_OPENSTACK_REPO $ANSIBLE_MODULE; do

         if [[ ! $i ]]; then
             continue
         fi
         name=`basename $i`

         if [[ ${name##*.} == git ]]; then
             download_git  $name $i
         elif [[ "https?" =~ ${i%%:*} || "file://" =~ ${i%%:*} ]]; then
             download_url  $name $i
         else
             download_local $name $i
         fi
     done

}

function copy_file()
{
    new=$1

    # main process
    mkdir -p $new/compass $new/bootstrap $new/pip $new/pip-openstack $new/guestimg $new/app_packages $new/ansible
    mkdir -p $new/repos/cobbler/{ubuntu,centos,redhat}/{iso,ppa}

    rm -rf $new/.rr_moved

    if [[ $UBUNTU_ISO ]]; then
        cp $CACHE_DIR/`basename $UBUNTU_ISO` $new/repos/cobbler/ubuntu/iso/ -rf
    fi

    if [[ $UBUNTU_ISO1 ]]; then
        cp $CACHE_DIR/`basename $UBUNTU_ISO1` $new/repos/cobbler/ubuntu/iso/ -rf
    fi

    if [[  $TRUSTY_JUNO_PPA ]]; then
        cp $CACHE_DIR/`basename $TRUSTY_JUNO_PPA` $new/repos/cobbler/ubuntu/ppa/ -rf
    fi

    if [[  $TRUSTY_LIBERTY_PPA ]]; then
        cp $CACHE_DIR/`basename $TRUSTY_LIBERTY_PPA` $new/repos/cobbler/ubuntu/ppa/ -rf
    fi

    if [[  $TRUSTY_MITAKA_PPA ]]; then
        cp $CACHE_DIR/`basename $TRUSTY_MITAKA_PPA` $new/repos/cobbler/ubuntu/ppa/ -rf
    fi

    if [[  $XENIAL_MITAKA_PPA ]]; then
        cp $CACHE_DIR/`basename $XENIAL_MITAKA_PPA` $new/repos/cobbler/ubuntu/ppa/ -rf
    fi

    if [[  $XENIAL_NEWTON_PPA ]]; then
        cp $CACHE_DIR/`basename $XENIAL_NEWTON_PPA` $new/repos/cobbler/ubuntu/ppa/ -rf
    fi

    if [[ $CENTOS_ISO ]]; then
        cp $CACHE_DIR/`basename $CENTOS_ISO` $new/repos/cobbler/centos/iso/ -rf
    fi

    if [[ $CENTOS7_JUNO_PPA ]]; then
        cp $CACHE_DIR/`basename $CENTOS7_JUNO_PPA` $new/repos/cobbler/centos/ppa/ -rf
    fi

    if [[ $CENTOS7_KILO_PPA ]]; then
        cp $CACHE_DIR/`basename $CENTOS7_KILO_PPA` $new/repos/cobbler/centos/ppa/ -rf
    fi

    if [[ $CENTOS7_LIBERTY_PPA ]]; then
        cp $CACHE_DIR/`basename $CENTOS7_LIBERTY_PPA` $new/repos/cobbler/centos/ppa/ -rf
    fi

    if [[ $CENTOS7_MITAKA_PPA ]]; then
        cp $CACHE_DIR/`basename $CENTOS7_MITAKA_PPA` $new/repos/cobbler/centos/ppa/ -rf
    fi

    if [[ $REDHAT7_ISO ]]; then
        cp $CACHE_DIR/`basename $REDHAT7_ISO` $new/repos/cobbler/redhat/iso/ -rf
    fi

    if [[ $REDHAT7_OSP9_PPA ]]; then
        cp $CACHE_DIR/`basename $REDHAT7_OSP9_PPA` $new/repos/cobbler/redhat/ppa/ -rf
    fi

    cp $CACHE_DIR/`basename $LOADERS` $new/ -rf || exit 1
    cp $CACHE_DIR/`basename $APP_PACKAGE` $new/app_packages/ -rf || exit 1
    cp $CACHE_DIR/`basename $ANSIBLE_MODULE | sed 's/.git//g'`  $new/ansible/ -rf || exit 1

    if [[ $CIRROS ]]; then
        cp $CACHE_DIR/`basename $CIRROS` $new/guestimg/ -rf || exit 1
    fi

    for i in $COMPASS_CORE $COMPASS_INSTALL $COMPASS_WEB; do
        cp $CACHE_DIR/`basename $i | sed 's/.git//g'` $new/compass/ -rf
    done

    cp $COMPASS_PATH/deploy/adapters $new/compass/compass-adapters -rf
    cp $COMPASS_PATH/deploy/compass_conf/* $new/compass/compass-core/conf -rf

    tar -zxvf $CACHE_DIR/`basename $PIP_REPO` -C $new/
    tar -zxvf $CACHE_DIR/`basename $PIP_OPENSTACK_REPO` -C $new/

    find $new/compass -name ".git" | xargs rm -rf
}

function rebuild_ppa()
{
    name=`basename $COMPASS_PKG`
    rm -rf ${name%%.*} $name
    cp $CACHE_DIR/$name $WORK_DIR
    cp $COMPASS_PATH/repo/openstack/make_ppa/centos/comps.xml $WORK_DIR
    tar -zxvf $name
    cp ${name%%.*}/*.rpm $1/Packages -f
    rm -rf $1/repodata/*
    createrepo -g $WORK_DIR/comps.xml $1
}

function make_iso()
{
    download_packages
    name=`basename $CENTOS_BASE`
    cp  $CACHE_DIR/$name ./ -f
    # mount base iso
    mkdir -p base new
    fuseiso $name base
    cd base;find .|cpio -pd ../new ;cd -
    fusermount -u base
    chmod 755 ./new -R

    copy_file new
    rebuild_ppa new

    mkisofs -quiet -r -J -R -b isolinux/isolinux.bin \
            -no-emul-boot -boot-load-size 4 \
            -boot-info-table -hide-rr-moved \
            -x "lost+found:" \
            -o compass.iso new/

    md5sum compass.iso > compass.iso.md5

    # delete tmp file
    rm -rf new base $name
}

function process_param()
{
    TEMP=`getopt -o c:d:f:s:t: --long iso-dir:,iso-name:,cache-dir:,openstack_build:,feature_build:,feature_version: -n 'build.sh' -- "$@"`

    if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

    eval set -- "$TEMP"

    while :; do
        case "$1" in
            -d|--iso-dir) export ISO_DIR=$2; shift 2;;
            -f|--iso-name) export ISO_NAME=$2; shift 2;;
            -c|--cache-dir) export CACHE_DIR=$2; shift 2;;
            -s|--openstack_build) export OPENSTACK_BUILD=$2; shift 2;;
            -t|--feature_build) export FEATURE_BUILD=$2; shift 2;;
            -v|--feature_version) export FEATURE_VERSION=$2; shift 2;;
            --) shift; break;;
            *) echo "Internal error!" ; exit 1 ;;
        esac
    done

    export CACHE_DIR=${CACHE_DIR:-$WORK_DIR/cache}
    export ISO_DIR=${ISO_DIR:-$WORK_DIR}
    export ISO_NAME=${ISO_NAME:-"compass.iso"}
    export OPENSTACK_BUILD=${OPENSTACK_BUILD:-"stable"}
    export FEATURE_BUILD=${FEATURE_BUILD:-"stable"}
#    export FEATURE_VERSION=${FEATURE_VERSION:-"colorado"}
}

function copy_iso()
{
   if [[ $ISO_DIR/$ISO_NAME == $WORK_DIR/compass.iso ]]; then
      return
   fi

   cp $WORK_DIR/compass.iso $ISO_DIR/$ISO_NAME -f
}

# get daily repo or stable repo
function get_repo_pkg()
{
   source $COMPASS_PATH/repo/repo_func.sh

   # switch to compass4nfv directory
   cd $COMPASS_PATH

   # set openstack ppa url
   if [[ $OPENSTACK_BUILD == daily ]]; then
       process_env
       make_osppa
       export PPA_URL=${PPA_URL:-$COMPASS_PATH/work/repo}
   else
       export PPA_URL=${PPA_URL:-$PACKAGE_URL}
   fi

   # set feature pkg url
   if [[ $FEATURE_BUILD == daily ]]; then
       process_env
       make_repo --package-tag feature

###TODO should the packages.tar.gz include all the packages from different OPNFV versions?

       export FEATURE_URL=${FEATURE_URL:-$COMPASS_PATH/work/repo}
   else
       export FEATURE_URL=${FEATURE_URL:-$PACKAGE_URL}
   fi

   source $COMPASS_PATH/build/build.conf

   # switch to building directory
   cd $WORK_DIR
}
process_param $*
prepare_env
get_repo_pkg
make_iso
copy_iso
