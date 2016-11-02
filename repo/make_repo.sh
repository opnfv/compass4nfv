#!/bin/bash
##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################
#set -ex

REPO_PATH=$(cd "$(dirname "$0")"; pwd)
COMPASS_PATH=$(cd "$(dirname "$0")"/..; pwd)

#source $REPO_PATH/repo.conf
source $REPO_PATH/repo_func.sh

function param_process()
{
    if [ ! -z "$1" ]; then
        case $1 in
            openstack)
                export MAKE_OPENSTACK="true"
                ;;
            pip)
                export MAKE_PIP="true"
                ;;
            feature)
                export MAKE_FEATURE="true"
                ;;
            jumphost)
                export MAKE_JH="true"
                ;;
            compass)
                export MAKE_COMPASS="true"
                ;;
            all)
                export MAKE_ALL="true"
                ;;
            help)
                usage
                exit
                ;;
            *)
                echo "'$1' is not a valid parameter."
                usage
                exit
                ;;
        esac

    else
        echo "Please add a valid parameter!"
        usage
        exit
    fi
}

function usage()
{
    echo 'Usage: ./repo/make_repo.sh [option]'
    echo 'All the valid options are:
    openstack     Make OpenStack PPA.
    pip           Make pip package.
    feature       Make feature project package, such as SDN, Moon, KVM, etc.
    jumphost      Make jumphost preparasion package.
    compass       Make compass VM package.
    all           Make all packages.
    help          Show usage.'
}

function main()
{
    process_env

    if [[ $MAKE_OPENSTACK == "true" ]]; then
        make_osppa
    fi

    if [[ $MAKE_PIP == "true" ]]; then
#        make_repo --package-tag pip
        make_pip_repo
    fi

    if [[ $MAKE_FEATURE == "true" ]]; then
#        make_repo --package-tag feature
        make_feature_repo
    fi

    if [[ $MAKE_JH == "true" ]]; then
        make_jhenv_repo
    fi

    if [[ $MAKE_COMPASS == "true" ]]; then
        make_compass_repo
    fi

    if [[ $MAKE_ALL == "true" ]]; then
        make_osppa
        make_pip_repo
        make_feature_repo
        make_jhenv_repo
        make_compass_repo
    fi

}

param_process "$@"

main
