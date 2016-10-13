#!/bin/bash
##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

function recover_cluster() {
    recover_nets
    recover_compass

    i=0
    MAX_RETRY_TIMES=2
    while [ $i -lt $MAX_RETRY_TIMES ]; do
        let i+=1

        if [[ ! -z $VIRT_NUMBER ]];then
            ## TODO: reboot vm
            recover_host_vms
        else
            reboot_hosts
        fi

        ret=$(check_hosts_reachable 500)
        if [[ "$ret" == "ok" ]];then
            break
        fi
    done

    if [[ $i -ge $MAX_RETRY_TIMES ]]; then
        echo "Recovery Failure !!!"
        exit 1
    fi
    sleep 500

    recover_hosts
}

