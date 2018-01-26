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

#avoid locale issue on some environment
export LC_ALL=en_US.UTF-8

COMPASS_PATH=`cd ${BASH_SOURCE[0]%/*};pwd`
WORK_DIR=$COMPASS_PATH/work/building
export CACHE_DIR=$WORK_DIR/cache

COMPASS_ARCH=$(uname -m)

echo $COMPASS_PATH

REDHAT_REL=${REDHAT_REL:-"false"}

PACKAGES="curl python-pip"

mkdir -p $WORK_DIR $CACHE_DIR

function install_docker_ubuntu()
{
    REPO_ARCH=amd64
    if [ "$COMPASS_ARCH" = "aarch64" ]; then
        REPO_ARCH=arm64
    fi

    sudo apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual
    sudo apt-get install -y apt-transport-https ca-certificates curl \
                 software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo apt-key fingerprint 0EBFCD88
    sudo add-apt-repository    "deb [arch=$REPO_ARCH] https://download.docker.com/linux/ubuntu \
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
    sudo docker version >/dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        if [[ $REDHAT_REL == false ]]; then
            install_docker_ubuntu
        else
            install_docker_redhat
        fi
    fi

    for i in $PACKAGES; do
        if [[ $REDHAT_REL == false ]]; then
            if ! apt --installed list 2>/dev/null |grep "\<$i\>"
            then
                sudo apt-get install  -y --force-yes  $i
            fi
            sudo pip install pyyaml
        fi
        if [[ $REDHAT_REL == true ]]; then
            sudo yum install $i -y
        fi
        sudo pip install pyyaml
    done
    set -e
}

function download_packages()
{
    build_yaml_file=build.yaml
    if [ -f "$COMPASS_PATH/build/build-$COMPASS_ARCH.yaml" ]; then
        build_yaml_file=build-$COMPASS_ARCH.yaml
    fi

    python $COMPASS_PATH/build/parser.py $COMPASS_PATH/build/$build_yaml_file
}

function build_tar()
{
    cd $CACHE_DIR
    sudo rm -rf compass_dists
    mkdir -p compass_dists
    sudo cp -f *.tar *.iso compass_dists
    sudo cp $COMPASS_PATH/build/build*.yaml compass_dists
    sudo cp -rf $COMPASS_PATH/util/docker-compose ./
    sudo tar -zcf compass.tar.gz docker-compose compass_dists
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

