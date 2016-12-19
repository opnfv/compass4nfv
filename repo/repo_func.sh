#!/bin/bash
##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

function process_env()
{
    mkdir -p ${COMPASS_PATH}/work/repo/ ${COMPASS_PATH}/work/repo/pip

    set +e
    sudo docker info
    if [[ $? != 0 ]]; then
        wget -qO- https://get.docker.com/ | sh
    else
        echo "docker is already installed!"
    fi
    set -e

cat <<EOF >${COMPASS_PATH}/work/repo/cp_repo.sh
#!/bin/bash
set -ex
cp /*.tar.gz /result -f
EOF

    sudo apt-get -f install
    sudo apt-get install python-yaml -y
    sudo apt-get install python-cheetah -y

    source ${COMPASS_PATH}/repo/repo.conf
}

function make_repo()
{
    rm -f ${COMPASS_PATH}/work/repo/install_packages.sh
    rm -f ${COMPASS_PATH}/work/repo/Dockerfile

    option=`echo "os-ver:,package-tag:,tmpl:,default-package:, \
            special-package:,special-package-script-dir:, \
            special-package-dir:,ansible-dir:" | sed 's/ //g'`

    TEMP=`getopt -o h -l $option -n 'repo_func.sh' -- "$@"`

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
    ansible_dir_tmp=""
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

#    if [[ -n ${package_tag} && ${package_tag} == "pip" ]]; then
#        make_pip_repo
#        return
#    fi

#    if [[ -n ${package_tag} && ${package_tag} == "jhenv" && -n ${jh_os} ]]; then
#        make_jhenv_repo
#        return
#    fi

#    if [[ -n ${package_tag} && ${package_tag} == "feature" ]]; then
#        make_feature_repo
#        return
#    fi

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

    if [[ ${os_ver} =~ redhat[0-9]*$ ]]; then
        arch=RedHat
        os_name=redhat
#        tmpl=${BUILD_PATH}/templates/${arch}_${os_ver}_${package_tag}.tmpl
    fi

    if [[ -z $arch ]]; then
        echo "unsupported ${os_ver} os"
        exit 1
    fi

    dockerfile=Dockerfile
    docker_tmpl=${REPO_PATH}/openstack/make_ppa/${os_name}/${dockerfile}".tmpl"
    docker_tag="${os_ver}/${package_tag}"

#    if [[ -z ${tmpl} ]]; then
#        if [[ ${os_ver} == xenial ]]; then
    tmpl=${REPO_PATH}/openstack/make_ppa/${os_name}/${os_ver}/${package_tag}/download_pkg.tmpl
#        else
#            tmpl=${REPO_PATH}/openstack/templates/${arch}_${package_tag}.tmpl
#        fi
#    fi

    if [[ "${ansible_dir}" != "" ]]; then
        # generate ansible_dir_tmp
        if [[ -d ${COMPASS_PATH}/work/tmp ]]; then
            rm -rf ${COMPASS_PATH}/work/tmp
        fi
        mkdir -p ${COMPASS_PATH}/work/tmp
        echo "${ansible_dir}"
        cp -rf ${ansible_dir}/roles/ ${COMPASS_PATH}/work/tmp/
        if [[ ${os_ver} == xenial ]]; then
            if [[ -d ${ansible_dir}/openstack_${package_tag}_${os_ver}/roles && "`ls ${ansible_dir}/openstack_${package_tag}_${os_ver}`" != "" ]]; then
                cp -rf ${ansible_dir}/openstack_${package_tag}_${os_ver}/roles/* ${COMPASS_PATH}/work/tmp/roles/
            fi
        else
            if [[ -d ${ansible_dir}/openstack_${package_tag}/roles && "`ls ${ansible_dir}/openstack_${package_tag}`" != "" ]]; then
                cp -rf ${ansible_dir}/openstack_${package_tag}/roles/* ${COMPASS_PATH}/work/tmp/roles/
            fi
        fi
        ansible_dir_tmp=${COMPASS_PATH}/work/tmp/
    fi

    rm -rf ${COMPASS_PATH}/work/repo/$arch
    mkdir -p ${COMPASS_PATH}/work/repo/$arch/{script,packages}

    if [[ -n $special_package ]]; then
        special_package_script_dir=${REPO_PATH}/openstack/special_pkg/${arch}/
    fi

    # copy make package script to work dir
    if [[ -n $special_package_script_dir && -d $special_package_script_dir ]]; then
        cp -rf $special_package_script_dir/*  ${COMPASS_PATH}/work/repo/$arch/script/
    fi

    # copy special++ packages to work dir
    if [[ -n $special_package_dir ]]; then
        curl --connect-timeout 10 -o $COMPASS_PATH/work/repo/$arch/`basename $special_package_dir` $special_package_dir
        tar -zxvf $COMPASS_PATH/work/repo/$arch/`basename $special_package_dir` -C ${COMPASS_PATH}/work/repo/$arch/packages
    fi

    python ${REPO_PATH}/gen_ins_pkg_script.py "${ansible_dir_tmp}" "${arch}" "${tmpl}" \
          "${docker_tmpl}" "${default_package}" "${special_package}" \
          "${COMPASS_PATH}/work/repo/$arch/script/" \
          "${COMPASS_PATH}/work/repo/$arch/packages/" "${os_ver}"

    # copy centos comps.xml to work dir
    if [[ $arch == RedHat && -f ${COMPASS_PATH}/repo/openstack/make_ppa/centos/comps.xml ]]; then
        cp -rf ${COMPASS_PATH}/repo/openstack/make_ppa/centos/comps.xml ${COMPASS_PATH}/work/repo
        cp -rf ${COMPASS_PATH}/repo/openstack/make_ppa/centos/ceph_key_release.asc ${COMPASS_PATH}/work/repo
    fi

    sudo docker build --no-cache=true -t ${docker_tag} -f ${COMPASS_PATH}/work/repo/${dockerfile} ${COMPASS_PATH}/work/repo/
    sudo docker run -t -v ${COMPASS_PATH}/work/repo:/result ${docker_tag}

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
    source $COMPASS_PATH/repo/repo.conf
    local pip_path=$COMPASS_PATH/work/repo/pip
    local pip_tmp_path=$COMPASS_PATH/work/repo/pip_tmp

    for i in $SPECIAL_PIP_PACKAGE; do
        curl --connect-timeout 10 -o $pip_path/`basename $i` $i
    done

    mkdir -p $pip_tmp_path

    for i in $PIP_PACKAGE; do
        curl --connect-timeout 10 -o $pip_path/$(basename $i) $i
        try_fetch_dependency $pip_path $(basename $i) $pip_tmp_path
    done

    rm -rf $pip_tmp_path

    _make_pip

    cd $COMPASS_PATH/work/repo

    rm -rf openstack_pip

    rm -rf pip-openstack; mkdir -p pip-openstack

    tar -zxvf openstack_pip.tar.gz; cp -f openstack_pip/* pip-openstack/

    cp -f pip/* pip-openstack/

    tar -zcvf pip-openstack.tar.gz ./pip-openstack; cd -

}

function make_jhenv_repo()
{
    for x in $JUMP_HOST; do
        _make_jhenv_repo $x
    done
}

function _make_jhenv_repo()
{
    if [[ $1 == trusty ]]; then
        env_os_name=ubuntu
    fi

    if [[ $1 == xenial ]]; then
        env_os_name=ubuntu
    fi

    if [[ $1 =~ rhel[0-9]*$ ]]; then
        env_os_name=centos
    fi

    if [[ -d ${COMPASS_PATH}/repo/jhenv_template/$env_os_name ]]; then

        jh_env_dockerfile=Dockerfile
        jh_env_docker_tmpl=${REPO_PATH}/jhenv_template/$env_os_name/$1/${jh_env_dockerfile}".tmpl"
        jh_env_docker_tag="$1/env"

        rm -rf ${COMPASS_PATH}/work/repo/jhenv_template
        mkdir ${COMPASS_PATH}/work/repo/jhenv_template
        cp -rf ${COMPASS_PATH}/repo/jhenv_template/$env_os_name/$1/${jh_env_dockerfile} ${COMPASS_PATH}/work/repo/jhenv_template

cat <<EOF >${COMPASS_PATH}/work/repo/jhenv_template/cp_env.sh
#!/bin/bash
set -ex
cp /*.tar.gz /env -f
EOF

        sudo docker build --no-cache=true -t ${jh_env_docker_tag} -f ${COMPASS_PATH}/work/repo/jhenv_template/${jh_env_dockerfile} ${COMPASS_PATH}/work/repo/jhenv_template
        sudo docker run -t -v ${COMPASS_PATH}/work/repo:/env ${jh_env_docker_tag}

        image_id=$(sudo docker images|grep ${jh_env_docker_tag}|awk '{print $3}')

        sudo docker rmi -f ${image_id}

#    cd $COMPASS_PATH/work/repo; tar -zcvf pip.tar.gz ./pip; cd -
    fi
}

function _make_pip()
{
    if [[ ! -f ${COMPASS_PATH}/repo/openstack/pip/Dockerfile ]]; then
        echo "No Dockerfile for making pip repo!"
        return
    fi

    if [[ -d ${COMPASS_PATH}/repo/openstack_pip ]]; then
        rm -rf ${COMPASS_PATH}/work/repo/openstack_pip
    fi

    mkdir -p ${COMPASS_PATH}/work/repo/openstack_pip

    cp -f ${COMPASS_PATH}/repo/openstack/pip/Dockerfile ${COMPASS_PATH}/work/repo/openstack_pip/
    cp -f ${COMPASS_PATH}/repo/openstack/pip/code_url.conf ${COMPASS_PATH}/work/repo/openstack_pip/

cat <<EOF >${COMPASS_PATH}/work/repo/openstack_pip/cp_pip.sh
#!/bin/bash
set -ex
cp /*.tar.gz /env -f
EOF

cat <<EOF >${COMPASS_PATH}/work/repo/openstack_pip/make_pip.sh
#!/bin/bash
set -ex
source code_url.conf
for i in \$GIT_URL; do
    mkdir -p /home/tmp
    git clone \$i -b \$BRANCH /home/tmp
    pip install -r /home/tmp/requirements.txt -d openstack_pip/
    rm -rf /home/tmp
done
EOF

    pip_docker_tag="pip/env"

    sudo docker build --no-cache=true -t ${pip_docker_tag} -f ${COMPASS_PATH}/work/repo/openstack_pip/Dockerfile ${COMPASS_PATH}/work/repo/openstack_pip
    sudo docker run -t -v ${COMPASS_PATH}/work/repo:/env ${pip_docker_tag}

    image_id=$(sudo docker images|grep ${pip_docker_tag}|awk '{print $3}')

    sudo docker rmi -f ${image_id}

}

# Make all the openstack ppas
function make_osppa()
{
    make_repo --os-ver xenial --package-tag newton \
              --ansible-dir $COMPASS_PATH/deploy/adapters/ansible \
              --default-package "openssh-server"
}

function make_compass_repo()
{
    make_repo --os-ver rhel7 --package-tag compass \
              --tmpl "${COMPASS_PATH}/repo/openstack/make_ppa/centos/rhel7/compass/compass_core.tmpl" \
              --default-package "kernel-devel epel-release wget libxml2 glibc gcc perl openssl-libs mkisofs createrepo lsof \
                                 python-yaml python-jinja2 python-paramiko elasticsearch logstash bind-license vim nmap-ncat \
                                 yum cobbler cobbler-web createrepo mkisofs syslinux pykickstart bind rsync fence-agents \
                                 dhcp xinetd tftp-server httpd libselinux-python python-setuptools python-devel mysql-devel \
                                 mysql-server mysql MySQL-python redis mod_wsgi net-tools rabbitmq-server nfs-utils" \
              --special-package "kibana jdk"
}

function make_feature_repo()
{
    if [[ -d $COMPASS_PATH/work/repo/packages ]]; then
        rm -rf $COMPASS_PATH/work/repo/packages
    fi

    if [[ -d $COMPASS_PATH/work/repo/temp ]]; then
        rm -rf $COMPASS_PATH/work/repo/temp
    fi

    mkdir -p $COMPASS_PATH/work/repo/packages
    mkdir -p $COMPASS_PATH/work/repo/temp

    echo "$OPNFV_VERSION"

    for i in $OPNFV_VERSION; do
        mkdir -p $COMPASS_PATH/work/repo/packages/$i
        mkdir -p $COMPASS_PATH/work/repo/temp/$i
        if [[ -d $COMPASS_PATH/work/repo/temp/make_pkg ]]; then
            rm -rf $COMPASS_PATH/work/repo/temp/make_pkg
        fi
        mkdir -p $COMPASS_PATH/work/repo/temp/make_pkg

        if [[ ! -d $COMPASS_PATH/repo/features/$i ]]; then
            echo "No $i in compass feature directory."
            return
        fi

        cp -rf $COMPASS_PATH/repo/features/$i/* $COMPASS_PATH/work/repo/temp/make_pkg

        feature_dockerfile=Dockerfile
        feature_docker_tag=trusty/feature

        if [[ ! -f $COMPASS_PATH/repo/features/$feature_dockerfile ]]; then
            echo "No Dockerfile in compass feature directory."
            return
        fi

        cp -f $COMPASS_PATH/repo/features/$feature_dockerfile $COMPASS_PATH/work/repo/temp/

cat <<EOF >${COMPASS_PATH}/work/repo/temp/cp_pkg.sh
#!/bin/bash
set -ex
cp /*.tar.gz /feature -f
EOF

cat <<EOF >${COMPASS_PATH}/work/repo/temp/feature_run.sh
#!/bin/bash
set -ex
_script=\`ls /run_script\`
for z in \$_script; do
    . /run_script/\$z
done
EOF
        sudo docker build --no-cache=true -t ${feature_docker_tag} -f ${COMPASS_PATH}/work/repo/temp/${feature_dockerfile} ${COMPASS_PATH}/work/repo/temp
        sudo docker run -t -v ${COMPASS_PATH}/work/repo/packages:/feature ${feature_docker_tag}

        image_id=$(sudo docker images|grep ${feature_docker_tag}|awk '{print $3}')

        sudo docker rmi -f ${image_id}

        mv ${COMPASS_PATH}/work/repo/packages/*.tar.gz $COMPASS_PATH/work/repo/packages/$i

    done

    cd ${COMPASS_PATH}/work/repo/
    tar -zcvf ${COMPASS_PATH}/work/repo/packages.tar.gz packages/
    cd -
}


