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

    sudo apt-get install python-yaml -y
    sudo apt-get install python-cheetah -y
}

function make_repo()
{
    rm -f ${WORK_PATH}/work/repo/install_packages.sh
    rm -f ${WORK_PATH}/work/repo/Dockerfile

    option=`echo "os-ver:,package-tag:,tmpl:,default-package:, \
            special-package:,special-package-script-dir:, \
            special-package-dir:,ansible-dir:,special-package-dir" | sed 's/ //g'`

    TEMP=`getopt -o h -l $option -n 'make_repo.sh' -- "$@"`

    if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

    eval set -- "$TEMP"

    os_ver=""
    package_tag=""
    tmpl=""
    default_package=""
    special_package=""
    special_package_script_dir=""
    special_package_dir=""
    ansible_dir=""
    while :; do
        case "$1" in
            --os-ver) os_ver=$2; shift 2;;
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

    if [[ -z ${os_ver} || -z ${package_tag} ]]; then
        echo "parameter is wrong"
        exit 1
    fi

    if [[ ${os_ver} == trusty ]]; then
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
        tmpl=${BUILD_PATH}/templates/${arch}_${package_tag}.tmpl
    fi

    python ${BUILD_PATH}/gen_ins_pkg_script.py "${ansible_dir}" "${arch}" "${tmpl}" \
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

function make_pip_repo()
{
    source $WORK_PATH/build/build.conf

    if [[ $PIP_CONF == "" ]]; then
        return
    fi

    for i in $PIP_CONF; do
        curl --connect-timeout 10 -o $WORK_PATH/work/repo/pip/`basename $i` $i
    done

    cd $WORK_PATH/work/repo; tar -zcvf pip.tar.gz ./pip; cd -
}

function make_all_repo()
{
#    make_repo --package-tag pip

#    make_repo --os-ver rhel7 --package-tag compass \
#              --tmpl "${WORK_PATH}/build/templates/compass_core.tmpl" \
#              --default-package "kernel-devel epel-release wget libxml2 glibc gcc perl openssl-libs mkisofs createrepo lsof \
#                                 python-yaml python-jinja2 python-paramiko elasticsearch logstash bind-license vim nmap-ncat \
#                                 yum cobbler cobbler-web createrepo mkisofs syslinux pykickstart bind rsync fence-agents \
#                                 dhcp xinetd tftp-server httpd libselinux-python python-setuptools python-devel mysql-devel \
#                                 mysql-server mysql MySQL-python redis mod_wsgi net-tools rabbitmq-server nfs-utils" \
#              --special-package "kibana jdk"

    for opv in juno kilo liberty; do
    make_repo --os-ver trusty --package-tag $opv \
              --ansible-dir $WORK_PATH/deploy/adapters/ansible \
              --default-package "openssh-server" \
              --special-package "openvswitch-switch"
    done

    make_repo --os-ver rhel7 --package-tag juno \
              --ansible-dir $WORK_PATH/deploy/adapters/ansible \
              --default-package "rsyslog-7.6.7-1.el7 strace net-tools wget vim openssh-server \
                                 dracut-config-rescue-033-241.el7_1.3 dracut-network-033-241.el7_1.3"

    for opv in kilo liberty; do
    make_repo --os-ver rhel7 --package-tag kilo \
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
        make_repo $*
    fi
}

main $*
