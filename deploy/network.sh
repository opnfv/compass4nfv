function destroy_nat() {
    sudo virsh net-destroy $1  2>&1
    sudo virsh net-undefine $1 2>&1
    rm -rf $COMPASS_DIR/deploy/work/network/$1.xml
}

function destroy_bridge()
{
    bridge=$1
    nic=$2
    ips=$(ip addr show $bridge | grep 'inet ' | awk -F' ' '{print $2}')
    routes=$(ip route show | grep $bridge)

    ip link set $bridge down

    brctl delbr $bridge

    for ip in $ips; do
        ip addr add $ip dev $nic
    done

    echo "$routes" | while read line; do
        echo $line | sed "s/$bridge/$nic/g" | xargs ip route add | true
    done
}

function create_bridge()
{
    bridge=$1
    nic=$2
    ips=$(ip addr show $nic | grep 'inet ' | awk -F' ' '{print $2}')
    routes=$(ip route show | grep $nic)

    ip addr flush $nic

    brctl addbr $bridge
    brctl addif $bridge $nic
    ip link set $bridge up

    for ip in $ips; do
        ip addr add $ip dev $bridge
    done

    mask=`echo $INSTALL_MASK | awk -F'.' '{print ($1*(2^24)+$2*(2^16)+$3*(2^8)+$4)}'`
    mask_len=`echo "obase=2;${mask}"|bc|awk -F'0' '{print length($1)}'`
    ip addr add $INSTALL_GW/$mask_len dev $bridge

    echo "$routes" | while read line; do
        echo $line | sed "s/$nic/$bridge/g" | xargs ip route add | true
    done
}

function setup_om_bridge() {
    destroy_bridge br_install $OM_NIC
    create_bridge br_install $OM_NIC
}

function setup_om_nat() {
    destroy_nat install
    # create install network
    sed -e "s/REPLACE_BRIDGE/br_install/g" \
        -e "s/REPLACE_NAME/install/g" \
        -e "s/REPLACE_GATEWAY/$INSTALL_GW/g" \
        -e "s/REPLACE_MASK/$INSTALL_MASK/g" \
        -e "s/REPLACE_START/$INSTALL_IP_START/g" \
        -e "s/REPLACE_END/$INSTALL_IP_END/g" \
        $COMPASS_DIR/deploy/template/network/nat.xml \
        > $WORK_DIR/network/install.xml

    sudo virsh net-define $WORK_DIR/network/install.xml
    sudo virsh net-start install
}

function create_nets() {
    destroy_nat mgmt
    # create mgmt network
    sed -e "s/REPLACE_BRIDGE/br_mgmt/g" \
        -e "s/REPLACE_NAME/mgmt/g" \
        -e "s/REPLACE_GATEWAY/$MGMT_GW/g" \
        -e "s/REPLACE_MASK/$MGMT_MASK/g" \
        -e "s/REPLACE_START/$MGMT_IP_START/g" \
        -e "s/REPLACE_END/$MGMT_IP_END/g" \
        $COMPASS_DIR/deploy/template/network/nat.xml \
        > $WORK_DIR/network/mgmt.xml

    sudo virsh net-define $WORK_DIR/network/mgmt.xml
    sudo virsh net-start mgmt

    # create install network
    if [[ ! -z $VIRT_NUMBER ]];then
        setup_om_nat
    else
        setup_om_bridge
    fi
}

