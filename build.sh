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

REDHAT_REL=${REDHAT_REL:-"false"}

PACKAGES="curl"

mkdir -p $WORK_DIR $CACHE_DIR

source $COMPASS_PATH/build/build.conf
#cd $WORK_DIR

function install_docker_ubuntu()
{
    sudo apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual
    sudo apt-get install -y apt-transport-https ca-certificates curl \
                 software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo apt-key fingerprint 0EBFCD88
    sudo add-apt-repository    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce

    sudo service docker start
    sudo service docker restart
}

function install_docker_redhat()
{
    echo "TODO"
    exit 1
}

function prepare_env()
{
    if [[ -f /etc/redhat-release ]]; then
        REDHAT_REL=true
    fi

    set +e
    if [[ $REDHAT_REL == false ]]; then
        install_docker_ubuntu
    else
        install_docker_redhat
    fi

    for i in $PACKAGES; do
        if [[ $REDHAT_REL == false ]]; then
            if ! apt --installed list 2>/dev/null |grep "\<$i\>"
            then
                sudo apt-get install  -y --force-yes  $i
            fi
        fi
        if [[ $REDHAT_REL == true ]]; then
            sudo yum install $i -y
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

function download_docker_images()
{
    for i in $COMPASS_DECK $COMPASS_TASKS $COMPASS_COBBLER \
             $COMPASS_DB $COMPASS_MQ; do
        basename=`basename $i`
        sudo docker pull $i
        sudo docker save $i -o $CACHE_DIR/${basename%:*}.tar
    done
}

function download_packages()
{
    for i in $PIP_OPENSTACK_REPO $APP_PACKAGE $COMPASS_COMPOSE \
             $UBUNTU_ISO $CENTOS_ISO $UBUNTU_PPA $CENTOS_PPA; do

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

    download_docker_images
}

function build_tar()
{
    cd $CACHE_DIR
    sudo rm -rf compass_dists
    mkdir -p compass_dists
    sudo cp -f `basename $PIP_OPENSTACK_REPO` `basename $APP_PACKAGE` \
    `basename $UBUNTU_ISO` `basename $CENTOS_ISO` \
    `basename $UBUNTU_PPA` `basename $CENTOS_PPA` \
    compass-deck.tar compass-tasks-osa.tar compass-cobbler.tar \
    compass-db.tar compass-mq.tar compass_dists
    sudo tar -zcf compass.tar.gz compass-docker-compose compass_dists
    sudo mv compass.tar.gz $TAR_DIR/$TAR_NAME
    cd -
}

function process_param()
{
    TEMP=`getopt -o c:d:f:s:t: --long tar-dir:,tar-name:,cache-dir:,openstack_build:,feature_build:,feature_version: -n 'build.sh' -- "$@"`

    if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

    eval set -- "$TEMP"

    while :; do
        case "$1" in
            -d|--tar-dir) export TAR_DIR=$2; shift 2;;
            -f|--tar-name) export TAR_NAME=$2; shift 2;;
            -c|--cache-dir) export WORK_DIR=$2; shift 2;;
            -s|--openstack_build) export OPENSTACK_BUILD=$2; shift 2;;
            -t|--feature_build) export FEATURE_BUILD=$2; shift 2;;
            -v|--feature_version) export FEATURE_VERSION=$2; shift 2;;
            --) shift; break;;
            *) echo "Internal error!" ; exit 1 ;;
        esac
    done

    export WORK_DIR=${WORK_DIR:-$WORK_DIR/cache}
    export TAR_DIR=${TAR_DIR:-$WORK_DIR}
    export TAR_NAME=${TAR_NAME:-"compass.tar.gz"}
    export OPENSTACK_BUILD=${OPENSTACK_BUILD:-"stable"}
    export FEATURE_BUILD=${FEATURE_BUILD:-"stable"}
#    export FEATURE_VERSION=${FEATURE_VERSION:-"colorado"}
}

process_param $*
prepare_env
download_packages
build_tar
