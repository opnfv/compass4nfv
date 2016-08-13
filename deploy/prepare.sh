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

    rm -rf $WORK_DIR/iso
    mkdir -p $WORK_DIR/iso
    mkdir -p $WORK_DIR/cache
    curl --connect-timeout 10 -o $WORK_DIR/cache/$iso_name $ISO_URL

}

function pre_prepare() {
    # prepare work dir
    rm -rf $WORK_DIR/{installer,vm,network}
    mkdir -p $WORK_DIR/installer
    mkdir -p $WORK_DIR/vm
    mkdir -p $WORK_DIR/network

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

    rm -rf $WORK_DIR/cache/compass_tmp
    mkdir -p $WORK_DIR/cache/compass_tmp
    rm -rf $WORK_DIR/cache/jh_env_tmp
    mkdir -p $WORK_DIR/cache/jh_env_tmp
    sudo mount -o loop $WORK_DIR/cache/$iso_name $WORK_DIR/cache/compass_tmp/
    cp $WORK_DIR/cache/compass_tmp/jh_env_package/*.tar.gz $WORK_DIR/cache/jh_env_tmp/
    sudo umount $WORK_DIR/cache/compass_tmp/
    rm -rf $WORK_DIR/cache/compass_tmp
    tar -zxvf $WORK_DIR/cache/jh_env_tmp/env_trusty_deb.tar.gz -C $WORK_DIR/cache/jh_env_tmp
    tar -zxvf $WORK_DIR/cache/jh_env_tmp/env_trusty_pip.tar.gz -C $WORK_DIR/cache/jh_env_tmp
}

function prepare_env() {
   if [[ "$DEPLOY_FIRST_TIME" == "true" ]]; then
        cd $WORK_DIR/cache/jh_env_tmp/jh_deb
        dpkg -i *.deb
        cd -
   fi
}

function  _prepare_python_env() {
   rm -rf $WORK_DIR/venv
   mkdir -p $WORK_DIR/venv

   rm -rf ~/.pip
   mkdir -p ~/.pip
   cd $WORK_DIR/cache/jh_env_tmp/

cat <<EOF > ~/.pip/pip.conf
[global]
find-links = http://127.0.0.1:9999/jh_pip
no-index = true
[install]
trusted-host=127.0.0.1
EOF

   nohup python -m SimpleHTTPServer 9999 &

   cd -

   virtualenv $WORK_DIR/venv
   source $WORK_DIR/venv/bin/activate

   PIP="markupsafe virtualenv cheetah pyyaml requests netaddr pbr oslo.config ansible"
   for i in ${PIP}; do
     pip install --upgrade $i
   done
   service libvirt-bin restart
   if sudo service openvswitch-switch status|grep stop; then
       sudo service openvswitch-switch start
   fi

   pid=$(ps -ef | grep SimpleHTTPServer | grep 9999 | awk '{print $2}')
   echo $pid
   kill -9 $pid

   rm -rf ~/.pip/pip.conf
   rm -rf $WORK_DIR/cache/jh_env_tmp
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

