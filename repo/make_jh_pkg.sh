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
WORK_PATH=$(cd "$(dirname "$0")"/..; pwd)

function env_prepare()
{
    mkdir -p ${WORK_PATH}/work/repo/

    set +e
    sudo docker info
    if [[ $? != 0 ]]; then
        wget -qO- https://get.docker.com/ | sh
    else
        echo "docker is already installed!"
    fi
    set -e

    sudo apt-get -f install
    sudo apt-get install python-yaml -y
    sudo apt-get install python-cheetah -y
}

function make_repo()
{
    option=`echo "jh-os:,package-tag:" | sed 's/ //g'`

    TEMP=`getopt -o h -l $option -n 'make_jh_pkg.sh' -- "$@"`

    if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

    eval set -- "$TEMP"

    jh_os=""
    package_tag=""

    while :; do
        case "$1" in
            --jh-os) jh_os=$2; shift 2;;
            --package-tag) package_tag=$2; shift 2;;
            --) shift; break;;
            *) echo "Internal error! $1" ; exit 1 ;;
        esac
    done

    if [[ -n ${package_tag} && ${package_tag} == "jhenv" && -n ${jh_os} ]]; then
        make_jhenv_repo
        return
    fi
}

function make_jhenv_repo()
{
    if [[ ${jh_os} == trusty ]]; then
        env_os_name=ubuntu
    fi

    if [[ ${jh_os} == xenial ]]; then
        env_os_name=ubuntu
    fi

    if [[ ${jh_os} =~ rhel[0-9]*$ ]]; then
        env_os_name=centos
    fi

    if [[ -d ${WORK_PATH}/repo/jhenv_template/$env_os_name ]]; then

        jh_env_dockerfile=Dockerfile
        jh_env_docker_tmpl=${REPO_PATH}/jhenv_template/$env_os_name/$jh_os/${jh_env_dockerfile}".tmpl"
        jh_env_docker_tag="$jh_os/env"

        rm -rf ${WORK_PATH}/work/repo/jhenv_template
        mkdir ${WORK_PATH}/work/repo/jhenv_template
        cp -rf ${WORK_PATH}/repo/jhenv_template/$env_os_name/$jh_os/${jh_env_dockerfile} ${WORK_PATH}/work/repo/jhenv_template

cat <<EOF >${WORK_PATH}/work/repo/jhenv_template/cp_env.sh
#!/bin/bash
set -ex
cp /*.tar.gz /env -f
EOF

        sudo docker build --no-cache=true -t ${jh_env_docker_tag} -f ${WORK_PATH}/work/repo/jhenv_template/${jh_env_dockerfile} ${WORK_PATH}/work/repo/jhenv_template
        sudo docker run -t -v ${WORK_PATH}/work/repo:/env ${jh_env_docker_tag}

        image_id=$(sudo docker images|grep ${jh_env_docker_tag}|awk '{print $3}')

        sudo docker rmi -f ${image_id}

#    cd $WORK_PATH/work/repo; tar -zcvf pip.tar.gz ./pip; cd -
    fi
}

function main()
{
    env_prepare

    for env_os in trusty xanial; do
    make_repo --package-tag jhenv --jh-os $env_os
    done
}

main

