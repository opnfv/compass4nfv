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
            *)
                echo "'$1' is not a valid parameter."
                return
                ;;
        esac

    else
        export MAKE_ALL="true"
    fi
}

function main()
{
    process_env

    if [[ $MAKE_OPENSTACK == "true" ]]; then
        make_osppa
    fi

    if [[ $MAKE_PIP == "true" ]]; then
        make_repo --package-tag pip
    fi

    if [[ $MAKE_FEATURE == "true" ]]; then
        make_repo --package-tag feature
    fi

    if [[ $MAKE_JH == "true" ]]; then
        for env_os in trusty; do
        make_repo --package-tag jhenv --jh-os $env_os
        done
    fi

    if [[ $MAKE_COMPASS == "true" ]]; then
        make_repo --os-ver rhel7 --package-tag compass \
                  --tmpl "${REPO_PATH}/openstack/make_ppa/centos/rhel7/compass/compass_core.tmpl" \
                  --default-package "kernel-devel epel-release wget libxml2 glibc gcc perl openssl-libs mkisofs createrepo lsof \
                                     python-yaml python-jinja2 python-paramiko elasticsearch logstash bind-license vim nmap-ncat \
                                     yum cobbler cobbler-web createrepo mkisofs syslinux pykickstart bind rsync fence-agents \
                                     dhcp xinetd tftp-server httpd libselinux-python python-setuptools python-devel mysql-devel \
                                     mysql-server mysql MySQL-python redis mod_wsgi net-tools rabbitmq-server nfs-utils" \
                  --special-package "kibana jdk"
    fi

    if [[ $MAKE_ALL == "true" ]]; then
       make_all_repo
    fi


#    if [[ $# -eq 0 ]]; then
#        make_all_repo
#    else
#        make_repo "$@"
#    fi
}

#main "$@"
param_process "$@"

main
