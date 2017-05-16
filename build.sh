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
#COMPASS_PATH=$(cd "$(dirname "$0")"/..; pwd)
BUILD_IMAGES=${BUILD_IMAGES:-"false"}

COMPASS_PATH=`cd ${BASH_SOURCE[0]%/*};pwd`
WORK_DIR=$COMPASS_PATH/work/building
CACHE_DIR=$WORK_DIR/cache

echo $COMPASS_PATH

# REPO related setting
REPO_PATH=$COMPASS_PATH/repo
WORK_PATH=$COMPASS_PATH

PACKAGES="docker curl"

# PACKAGE_URL will be reset in Jenkins for different branch
export PACKAGE_URL=${PACKAGE_URL:-http://192.168.104.2:9999/download}

mkdir -p $WORK_DIR $CACHE_DIR

source $COMPASS_PATH/build/build.conf
#cd $WORK_DIR

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
    curl --connect-timeout 10 -o $CACHE_DIR/$1.md5 $2.md5 2>/dev/null || true
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
    for i in $PIP_OPENSTACK_REPO $APP_PACKAGE $COMPASS_MQ \
             $COMPASS_DECK $COMPASS_TASKS $COMPASS_COBBLER $COMPASS_DB $COMPASS_COMPOSE \
             $UBUNTU_ISO $CENTOS_ISO $XENIAL_NEWTON_PPA $CENTOS7_NEWTON_PPA; do

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

function build_docker()
{
    for i in $COMPASS_DECK $COMPASS_TASKS $COMPASS_COBBLER $COMPASS_DB; do
        REPO_NAME=${i##*/}
        REPO_DIR=${REPO_NAME%.*}
        DOCKER_TAG="localbuild/$REPO_DIR"

        cd $CACHE_DIR/$REPO_DIR
        old_dockers=`docker ps -a | grep "build-$REPO_DIR" | awk '{print $1}'`
        if [ -n "$old_dockers" ]; then
            docker rm -f $old_dockers
        fi

        if [[ "$BUILD_IMAGES" == "true" ]]; then
            old_imgs=`docker images | grep $DOCKER_TAG | awk '{print $3}'`
            if [ -n "$old_imgs" ]; then
                docker rmi -f $old_imgs
            fi
            docker build --no-cache=true  -f Dockerfile ./ -t $DOCKER_TAG
        fi
        cd -

        docker run -itd --name "build-$REPO_DIR" $DOCKER_TAG bash
    done
}

function copy_file()
{
    docker cp $COMPASS_PATH/deploy/status_callback.py \
              build-compass-deck:/root/compass-deck/bin/ansible_callbacks
    docker cp $COMPASS_PATH/deploy/playbook_done.py \
              build-compass-deck:/root/compass-deck/bin/ansible_callbacks

    docker exec build-compass-tasks bash -c "mkdir -p /opt/ansible_callbacks"

    docker cp $COMPASS_PATH/deploy/status_callback.py \
              build-compass-tasks:/opt/ansible_callbacks
    docker cp $COMPASS_PATH/deploy/playbook_done.py \
              build-compass-tasks:/opt/ansible_callbacks

    ADAPTERS_DIR=$COMPASS_PATH/deploy/adapters

    for i in `ls $ADAPTERS_DIR/ansible | grep "openstack_"`; do
        cp -rf $ADAPTERS_DIR/ansible/openstack/* $ADAPTERS_DIR/ansible/$i
    done

    docker cp $ADAPTERS_DIR/ansible/ build-compass-tasks:/root/
    docker exec build-compass-tasks bash -c \
    "cp -rf /root/ansible/ansible_modules /opt"

    docker cp $ADAPTERS_DIR/cobbler/ build-compass-cobbler:/root/
    docker exec build-compass-cobbler bash -c \
    "cp -f /root/cobbler/conf/* /etc/cobbler"

    cd $COMPASS_PATH/deploy/compass_conf
    copy_conf=`ls -F | grep '/$'`
    for i in $copy_conf; do
        docker cp $i build-compass-deck:/etc/compass
        docker cp $i build-compass-tasks:/etc/compass
    done
    cd -
}

function save_image()
{
    docker commit `docker ps | grep build-compass-deck | awk '{print $1}'` \
    opnfv/compass-deck
    docker commit `docker ps | grep build-compass-tasks | awk '{print $1}'` \
    opnfv/compass-tasks
    docker commit `docker ps | grep build-compass-cobbler | awk '{print $1}'` \
    opnfv/compass-cobbler
    docker commit `docker ps | grep build-compass-db | awk '{print $1}'` \
    opnfv/compass-db

    docker save opnfv/compass-deck -o $CACHE_DIR/compass-deck.tar
    docker save opnfv/compass-tasks -o $CACHE_DIR/compass-tasks.tar
    docker save opnfv/compass-cobbler -o $CACHE_DIR/compass-cobbler.tar
    docker save opnfv/compass-db -o $CACHE_DIR/compass-db.tar
}

function build_tar()
{
    cd $CACHE_DIR
    mkdir -p compass_dists
    cp -f `basename $PIP_OPENSTACK_REPO` `basename $APP_PACKAGE` \
    `basename $UBUNTU_ISO` `basename $CENTOS_ISO` \
    `basename $XENIAL_NEWTON_PPA` `basename $CENTOS7_NEWTON_PPA` \
    compass-deck.tar compass-tasks.tar compass-cobbler.tar compass-db.tar \
    compass-mq.tar compass_dists
    tar -zcf compass.tar.gz compass-docker-compose compass_dists
    mv compass.tar.gz ../
    cd -
}

function rebuild_ppa()
{
    name=`basename $COMPASS_PKG`
    rm -rf ${name%%.*} $name
    cp $WORK_DIR/$name $WORK_DIR
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
    cp  $WORK_DIR/$name ./ -f
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
            -c|--cache-dir) export WORK_DIR=$2; shift 2;;
            -s|--openstack_build) export OPENSTACK_BUILD=$2; shift 2;;
            -t|--feature_build) export FEATURE_BUILD=$2; shift 2;;
            -v|--feature_version) export FEATURE_VERSION=$2; shift 2;;
            --) shift; break;;
            *) echo "Internal error!" ; exit 1 ;;
        esac
    done

    export WORK_DIR=${WORK_DIR:-$WORK_DIR/cache}
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
download_packages
build_docker
copy_file
save_image
build_tar
