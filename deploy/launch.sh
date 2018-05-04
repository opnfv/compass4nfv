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

export DEPLOY_FIRST_TIME=${DEPLOY_FIRST_TIME:-"true"}
export DEPLOY_RECOVERY=${DEPLOY_RECOVERY:-"false"}

source ${COMPASS_DIR}/deploy/conf/base.conf
source ${COMPASS_DIR}/deploy/prepare.sh
prepare_python_env
source ${COMPASS_DIR}/util/log.sh
source ${COMPASS_DIR}/deploy/deploy_parameter.sh
source $(process_input_para $* ) || exit 1
check_input_para
source $(process_default_para $*) || exit 1
source ${COMPASS_DIR}/deploy/conf/${FLAVOR}.conf
source ${COMPASS_DIR}/deploy/conf/${TYPE}.conf
source ${COMPASS_DIR}/deploy/conf/compass.conf
source ${COMPASS_DIR}/deploy/network.sh
source ${COMPASS_DIR}/deploy/host_${TYPE}.sh
source ${COMPASS_DIR}/deploy/compass_vm.sh
source ${COMPASS_DIR}/deploy/deploy_host.sh

######################### main process

if [[ "$DEPLOY_RECOVERY"  == "true" ]]; then
    source ${COMPASS_DIR}/deploy/recovery.sh
    recover_cluster
    exit 0
fi

if [[ "$EXPANSION" == "false" ]]; then
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

    CONTAINER_ALIVE=$(check_container_alive)
    if
    [[ "$DEPLOY_FIRST_TIME" == "true" ]] ||
    [[ "$DEPLOY_COMPASS" == "true" && "$CONTAINER_ALIVE" == "false" ]]
    then
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
    elif
    [[ "$DEPLOY_COMPASS" == "true" && "$CONTAINER_ALIVE" == "true" ]]
    then
        refresh_compass_core
    fi
else
    machines=`get_host_macs`
    if [[ -z $machines ]];then
        log_error "get_host_macs failed"
        exit 1
    fi

    log_info "deploy host macs: $machines"
fi

if [[ "$DEPLOY_HARBOR" == "true" ]]; then
   
   if ! launch_harbor;then
       log_error "launch_harbor failed"
       exit 1
   fi
fi	

if [[ "$REDEPLOY_HOST" != "true" ]]; then
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
fi

public_vip=$(get_public_vip)
set +x

figlet -ctf slant Installation Complete!
echo ""
echo "+------------------------------------------------------------------+"
echo "| To Use OpenStack CLI and Access Horizon, Follow instructions in  |"
echo "| https://wiki.opnfv.org/display/compass4nfv/Containerized+Compass |"
echo "+------------------------------------------------------------------+"
echo ""

if [[ ${DHA##*/} =~ "openo" ]]; then
    python ${COMPASS_DIR}/deploy/opera_adapter.py $DHA $NETWORK
    if [[ $? -ne 0 ]]; then
        log_error 'opera launch failed'
        exit 1
    fi
fi

echo 'compass deploy success'
