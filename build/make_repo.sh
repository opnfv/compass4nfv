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

BUILD_PATH=$(cd "$(dirname "$0")"; pwd)
WORK_PATH=$(cd "$(dirname "$0")"/..; pwd)

source $BUILD_PATH/build.conf

function process_env()
{
    mkdir -p ${WORK_PATH}/work/repo/ ${WORK_PATH}/work/repo/pip

    set +e
    sudo docker info
    if [[ $? != 0 ]]; then
        wget -qO- https://get.docker.com/ | sh
    else
        echo "docker is already installed!"
    fi
    set -e

cat <<EOF >${WORK_PATH}/work/repo/cp_repo.sh
#!/bin/bash
set -ex
cp /*.tar.gz /result -f
EOF

    sudo apt-get -f install
    sudo apt-get install python-yaml -y
    sudo apt-get install python-cheetah -y
}

function make_repo()
{
    rm -f ${WORK_PATH}/work/repo/install_packages.sh
    rm -f ${WORK_PATH}/work/repo/Dockerfile

    option=`echo "os-ver:,jh-os:,package-tag:,tmpl:,default-package:, \
            special-package:,special-package-script-dir:, \
            special-package-dir:,ansible-dir:,special-package-dir" | sed 's/ //g'`

    TEMP=`getopt -o h -l $option -n 'make_repo.sh' -- "$@"`

    if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

    eval set -- "$TEMP"

    os_ver=""
    jh_os=""
    package_tag=""
    tmpl=""
    default_package=""
    special_package=""
    special_package_script_dir=""
    special_package_dir=""
    ansible_dir=""
    ansible_dir_tmp=""
    while :; do
        case "$1" in
            --os-ver) os_ver=$2; shift 2;;
            --jh-os) jh_os=$2; shift 2;;
            --package-tag) package_tag=$2; shift 2;;
            --tmpl) tmpl=$2; shift 2;;
            --default-package) default_package=$2; shift 2;;
            --special-package) special_package=$2; shift 2;;
            --special-package-script-dir) special_package_script_dir=$2; shift 2;;
            --special-package-dir) special_package_dir=$2; shift 2;;
            --ansible-dir) ansible_dir=$2; shift 2;;
            --) shift; break;;
            *) echo "Internal error! $1" ; exit 1 ;;
        esac
    done

    if [[ -n ${package_tag} && ${package_tag} == "pip" ]]; then
        make_pip_repo
        return
    fi

    if [[ -n ${package_tag} && ${package_tag} == "jhenv" && -n ${jh_os} ]]; then
        make_jhenv_repo
        return
    fi

    if [[ -z ${os_ver} || -z ${package_tag} ]]; then
        echo "parameter is wrong"
        exit 1
    fi

    if [[ ${os_ver} == trusty || ${os_ver} == xenial ]]; then
        arch=Debian
        os_name=ubuntu
    fi

    if [[ ${os_ver} =~ rhel[0-9]*$ ]]; then
        arch=RedHat
        os_name=centos
    fi

    if [[ -z $arch ]]; then
        echo "unsupported ${os_ver} os"
        exit 1
    fi

    dockerfile=Dockerfile
    docker_tmpl=${BUILD_PATH}/os/${os_name}/${os_ver}/${package_tag}/${dockerfile}".tmpl"
    docker_tag="${os_ver}/${package_tag}"

    if [[ -z ${tmpl} ]]; then
        if [[ ${os_ver} == xenial ]]; then
            tmpl=${BUILD_PATH}/templates/${arch}_${os_ver}_${package_tag}.tmpl
        else
            tmpl=${BUILD_PATH}/templates/${arch}_${package_tag}.tmpl
        fi
    fi

    if [[ "${ansible_dir}" != "" ]]; then
        # generate ansible_dir_tmp
        if [[ -d ${WORK_PATH}/work/tmp ]]; then
            rm -rf ${WORK_PATH}/work/tmp
        fi
        mkdir -p ${WORK_PATH}/work/tmp
        echo "${ansible_dir}"
        cp -rf ${ansible_dir}/roles/ ${WORK_PATH}/work/tmp/
        if [[ ${os_ver} == xenial ]]; then
            if [[ -d ${ansible_dir}/openstack_${package_tag}/roles && "`ls ${ansible_dir}/openstack_${package_tag}`" != "" ]]; then
                cp -rf ${ansible_dir}/openstack_${package_tag}_${os_ver}/roles/* ${WORK_PATH}/work/tmp/roles/
            fi
        else
            if [[ -d ${ansible_dir}/openstack_${package_tag}/roles && "`ls ${ansible_dir}/openstack_${package_tag}`" != "" ]]; then
                cp -rf ${ansible_dir}/openstack_${package_tag}/roles/* ${WORK_PATH}/work/tmp/roles/
            fi
        fi
        ansible_dir_tmp=${WORK_PATH}/work/tmp/
    fi

    python ${BUILD_PATH}/gen_ins_pkg_script.py "${ansible_dir_tmp}" "${arch}" "${tmpl}" \
          "${docker_tmpl}" "${default_package}" "${special_package}" \
          "${WORK_PATH}/work/repo/$arch/script/" \
          "${WORK_PATH}/work/repo/$arch/packages/"

    rm -rf ${WORK_PATH}/work/repo/$arch
    mkdir -p ${WORK_PATH}/work/repo/$arch/{script,packages}

    # copy default package script to wokr dir
    if [[ -d ${WORK_PATH}/build/arch/$arch ]]; then
        cp -rf ${WORK_PATH}/build/arch/$arch/* ${WORK_PATH}/work/repo/$arch/script/
    fi

    # copy make package script to work dir
    if [[ -n $special_package_script_dir && -d $special_package_script_dir ]]; then
        cp -rf $special_package_script_dir/*  ${WORK_PATH}/work/repo/$arch/script/
    fi

    # copy special package to work dir
    if [[ -n $special_package_dir ]]; then
        curl --connect-timeout 10 -o $WORK_PATH/work/repo/$arch/`basename $special_package_dir` $special_package_dir
        tar -zxvf $WORK_PATH/work/repo/$arch/`basename $special_package_dir` -C ${WORK_PATH}/work/repo/$arch/packages
    fi

    # copy docker file to work dir
    if [[ -n $os_ver && -d ${WORK_PATH}/build/os/$os_name/$os_ver ]]; then
        rm -rf ${WORK_PATH}/work/repo/$os_ver
        cp -rf ${WORK_PATH}/build/os/$os_name/$os_ver ${WORK_PATH}/work/repo
    fi

    # copy centos comps.xml to work dir
    if [[ $arch == RedHat && -f ${WORK_PATH}/build/os/$os_name/comps.xml ]]; then
        cp -rf ${WORK_PATH}/build/os/$os_name/comps.xml ${WORK_PATH}/work/repo
        cp -rf ${WORK_PATH}/build/os/$os_name/ceph_key_release.asc ${WORK_PATH}/work/repo
    fi

    sudo docker build --no-cache=true -t ${docker_tag} -f ${WORK_PATH}/work/repo/${dockerfile} ${WORK_PATH}/work/repo/
    sudo docker run -t -v ${WORK_PATH}/work/repo:/result ${docker_tag}

    image_id=$(sudo docker images|grep ${docker_tag}|awk '{print $3}')

    sudo docker rmi -f ${image_id}
}

function _try_fetch_dependency()
{
    local dir_name=''
    if [ -f $1 ];then
        case $1 in
            *.tar.bz2)
                tar xjf $1
                dir_name="$(basename $1 .tar.bz2)"
                ;;
            *.tar.gz)
                tar xzf $1
                dir_name="$(basename $1 .tar.gz)"
                ;;
            *.bz2)
                bunzip2 $1
                dir_name="$(basename $1 .bz2)"
                ;;
            *.rar)
                unrar e $1
                dir_name="$(basename $1 .rar)"
                ;;
            *.gz)
                gunzip $1
                dir_name="$(basename $1 .gz)"
                ;;
            *.tar)
                tar xf $1
                dir_name="$(basename $1 .tar)"
                ;;
            *.tbz2)
                tar xjf $1
                dir_name="$(basename $1 .tbz2)"
                ;;
            *.tgz)
                tar xzf $1
                dir_name="$(basename $1 .tgz)"
                ;;
            *.zip)
                gunzip $1
                dir_name="$(basename $1 .zip)"
                ;;
            *)
                echo "'$1' cannot be extract()"
                return
                ;;
        esac
    else
        echo "'$1' is not a valid file"
        return
    fi

    if [ ! -f ${dir_name}/requirements.txt ]; then
        echo "${dir_name}/requirements.txt does not exist"
        return
    fi

    pip install --download=$2 -r ${dir_name}/requirements.txt

    rm -rf $dir_name
}

function try_fetch_dependency()
{
    cd $3
    _try_fetch_dependency $1/$2 $1
    cd -
}

function make_pip_repo()
{
    source $WORK_PATH/build/build.conf
    local pip_path=$WORK_PATH/work/repo/pip
    local pip_tmp_path=$WORK_PATH/work/repo/pip_tmp

    for i in $SPECIAL_PIP_PACKAGE; do
        curl --connect-timeout 10 -o $pip_path/`basename $i` $i
    done

    mkdir -p $pip_tmp_path

    for i in $PIP_PACKAGE; do
        curl --connect-timeout 10 -o $pip_path/$(basename $i) $i
        try_fetch_dependency $pip_path $(basename $i) $pip_tmp_path
    done

    rm -rf $pip_tmp_path

    cd $WORK_PATH/work/repo; tar -zcvf pip.tar.gz ./pip; cd -
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

    if [[ -d ${WORK_PATH}/build/jhenv_template/$env_os_name ]]; then

        jh_env_dockerfile=Dockerfile
        jh_env_docker_tmpl=${BUILD_PATH}/jhenv_template/$env_os_name/$jh_os/${jh_env_dockerfile}".tmpl"
        jh_env_docker_tag="$jh_os/env"

        rm -rf ${WORK_PATH}/work/repo/jhenv_template
        mkdir ${WORK_PATH}/work/repo/jhenv_template
        cp -rf ${WORK_PATH}/build/jhenv_template/$env_os_name/$jh_os/${jh_env_dockerfile} ${WORK_PATH}/work/repo/jhenv_template

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

function make_all_repo()
{
    for env_os in trusty xanial rhel7; do
    make_repo --package-tag jhenv --jh-os $env_os
    done

    make_repo --package-tag pip

    make_repo --os-ver rhel7 --package-tag compass \
              --tmpl "${WORK_PATH}/build/templates/compass_core.tmpl" \
              --default-package "kernel-devel epel-release wget libxml2 glibc gcc perl openssl-libs mkisofs createrepo lsof \
                                 python-yaml python-jinja2 python-paramiko elasticsearch logstash bind-license vim nmap-ncat \
                                 yum cobbler cobbler-web createrepo mkisofs syslinux pykickstart bind rsync fence-agents \
                                 dhcp xinetd tftp-server httpd libselinux-python python-setuptools python-devel mysql-devel \
                                 mysql-server mysql MySQL-python redis mod_wsgi net-tools rabbitmq-server nfs-utils" \
              --special-package "kibana jdk"

    for opv in juno kilo liberty mitaka; do
    make_repo --os-ver trusty --package-tag $opv \
              --ansible-dir $WORK_PATH/deploy/adapters/ansible \
              --default-package "openssh-server" \
              --special-package "openvswitch-switch"
    done
 
    make_repo --os-ver xenial --package-tag mitaka \
              --ansible-dir $WORK_PATH/deploy/adapters/ansible \
              --default-package "openssh-server"

    make_repo --os-ver rhel7 --package-tag juno \
              --ansible-dir $WORK_PATH/deploy/adapters/ansible \
              --default-package "rsyslog-7.6.7-1.el7 strace net-tools wget vim openssh-server \
                                 dracut-config-rescue-033-241.el7_1.3 dracut-network-033-241.el7_1.3"

    for opv in kilo liberty mitaka; do
    make_repo --os-ver rhel7 --package-tag $opv \
              --ansible-dir $WORK_PATH/deploy/adapters/ansible \
              --default-package "rsyslog-7.6.7-1.el7 strace net-tools wget vim openssh-server \
                                 dracut-config-rescue-033-241.el7_1.5 dracut-network-033-241.el7_1.5"
    done
}

function main()
{
    process_env

    if [[ $# -eq 0 ]]; then
        make_all_repo
    else
        make_repo "$@"
    fi
}

main "$@"
