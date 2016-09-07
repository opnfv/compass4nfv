#!/bin/bash
##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################
function reboot_hosts() {
    if [ -z $POWER_MANAGE ]; then
        return
    fi
    $POWER_MANAGE
}

function get_host_macs() {
    if [ $EXPANSION -eq 0 ]; then
        machines=`echo $HOST_MACS | sed -e 's/,/'\',\''/g' -e 's/^/'\''/g' -e 's/$/'\''/g'`
        echo $machines
    else
        machines_old=`cat $WORK_DIR/switch_machines`
        machines_add=`echo $HOST_MACS | sed -e 's/,/'\',\''/g' -e 's/^/'\''/g' -e 's/$/'\''/g'`
        echo $machines_add $machines_old > $WORK_DIR/switch_machines
        machines=`echo $machines_add $machines_old|sed 's/ /,/g'`
    fi
}
