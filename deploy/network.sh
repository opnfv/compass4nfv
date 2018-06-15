#!/bin/bash
##############################################################################
# Copyright (c) 2016 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################
function clear_forward_rejct_rules()
{
    while sudo iptables -nL FORWARD --line-number|grep -E 'REJECT +all +-- +0.0.0.0/0 +0.0.0.0/0 +reject-with icmp-port-unreachable'|head -1|awk '{print $1}'|xargs sudo iptables -D FORWARD; do :; done
}

function setup_bridge_net()
{
    net_name=$1
    nic=$2

    sudo ifconfig $nic up

    sudo virsh net-destroy $net_name
    sudo virsh net-undefine $net_name

    sed -e "s/REPLACE_NAME/$net_name/g" \
        -e "s/REPLACE_NIC/$nic/g" \
    $COMPASS_DIR/deploy/template/network/bridge_nic.xml \
    > $WORK_DIR/network/$net_name.xml

    sudo virsh net-define $WORK_DIR/network/$net_name.xml
    sudo virsh net-start $net_name
    sudo virsh net-autostart $net_name
}

function recover_bridge_net()
{
    net_name=$1

    sudo virsh net-start $net_name
}

function save_network_info()
{
    sudo ovs-vsctl list-br |grep br-external
    br_exist=$?
    external_nic=`ip route |grep '^default'|awk '{print $5F}'`
    route_info=`ip route |grep -Eo '^default via [^ ]+'`
    ip_info=`ip addr show $external_nic|grep -Eo '[^ ]+ brd [^ ]+ '`
    if [ $br_exist -eq 0 ]; then
        if [ "$external_nic" != "br-external" ]; then
            sudo ip link set br-external up
            sudo ovs-vsctl --may-exist add-port br-external $external_nic
            sudo ip addr flush $external_nic
            sudo ip addr add $ip_info dev br-external
            sudo ip route add $route_info dev br-external
        fi
    else
        sudo ovs-vsctl add-br br-external
        sudo ip link set br-external up
        sudo ovs-vsctl add-port br-external $external_nic
        sudo ip addr flush $external_nic
        sudo ip addr add $ip_info dev br-external
        sudo ip route add $route_info dev br-external
    fi

    # Configure OS_MGMT_NIC when openstack external network and mgmt network use different nics
    if [[ x"$OS_MGMT_NIC" != "x" ]]; then
        sudo ovs-vsctl --may-exist add-port br-external $OS_MGMT_NIC
        sudo ip link set $OS_MGMT_NIC up
        sudo ip addr flush $OS_MGMT_NIC
    fi
}

function setup_bridge_external()
{
    sudo virsh net-destroy external
    sudo virsh net-undefine external

    save_network_info
    sed -e "s/REPLACE_NAME/external/g" \
        -e "s/REPLACE_OVS/br-external/g" \
    $COMPASS_DIR/deploy/template/network/bridge_ovs.xml \
    > $WORK_DIR/network/external.xml

    sudo virsh net-define $WORK_DIR/network/external.xml
    sudo virsh net-start external
    sudo virsh net-autostart external

}

function recover_bridge_external()
{
    sudo virsh net-start external

}

function setup_nat_net() {
    net_name=$1
    gw=$2
    mask=$3
    ip_start=$4
    ip_end=$5

    sudo virsh net-destroy $net_name
    sudo virsh net-undefine $net_name
    # create install network
    sed -e "s/REPLACE_BRIDGE/br_$net_name/g" \
        -e "s/REPLACE_NAME/$net_name/g" \
        -e "s/REPLACE_GATEWAY/$gw/g" \
        -e "s/REPLACE_MASK/$mask/g" \
        -e "s/REPLACE_START/$ip_start/g" \
        -e "s/REPLACE_END/$ip_end/g" \
        $COMPASS_DIR/deploy/template/network/nat.xml \
        > $WORK_DIR/network/$net_name.xml

    sudo virsh net-define $WORK_DIR/network/$net_name.xml
    sudo virsh net-start $net_name
    sudo virsh net-autostart $net_name
}

function recover_nat_net() {
    net_name=$1

    sudo virsh net-start $net_name
}

function setup_virtual_net() {
  setup_nat_net install $INSTALL_GW $INSTALL_NETMASK

  if [[ "$NAT_EXTERNAL"  == "false" ]]; then
     setup_bridge_external
  else
      setup_nat_net external_nat $EXT_NAT_GW $EXT_NAT_MASK $EXT_NAT_IP_START $EXT_NAT_IP_END
  fi
}

function recover_virtual_net() {
  recover_nat_net install
}

function setup_baremetal_net() {
  if [[ -z $INSTALL_NIC ]]; then
    exit 1
  fi
  sudo ifconfig $INSTALL_NIC up
  sudo ifconfig $INSTALL_NIC $INSTALL_GW netmask $INSTALL_NETMASK
}

function recover_baremetal_net() {
  if [[ -z $INSTALL_NIC ]]; then
    exit 1
  fi
  recover_bridge_net install
}

function setup_network_boot_scripts() {
    sudo cp $COMPASS_DIR/deploy/network.sh /usr/sbin/network_setup
    sudo chmod +777 /usr/sbin/network_setup
    sudo cat << EOF >> /usr/sbin/network_setup

sleep 2
#save_network_info
clear_forward_rejct_rules
EOF
    sudo chmod 755 /usr/sbin/network_setup

    egrep -R "^/usr/sbin/network_setup" /etc/rc.local
    if [[ $? != 0 ]]; then
        sudo sed -i '/^exit 0/i\/usr\/sbin\/network_setup' /etc/rc.local
    fi
}

function create_nets() {

    # create install network
    setup_"$TYPE"_net

    # create external network
    # setup_bridge_external
    clear_forward_rejct_rules

    setup_network_boot_scripts
}

function recover_nets() {
    recover_nat_net mgmt

    # recover install network
    recover_"$TYPE"_net

    # recover external network
    recover_bridge_external
    clear_forward_rejct_rules
}

