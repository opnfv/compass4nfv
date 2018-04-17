#!/bin/bash
##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################
function print_logo()
{

    figlet -ctf slant Compass Installer
    set +x; sleep 2; set -x
}

function install_docker()
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
    sleep 5
    sudo cat << EOF > /etc/docker/daemon.json
{
  "storage-driver": "devicemapper"
}
EOF

    sudo service docker start
    sudo service docker restart
}

function extract_tar()
{
    tar_name=`basename $TAR_URL`
    rm -f $WORK_DIR/cache/$tar_name
    curl --connect-timeout 10 -o $WORK_DIR/cache/$tar_name $TAR_URL
    tar -zxf $WORK_DIR/cache/$tar_name -C $WORK_DIR/installer
}

function prepare_env() {
    sudo sed -i -e 's/^#user =.*/user = "root"/g' /etc/libvirt/qemu.conf
    sudo sed -i -e 's/^#group =.*/group = "root"/g' /etc/libvirt/qemu.conf
    sudo service libvirt-bin restart
    if sudo service openvswitch-switch status|grep stop; then
        sudo service openvswitch-switch start
    fi

    # prepare work dir
    sudo rm -rf $WORK_DIR/{installer,vm,network,iso,docker}
    mkdir -p $WORK_DIR/installer
    mkdir -p $WORK_DIR/vm
    mkdir -p $WORK_DIR/network
    mkdir -p $WORK_DIR/iso
    mkdir -p $WORK_DIR/cache
    mkdir -p $WORK_DIR/docker

    extract_tar

    chmod 755 $WORK_DIR -R

    if [[ ! -d /etc/libvirt/hooks ]]; then
        sudo mkdir -p /etc/libvirt/hooks
    fi

    sudo cp ${COMPASS_DIR}/deploy/qemu_hook.sh /etc/libvirt/hooks/qemu
}

function  _prepare_python_env() {
   rm -rf $WORK_DIR/venv
   mkdir -p $WORK_DIR/venv

   if [[ "$DEPLOY_FIRST_TIME" == "true" ]]; then

        if [[ ! -z "$JHPKG_URL" ]]; then
             _pre_env_setup
        else
            if [[ ! -f /etc/redhat-release ]]; then
                sudo apt-get update -y
                sudo apt-get install -y --force-yes mkisofs bc curl ipmitool openvswitch-switch
                sudo apt-get install -y --force-yes git python-dev python-pip figlet sshpass
                sudo apt-get install -y --force-yes libxslt-dev libxml2-dev libvirt-dev build-essential qemu-utils qemu-kvm libvirt-bin virtinst libmysqld-dev
                sudo apt-get install -y --force-yes libffi-dev libssl-dev
            else
                sudo yum install -y centos-release-openstack-queens
                sudo yum install -y epel-release
                sudo yum install openvswitch -y --nogpgcheck
                sudo yum install -y git python-devel python-pip figlet sshpass mkisofs bc curl ipmitool
                sudo yum install -y libxslt-devel libxml2-devel libvirt-devel libmysqld-devel
                sudo yum install -y qemu-kvm qemu-img virt-manager libvirt libvirt-python libvirt-client virt-install virt-viewer
                sudo yum install -y libffi libffi-devel openssl-devel
                sudo yum groupinstall -y 'Development Tools'
            fi

            sudo docker version >/dev/null 2>&1
            if [[ $? -ne 0 ]]; then
                install_docker
            fi
        fi
   fi

   if [[ ! -z "$JHPKG_URL" ]]; then
        _pre_pip_setup
   else
        sudo pip install --upgrade virtualenv
        virtualenv $WORK_DIR/venv
        source $WORK_DIR/venv/bin/activate

        pip install cffi==1.10.0
        pip install MarkupSafe==1.0
        pip install pip==9.0.1
        pip install cheetah==2.4.4
        pip install pyyaml==3.12
        pip install requests==2.18.1
        pip install netaddr==0.7.19
        pip install oslo.config==4.6.0
        pip install ansible==2.3.1.0
        # For sudo use
        sudo pip install docker-compose==1.14.0
   fi
}

