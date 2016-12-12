#!/bin/bash
##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################
compass_vm_dir=$WORK_DIR/vm/compass
rsa_file=$compass_vm_dir/boot.rsa
ssh_args="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i $rsa_file"
function tear_down_compass() {
    sudo virsh destroy compass > /dev/null 2>&1
    sudo virsh undefine compass > /dev/null 2>&1

    sudo umount $compass_vm_dir/old > /dev/null 2>&1
    sudo umount $compass_vm_dir/new > /dev/null 2>&1

    sudo rm -rf $compass_vm_dir

    log_info "tear_down_compass success!!!"
}

function install_compass_core() {
    install_compass "compass_nodocker.yml"
}

function set_compass_machine() {
    local config_file=$WORK_DIR/installer/compass-install/install/group_vars/all

    sed -i -e '/test: true/d' -e '/pxe_boot_macs/d' $config_file
    echo "test: true" >> $config_file
    echo "pxe_boot_macs: [${machines}]" >> $config_file

    install_compass "compass_machine.yml"
}

function install_compass() {
    local inventory_file=$compass_vm_dir/inventory.file
    sed -i "s/mgmt_next_ip:.*/mgmt_next_ip: ${COMPASS_SERVER}/g" $WORK_DIR/installer/compass-install/install/group_vars/all
    echo "compass_nodocker ansible_ssh_host=$MGMT_IP ansible_ssh_port=22" > $inventory_file
    PYTHONUNBUFFERED=1 ANSIBLE_FORCE_COLOR=true ANSIBLE_HOST_KEY_CHECKING=false ANSIBLE_SSH_ARGS='-o UserKnownHostsFile=/dev/null -o ControlMaster=auto -o ControlPersist=60s' ansible-playbook -e pipeline=true --private-key=$rsa_file --user=root --connection=ssh --inventory-file=$inventory_file $WORK_DIR/installer/compass-install/install/$1
    exit_status=$?
    rm $inventory_file
    if [[ $exit_status != 0 ]];then
        /bin/false
    fi
}

function exec_cmd_on_compass() {
    ssh $ssh_args root@$MGMT_IP "$@"
}

function _inject_dashboard_conf() {
    for os in mitaka mitaka_xenial newton_xenial; do
        CONF_TEMPLATES_DIR=/etc/compass/templates/ansible_installer/openstack_$os/vars
        if [[ "$ENABLE_UBUNTU_THEME" == "true" ]]; then
            cmd="
                sed -i '/enable_ubuntu_theme/d' ${CONF_TEMPLATES_DIR}/HA-ansible-multinodes.tmpl; \
                echo enable_ubuntu_theme: True >> ${CONF_TEMPLATES_DIR}/HA-ansible-multinodes.tmpl
            "
        else
            cmd="
                sed -i '/enable_ubuntu_theme/d' ${CONF_TEMPLATES_DIR}/HA-ansible-multinodes.tmpl; \
                echo enable_ubuntu_theme: False >> ${CONF_TEMPLATES_DIR}/HA-ansible-multinodes.tmpl
            "
        fi
        exec_cmd_on_compass $cmd
    done
}

function inject_compass_conf() {
    _inject_dashboard_conf
}

function refresh_compass_core () {
    cmd="/opt/compass/bin/refresh.sh"
    exec_cmd_on_compass $cmd
}

function wait_ok() {
    set +x
    log_info "wait_compass_ok enter"
    ssh-keygen -f "/root/.ssh/known_hosts" -R $MGMT_IP >/dev/null 2>&1
    retry=0
    until timeout 1s ssh $ssh_args root@$MGMT_IP "exit" >/dev/null 2>&1
    do
        log_progress "os install time used: $((retry*100/$1))%"
        sleep 1
        let retry+=1
        if [[ $retry -ge $1 ]];then
            # first try
            ssh $ssh_args root@$MGMT_IP "exit"
            # second try
            ssh $ssh_args root@$MGMT_IP "exit"
            exit_status=$?
            if [[ $exit_status == 0 ]]; then
                log_warn "final ssh login compass success !!!"
                break
            fi
            log_error "final ssh retry failed with status: " $exit_status
            log_error "os install time out"
            exit 1
        fi
    done
    set -x
    log_warn "os install time used: 100%"
    log_info "wait_compass_ok exit"
}

