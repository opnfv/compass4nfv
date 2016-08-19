#!/bin/bash
##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################
#set -x
WORK_DIR=$COMPASS_DIR/work/deploy

mkdir -p $WORK_DIR/script

export DEPLOY_FIRST_TIME=${DEPLOY_FIRST_TIME-"true"}

source ${COMPASS_DIR}/deploy/prepare.sh
prepare_python_env
source ${COMPASS_DIR}/util/log.sh
source ${COMPASS_DIR}/deploy/deploy_parameter.sh
source $(process_input_para $*) || exit 1
source $(process_default_para $*) || exit 1
source ${COMPASS_DIR}/deploy/conf/${FLAVOR}.conf
source ${COMPASS_DIR}/deploy/conf/${TYPE}.conf
source ${COMPASS_DIR}/deploy/conf/base.conf
source ${COMPASS_DIR}/deploy/conf/compass.conf
source ${COMPASS_DIR}/deploy/network.sh
source ${COMPASS_DIR}/deploy/host_${TYPE}.sh
source ${COMPASS_DIR}/deploy/compass_vm.sh
source ${COMPASS_DIR}/deploy/deploy_host.sh

######################### main process
print_logo

if [[ ! -z $VIRT_NUMBER ]];then
    tear_down_machines
fi

log_info "########## get host mac begin #############"
machines=`get_host_macs`
if [[ -z $machines ]]; then
    log_error "get_host_macs failed"
    exit 1
fi

export machines

if [[ "$DEPLOY_COMPASS" == "true" ]]; then
    if ! prepare_env;then
        echo "prepare_env failed"
        exit 1
    fi

    log_info "########## set up network begin #############"
    if ! create_nets;then
        log_error "create_nets failed"
        exit 1
    fi

    if ! launch_compass;then
        log_error "launch_compass failed"
        exit 1
    fi
fi

if [[ -z "$REDEPLOY_HOST" || "$REDEPLOY_HOST" == "false" ]]; then
    if ! set_compass_machine; then
        log_error "set_compass_machine fail"
    fi
fi

if [[ "$DEPLOY_HOST" == "true" || $REDEPLOY_HOST == "true" ]]; then
    if [[ ! -z $VIRT_NUMBER ]];then
        if ! launch_host_vms;then
            log_error "launch_host_vms failed"
            exit 1
        fi
    fi

    if ! deploy_host;then
         exit 1
    fi
    echo $HOST_ROLES
    echo $TYPE
    echo $DHA
    if [[ `echo $HOST_ROLES | grep opencontrail` ]]; then
        ssh_options="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
        installer_ip="192.168.200.2"
        vgw_ip=$(sshpass -p 'root' ssh $ssh_options root@$installer_ip 'cat /home/opencontrail1.rc')
        externet_cidr=$(sshpass -p 'root' ssh $ssh_options root@$installer_ip 'cat /home/opencontrail2.rc')
        sudo ip route add $externet_cidr via $vgw_ip dev br-external 2>/dev/null
        sleep 60
        sudo python ${COMPASS_DIR}/deploy/reset_compute.py $TYPE $DHA
        sleep 600
    fi
fi

figlet -ctf slant Installation Complete!
