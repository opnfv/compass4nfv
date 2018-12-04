#!/bin/bash
##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################
host_vm_dir=$WORK_DIR/vm
function tear_down_machines() {
    old_ifs=$IFS
    IFS=,
    for i in $HOSTNAMES; do
        sudo virsh destroy $i
        if [ "$COMPASS_ARCH" = "aarch64" ]; then
            # --nvram is required for UEFI enabled VM
            sudo virsh undefine --nvram $i
        else
            sudo virsh undefine $i
        fi
        rm -rf $host_vm_dir/$i
    done
    IFS=$old_ifs
}

function reboot_hosts() {
    echo "reboot"
    # We do need it for aarch64
#    if [ "$COMPASS_ARCH" = "aarch64" ]; then
#        old_ifs=$IFS
#        IFS=,
#        for i in $HOSTNAMES; do
#            sudo virsh destroy $i
#            sleep 3
#            sudo virsh start $i
#            sleep 3
#        done
#        IFS=$old_ifs
#    else
#        log_warn "reboot_hosts do nothing"
#    fi
}

function launch_host_vms() {
    old_ifs=$IFS
    IFS=,
    #function_bod
    mac_array=($machines)

    # Select vm template per arch
    vm_template_dir="$COMPASS_DIR/deploy/template/vm"
    vm_template_file="$vm_template_dir/host.xml"
    vm_template_arch="$vm_template_dir/host-$COMPASS_ARCH.xml"
    [ -f $vm_template_arch ] && vm_template_file=$vm_template_arch
    if [[ "$NAT_EXTERNAL"  == "false" ]]; then
       NET_IAAS="external"
    else
       NET_IAAS="external_nat"
    fi

    log_info "bringing up pxe boot vms"
    i=0
    for host in $HOSTNAMES; do
        log_info "creating vm disk for instance $host"
        vm_dir=$host_vm_dir/$host
        mkdir -p $vm_dir
        sudo qemu-img create -f raw $vm_dir/disk.img ${VIRT_DISK}
        # create vm xml
        sed -e "s/REPLACE_MEM/$VIRT_MEM/g" \
          -e "s/REPLACE_CPU/$VIRT_CPUS/g" \
          -e "s/REPLACE_NAME/$host/g" \
          -e "s#REPLACE_IMAGE#$vm_dir/disk.img#g" \
          -e "s/REPLACE_BOOT_MAC/${mac_array[i]}/g" \
          -e "s/REPLACE_NET_INSTALL/install/g" \
          -e "s/REPLACE_NET_IAAS/$NET_IAAS/g" \
          "$vm_template_file" \
          > $vm_dir/libvirt.xml

        sudo virsh define $vm_dir/libvirt.xml
        sudo virsh start $host
        let i=i+1
    done
    IFS=$old_ifs
}

function recover_host_vms() {
    old_ifs=$IFS
    IFS=,

    for host in $HOSTNAMES; do
        sudo virsh destroy $host
        sleep 2
        sudo virsh start $host
        sleep 2
    done
    IFS=$old_ifs
}

function get_host_macs() {
    local machines=`echo $HOST_MACS | sed -e 's/,/'\',\''/g' -e 's/^/'\''/g' -e 's/$/'\''/g'`
    echo $machines
}