function _pre_env_setup()
{
     rm -rf $WORK_DIR/prepare
     mkdir -p $WORK_DIR/prepare
     jhpkg_url=${JHPKG_URL:7}
     echo $jhpkg_url
     if [[ ! -f "$jhpkg_url" ]]; then
          echo "There is no jh_env_package."
          exit 1
     fi

     tar -zxvf $jhpkg_url -C $WORK_DIR/prepare/
     cd $WORK_DIR/prepare/jh_env_package
     tar -zxvf jh-ppa.tar.gz

     if [[ ! -z /etc/apt/sources.list.d ]]; then
          mv /etc/apt/sources.list.d /etc/apt/sources.list.d.bak
     fi

     if [[ -f /etc/apt/apt.conf ]]; then
          mv /etc/apt/apt.conf /etc/apt/apt.conf.bak
     fi

     sudo cat << EOF > /etc/apt/apt.conf
APT::Get::Assume-Yes "true";
APT::Get::force-yes "true";
Acquire::http::Proxy::127.0.0.1:9998 DIRECT;
EOF

     if [[ -f /etc/apt/sources.list ]]; then
          mv /etc/apt/sources.list /etc/apt/sources.list.bak
     fi

     sudo cat << EOF > /etc/apt/sources.list
deb [arch=amd64] http://127.0.0.1:9998/jh-ppa $(lsb_release -cs) main
EOF

     if [[ $(lsb_release -cs) == "trusty" ]]; then
         nohup python -m SimpleHTTPServer 9998 &
     else
         nohup python3 -m http.server 9998 &
     fi

     http_ppa_pid=$!

     cd -
     sleep 5
     apt-get update
     apt-get install -y mkisofs bc curl ipmitool openvswitch-switch \
         git python-pip python-dev figlet \
         libxslt-dev libxml2-dev libvirt-dev \
         build-essential qemu-utils qemu-kvm libvirt-bin \
         virtinst libmysqld-dev \
         libssl-dev libffi-dev python-cffi

     sudo docker version >/dev/null 2>&1
     if [[ $? -ne 0 ]]; then
         sudo apt-get install -y docker-ce
         sleep 5
         sudo cat << EOF > /etc/docker/daemon.json
{
  "storage-driver": "devicemapper"
}
EOF

         sudo service docker start
         sudo service docker restart
     else
         StorageDriver=$(sudo docker info | grep "Storage Driver" | awk '{print $3}')
         if [[ $StorageDriver != "devicemapper" ]]; then
             echo "The storage driver of docker currently only supports 'devicemapper'."
             exit 1
         fi
     fi

     kill -9 $http_ppa_pid

     if [[ ! -d /etc/libvirt/hooks ]]; then
         sudo mkdir -p /etc/libvirt/hooks
     fi

     sudo cp -f ${COMPASS_DIR}/deploy/qemu_hook.sh /etc/libvirt/hooks/qemu

     rm -rf /etc/apt/sources.list
     if [[ -f /etc/apt/sources.list.bak ]]; then
          mv /etc/apt/sources.list.bak /etc/apt/sources.list
     fi

     rm -rf /etc/apt/apt.conf
     if [[ -f /etc/apt/apt.conf.bak ]]; then
          mv /etc/apt/apt.conf.bak /etc/apt/apt.conf
     fi

     if [[ ! -z /etc/apt/sources.list.d.bak ]]; then
          mv /etc/apt/sources.list.d.bak /etc/apt/sources.list.d
     fi
}

function _pre_pip_setup()
{
     if [[ -d ~/.pip ]]; then
          if [[ -f ~/.pip/pip.conf ]]; then
               mv ~/.pip/pip.conf ~/.pip/pip.conf.bak
          fi
     else
          mkdir -p ~/.pip
     fi

     rm -rf $WORK_DIR/prepare
     mkdir -p $WORK_DIR/prepare
     jhpkg_url=${JHPKG_URL:7}
     echo $jhpkg_url
     if [[ ! -f "$jhpkg_url" ]]; then
          echo "There is no jh_env_package."
          exit 1
     fi

     tar -zxvf $jhpkg_url -C $WORK_DIR/prepare/
     cd $WORK_DIR/prepare/jh_env_package
     tar -zxvf jh_pip.tar.gz

     cat << EOF > ~/.pip/pip.conf
[global]
find-links = http://127.0.0.1:9999/jh_pip
no-index = true
[install]
trusted-host=127.0.0.1
EOF

     if [[ $(lsb_release -cs) == "trusty" ]]; then
         nohup python -m SimpleHTTPServer 9999 &
     else
         nohup python3 -m http.server 9999 &
     fi

     http_pip_pid=$!
     echo $http_pip_pid

     sleep 5

     cd -

     pip install --upgrade virtualenv

     virtualenv $WORK_DIR/venv
     source $WORK_DIR/venv/bin/activate

     pip install cffi==1.10.0
     pip install MarkupSafe==1.0
     pip install pip==9.0.1
     pip install cheetah==2.4.4
     pip install pyyaml==3.12
     pip install requests==2.18.1
     pip install netaddr==0.7.19
     pip install oslo.config==4.6.0
     pip install ansible==2.3.1.0
     sudo pip install docker-compose==1.14.0
     if [[ $(lsb_release -cs) == "xenial" ]]; then
         sudo pip install -U pyOpenSSL
     fi

     kill -9 $http_pip_pid

     if [[ -f ~/.pip/pip.conf.bak ]]; then
          mv ~/.pip/pip.conf.bak ~/.pip/pip.conf
     else
          rm -rf ~/.pip/pip.conf
     fi
}

function prepare_python_env()
{
    if [[ "$DEPLOY_FIRST_TIME" == "true" ]]; then
        _prepare_python_env
    else
        source $WORK_DIR/venv/bin/activate
        if [[ $? -ne 0 ]]; then
            _prepare_python_env
        fi
    fi
    which python
}

