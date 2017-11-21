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

function check_container_alive() {
    docker exec -it compass-deck bash -c "exit" 1>/dev/null 2>&1
    local deck_state=$?
    docker exec -it compass-tasks bash -c "exit" 1>/dev/null 2>&1
    local tasks_state=$?
    docker exec -it compass-cobbler bash -c "exit" 1>/dev/null 2>&1
    local cobbler_state=$?
    docker exec -it compass-db bash -c "exit" 1>/dev/null 2>&1
    local db_state=$?
    docker exec -it compass-mq bash -c "exit" 1>/dev/null 2>&1
    local mq_state=$?

    if [ $((deck_state||tasks_state||cobbler_state||db_state||mq-state)) == 0 ]; then
        echo "true"
    else
        echo "false"
    fi
}

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
    local config_file=$WORK_DIR/installer/docker-compose/group_vars/all
    sed -i '/pxe_boot_macs/d' $config_file
    echo "pxe_boot_macs: [${machines}]" >> $config_file

    ansible-playbook $WORK_DIR/installer/docker-compose/add_machine.yml
}

function install_compass() {
    local inventory_file=$compass_vm_dir/inventory.file
    sed -i "s/mgmt_next_ip:.*/mgmt_next_ip: ${COMPASS_SERVER}/g" $WORK_DIR/installer/compass-install/install/group_vars/all
    sed -i "s/timezone:.*/timezone: ${TIMEZONE}/g" $WORK_DIR/installer/compass-install/install/group_vars/all
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
    os=newton
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
}

function _inject_ceph_expansion_conf() {
    os=newton
    CONF_TEMPLATES_DIR=/etc/compass/templates/ansible_installer/openstack_$os/vars
    if [[ "$EXPANSION" == "true" ]]; then
        cmd="
            sed -i '/compute_expansion/d' ${CONF_TEMPLATES_DIR}/HA-ansible-multinodes.tmpl; \
            echo compute_expansion: True >> ${CONF_TEMPLATES_DIR}/HA-ansible-multinodes.tmpl; \
        "
    else
        cmd="
            sed -i '/compute_expansion/d' ${CONF_TEMPLATES_DIR}/HA-ansible-multinodes.tmpl; \
            echo compute_expansion: False >> ${CONF_TEMPLATES_DIR}/HA-ansible-multinodes.tmpl; \
        "
    fi
    exec_cmd_on_compass $cmd
}

function inject_compass_conf() {
    _inject_dashboard_conf
    _inject_ceph_expansion_conf
}

function refresh_compass_core () {
    sudo docker exec compass-deck bash -c "/opt/compass/bin/manage_db.py createdb"
    sudo docker exec compass-deck bash -c "/root/compass-deck/bin/clean_installers.py"
    sudo docker exec compass-tasks bash -c \
    "ps aux | grep -E '[a]nsible-playbook|[o]penstack-ansible' | awk '{print \$2}' | xargs kill -9"
    sudo rm -rf $WORK_DIR/docker/ansible/run/*
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
    local group_vars=$WORK_DIR/installer/docker-compose/group_vars/all
    sed -i "s#^\(compass_dir:\).*#\1 $COMPASS_DIR#g" $group_vars
    sed -i "s#^\(compose_images:\).*#\1 $COMPOSE_IMAGES#g" $group_vars

    if [[ $OFFLINE_DEPLOY == "Enable" ]]; then
        sed -i "s#.*\(compass_repo:\).*#\1 $COMPASS_REPO#g" $group_vars
    else
        sed -i "s/^\(compass_repo:.*\)/#\1/g" $group_vars
    fi
    sed -i "s#^\(host_ip:\).*#\1 $INSTALL_IP#g" $group_vars
    sed -i "s#^\(install_subnet:\).*#\1 ${INSTALL_CIDR%/*}#g" $group_vars
    sed -i "s#^\(install_prefix:\).*#\1 ${INSTALL_CIDR##*/}#g" $group_vars
    sed -i "s#^\(install_netmask:\).*#\1 $INSTALL_NETMASK#g" $group_vars
    sed -i "s#^\(install_ip_range:\).*#\1 $INSTALL_IP_RANGE#g" $group_vars

    sed -i "s#^\(deck_port:\).*#\1 $COMPASS_DECK_PORT#g" $group_vars
    sed -i "s#^\(repo_port:\).*#\1 $COMPASS_REPO_PORT#g" $group_vars
    ansible-playbook $WORK_DIR/installer/docker-compose/bring_up_compass.yml
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
    cat $WORK_DIR/docker/ansible/run/$ADAPTER_NAME'-'$CLUSTER_NAME/group_vars/all \
    | grep -A 3 public_vip: | sed -n '2p' |sed -e 's/  ip: //g'
}