function launch_compass() {
    local old_mnt=$compass_vm_dir/old
    local new_mnt=$compass_vm_dir/new
    local old_iso=$WORK_DIR/iso/centos.iso
    local new_iso=$compass_vm_dir/centos.iso

    log_info "launch_compass enter"
    tear_down_compass

    set -e
    mkdir -p $compass_vm_dir $old_mnt
    sudo mount -o loop $old_iso $old_mnt
    cd $old_mnt;find .|cpio -pd $new_mnt;cd -

    sudo umount $old_mnt

    chmod 755 -R $new_mnt

    cp $COMPASS_DIR/util/isolinux.cfg $new_mnt/isolinux/ -f
    cp $COMPASS_DIR/util/ks.cfg $new_mnt/isolinux/ -f

    sed -i -e "s/REPLACE_MGMT_IP/$MGMT_IP/g" \
           -e "s/REPLACE_MGMT_NETMASK/$MGMT_MASK/g" \
           -e "s/REPLACE_GW/$MGMT_GW/g" \
           -e "s/REPLACE_INSTALL_IP/$COMPASS_SERVER/g" \
           -e "s/REPLACE_INSTALL_NETMASK/$INSTALL_MASK/g" \
           -e "s/REPLACE_COMPASS_EXTERNAL_NETMASK/$COMPASS_EXTERNAL_MASK/g" \
           -e "s/REPLACE_COMPASS_EXTERNAL_IP/$COMPASS_EXTERNAL_IP/g" \
           -e "s/REPLACE_COMPASS_EXTERNAL_GW/$COMPASS_EXTERNAL_GW/g" \
           $new_mnt/isolinux/isolinux.cfg

    if [[ -n $COMPASS_DNS1 ]]; then
        sed -i -e "s/REPLACE_COMPASS_DNS1/$COMPASS_DNS1/g" $new_mnt/isolinux/isolinux.cfg
    fi

    if [[ -n $COMPASS_DNS2 ]]; then
        sed -i -e "s/REPLACE_COMPASS_DNS2/$COMPASS_DNS2/g" $new_mnt/isolinux/isolinux.cfg
    fi

    ssh-keygen -f $new_mnt/bootstrap/boot.rsa -t rsa -N ''
    cp $new_mnt/bootstrap/boot.rsa $rsa_file

    rm -rf $new_mnt/.rr_moved $new_mnt/rr_moved
    sudo mkisofs -quiet -r -J -R -b isolinux/isolinux.bin  -no-emul-boot -boot-load-size 4 -boot-info-table -hide-rr-moved -x "lost+found:" -o $new_iso $new_mnt

    rm -rf $old_mnt $new_mnt

    qemu-img create -f qcow2 $compass_vm_dir/disk.img 100G

    # create vm xml
    sed -e "s/REPLACE_MEM/$COMPASS_VIRT_MEM/g" \
        -e "s/REPLACE_CPU/$COMPASS_VIRT_CPUS/g" \
        -e "s#REPLACE_IMAGE#$compass_vm_dir/disk.img#g" \
        -e "s#REPLACE_ISO#$compass_vm_dir/centos.iso#g" \
        -e "s/REPLACE_NET_MGMT/mgmt/g" \
        -e "s/REPLACE_NET_INSTALL/install/g" \
        -e "s/REPLACE_NET_EXTERNAL/external/g" \
        $COMPASS_DIR/deploy/template/vm/compass.xml \
        > $WORK_DIR/vm/compass/libvirt.xml

    sudo virsh define $compass_vm_dir/libvirt.xml
    sudo virsh start compass

    exit_status=$?
    if [ $exit_status != 0 ];then
        log_error "virsh start compass failed"
        exit 1
    fi

    if ! wait_ok 500;then
        log_error "install os timeout"
        exit 1
    fi

    if ! install_compass_core;then
        log_error "install compass core failed"
        exit 1
    fi

    set +e
    log_info "launch_compass exit"
}

function recover_compass() {
    log_info "recover_compass enter"

    sudo virsh start compass

    if ! wait_ok 500;then
        log_error "install os timeout"
        exit 1
    fi

    log_info "launch_compass exit"
}

function _check_hosts_reachable() {
    retry=0

    while true; do
        sleep 1
        let retry+=1
        if [[ $retry -ge $1 ]]; then
            log_error "hosts boot time out"
            echo "fail"
            return
        fi

        ssh $ssh_args root@$MGMT_IP "
            cd /var/ansible/run/$ADAPTER_NAME'-'$CLUSTER_NAME;
            ansible -i inventories/inventory.yml $2 -m ping
        " > /dev/null
        if [ $? == 0 ]; then
            break
        fi
    done
    echo "ok"
}

function check_hosts_reachable() {
    ret=$(_check_hosts_reachable $1 compute)
    if [[ "$ret" == "fail" ]]; then
        echo $ret
        return
    fi

    ret=$(_check_hosts_reachable 100 controller)
    echo $ret
}

function recover_hosts() {
    ssh $ssh_args root@$MGMT_IP "
        cd /var/ansible/run/$ADAPTER_NAME'-'$CLUSTER_NAME;
        ansible-playbook \
            -i inventories/inventory.yml HA-ansible-multinodes.yml \
            -t recovery \
            -e 'RECOVERY_ENV=True'
    "
    if [ $? == 0 ]; then
        echo "Recovery Complete!"
    fi
}

function wait_controller_nodes_ok() {
    sleep 100
    ssh $ssh_args root@$MGMT_IP "
        cd /var/ansible/run/$ADAPTER_NAME'-'$CLUSTER_NAME;
        ansible-playbook \
            -i inventories/inventory.yml HA-ansible-multinodes.yml \
            -t recovery-stop-service \
            -e 'RECOVERY_ENV=True'
    "
    sleep 30
}

function get_public_vip () {
    ssh $ssh_args root@$MGMT_IP "
        cd /var/ansible/run/openstack_newton_xenial-opnfv2
        cat group_vars/all | grep -A 3 public_vip: | sed -n '2p' |sed -e 's/  ip: //g'
    "
}
