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
#    if ! apt --installed list 2>/dev/null | grep "figlet"
#    then
#        sudo apt-get update -y
#        sudo apt-get install -y --force-yes figlet
#    fi

    figlet -ctf slant Compass Installer
    set +x; sleep 2; set -x
}

function download_iso()
{
    iso_name=`basename $ISO_URL`
    rm -f $WORK_DIR/cache/"$iso_name.md5"
    curl --connect-timeout 10 -o $WORK_DIR/cache/"$iso_name.md5" $ISO_URL.md5
    if [[ -f $WORK_DIR/cache/$iso_name ]]; then
        local_md5=`md5sum $WORK_DIR/cache/$iso_name | cut -d ' ' -f 1`
        repo_md5=`cat $WORK_DIR/cache/$iso_name.md5 | cut -d ' ' -f 1`
        if [[ "$local_md5" == "$repo_md5" ]]; then
            return
        fi
    fi

    curl --connect-timeout 10 -o $WORK_DIR/cache/$iso_name $ISO_URL
}

function prepare_env() {

    sudo service libvirt-bin restart
    if sudo service openvswitch-switch status|grep stop; then
        sudo service openvswitch-switch start
    fi

    # prepare work dir
    rm -rf $WORK_DIR/{installer,vm,network,iso}
    mkdir -p $WORK_DIR/installer
    mkdir -p $WORK_DIR/vm
    mkdir -p $WORK_DIR/network
    mkdir -p $WORK_DIR/iso
    mkdir -p $WORK_DIR/cache

    download_iso

    cp $WORK_DIR/cache/`basename $ISO_URL` $WORK_DIR/iso/centos.iso -f

    # copy compass
    mkdir -p $WORK_DIR/mnt
    sudo mount -o loop $WORK_DIR/iso/centos.iso $WORK_DIR/mnt
    cp -rf $WORK_DIR/mnt/compass/compass-core $WORK_DIR/installer/
    cp -rf $WORK_DIR/mnt/compass/compass-install $WORK_DIR/installer/
    sudo umount $WORK_DIR/mnt
    rm -rf $WORK_DIR/mnt

    chmod 755 $WORK_DIR -R

    sudo cp ${COMPASS_DIR}/deploy/qemu_hook.sh /etc/libvirt/hooks/qemu
}

function  _prepare_python_env() {
   rm -rf $WORK_DIR/venv
   mkdir -p $WORK_DIR/venv

   if [[ "$DEPLOY_FIRST_TIME" == "true" ]]; then

        if [[ ! -z "$JHPKG_URL" ]]; then
             _pre_env_setup
        else
             sudo apt-get update -y
             sudo apt-get install -y --force-yes mkisofs bc curl ipmitool openvswitch-switch
             sudo apt-get install -y --force-yes git python-dev python-pip figlet
             sudo apt-get install -y --force-yes libxslt-dev libxml2-dev libvirt-dev build-essential qemu-utils qemu-kvm libvirt-bin virtinst libmysqld-dev
             sudo apt-get install -y --force-yes libffi-dev libssl-dev

        fi
   else
        if [[ ! -z "$JHPKG_URL" ]]; then
             _pre_pip_setup
        else
             sudo pip install --upgrade virtualenv
             virtualenv $WORK_DIR/venv
             source $WORK_DIR/venv/bin/activate

             pip install --upgrade cffi
             pip install --upgrade MarkupSafe
             pip install --upgrade pip
             pip install --upgrade cheetah
             pip install --upgrade pyyaml
             pip install --upgrade requests
             pip install --upgrade netaddr
             pip install --upgrade oslo.config
             pip install --upgrade ansible
        fi
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
     tar -zxvf trusty-jh-ppa.tar.gz

     if [[ -f /etc/apt/apt.conf ]]; then
          mv /etc/apt/apt.conf /etc/apt/apt.conf.bak
     fi

     cat << EOF > /etc/apt/apt.conf
APT::Get::Assume-Yes "true";
APT::Get::force-yes "true";
Acquire::http::Proxy::127.0.0.1:9998 DIRECT;
EOF

     if [[ -f /etc/apt/sources.list ]]; then
          mv /etc/apt/sources.list /etc/apt/sources.list.bak
     fi

     cat << EOF > /etc/apt/sources.list
deb [arch=amd64] http://127.0.0.1:9998/trusty-jh-ppa trusty main
EOF

     nohup python -m SimpleHTTPServer 9998 &

     cd -
     sleep 5
     apt-get update
     apt-get install -y mkisofs bc curl ipmitool openvswitch-switch \
         git python-pip python-dev figlet \
         libxslt-dev libxml2-dev libvirt-dev \
         build-essential qemu-utils qemu-kvm libvirt-bin \
         virtinst libmysqld-dev \
         libssl-dev libffi-dev python-cffi
     pid=$(ps -ef | grep SimpleHTTPServer | grep 9998 | awk '{print $2}')
     echo $pid
     kill -9 $pid

     sudo cp ${COMPASS_DIR}/deploy/qemu_hook.sh /etc/libvirt/hooks/qemu

     rm -rf /etc/apt/sources.list
     if [[ -f /etc/apt/sources.list.bak ]]; then
          mv /etc/apt/sources.list.bak /etc/apt/sources.list
     fi

     rm -rf /etc/apt/apt.conf
     if [[ -f /etc/apt/apt.conf.bak ]]; then
          mv /etc/apt/apt.conf.bak /etc/apt/apt.conf
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

#     rm -rf ~/.pip
#     mkdir -p ~/.pip
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
     tar -zxvf env_trusty_pip.tar.gz

     cat << EOF > ~/.pip/pip.conf
[global]
find-links = http://127.0.0.1:9999/jh_pip
no-index = true
[install]
trusted-host=127.0.0.1
EOF

     nohup python -m SimpleHTTPServer 9999 &

     sleep 5

     cd -

     pip install --upgrade virtualenv

     virtualenv $WORK_DIR/venv
     source $WORK_DIR/venv/bin/activate

     #pip install --upgrade cffi

     PIP="cffi MarkupSafe pip cheetah pyyaml requests netaddr oslo.config ansible"

     #PIP="paramiko jinja2 PyYAML setuptools pycrypto pyasn1 cryptography MarkupSafe idna six enum34 ipaddress pycparser virtualenv cheetah requests netaddr pbr oslo.config ansible"
     for i in ${PIP}; do
        pip install --upgrade $i
     done

     pid=$(ps -ef | grep SimpleHTTPServer | grep 9999 | awk '{print $2}')
     echo $pid
     kill -9 $pid

     if [[ -f ~/.pip/pip.conf.bak ]]; then
          mv ~/.pip/pip.conf.bak ~/.pip/pip.conf
     else
          rm -rf ~/.pip/pip.conf
     fi
#     rm -rf ~/.pip/pip.conf
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

