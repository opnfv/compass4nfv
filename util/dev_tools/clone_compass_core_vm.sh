#!/bin/bash

export COMPASS_CLONED_NAME=compass-clone1
# ETH0 for phy server to access compass-core
export COMPASS_CLONED_ETH0_IP="192.168.200.3"
# ETH1 for PXE and ansible
export COMPASS_CLONED_ETH1_IP="10.1.0.13"
# ETH2 assign external ip for access compass-web
export COMPASS_CLONED_ETH2_IP=""
export COMPASS4FNV_BASE_PATH=/home/compass4nfv
export COMPASS4FNV_WORK_VM_PATH=${COMPASS4FNV_BASE_PATH}/work/deploy/vm
export COMPASS_SSH_KEY=${COMPASS4FNV_WORK_VM_PATH}/compass/boot.rsa
export COMPASS_CORE_IP="192.168.200.2"

export SSH_ARGS="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${COMPASS_SSH_KEY}"

function wait_ok() {
    MGMT_IP=$1
    set +x
    echo "wait_ok enter"
    ssh-keygen -f "/root/.ssh/known_hosts" -R $MGMT_IP >/dev/null 2>&1
    retry=0
    until timeout 1s ssh $SSH_ARGS root@$MGMT_IP "exit" >/dev/null 2>&1
    do
        # echo "os install time used: $((retry*100/$2))%"
        sleep 1
        let retry+=1
        if [[ $retry -ge $2 ]];then
            timeout 1s ssh $SSH_ARGS root@$MGMT_IP "exit"
            echo "os install time out"
            exit 1
        fi
    done
    echo "wait_ok exit"
}

function exec_cmd_on_compass() {
    MGMT_IP=$1
    shift
    ssh $SSH_ARGS root@$MGMT_IP "$@"
}

echo "wait for compass-core poweroff..."
ssh -i ${COMPASS_SSH_KEY} ${COMPASS_CORE_IP} poweroff
virsh domstate compass | grep "shut off" > /dev/null
while [[ $? -ne 0 ]]; do
    sleep 1
    virsh  domstate compass | grep "shut off" > /dev/null
done
echo "done"

echo "clone compass-core vm files..."
cp -a ${COMPASS4FNV_WORK_VM_PATH}/compass \
    ${COMPASS4FNV_WORK_VM_PATH}/${COMPASS_CLONED_NAME}
echo "done"

echo "boot compass-core cloned vm..."
sed -i \
    -e "s/>compass</>${COMPASS_CLONED_NAME}</g" \
    -e "s/\/compass\//\/${COMPASS_CLONED_NAME}\//g" \
    ${COMPASS4FNV_WORK_VM_PATH}/${COMPASS_CLONED_NAME}/libvirt.xml
virsh define ${COMPASS4FNV_WORK_VM_PATH}/${COMPASS_CLONED_NAME}/libvirt.xml
virsh start ${COMPASS_CLONED_NAME}

wait_ok ${COMPASS_CORE_IP} 100
echo "done"

echo "config cloned compass-core..."
cmd="
    sed -i -e 's/IPADDR=.*/IPADDR=${COMPASS_CLONED_ETH0_IP}/g' /etc/sysconfig/network-scripts/ifcfg-eth0;
    sed -i -e 's/IPADDR=.*/IPADDR=${COMPASS_CLONED_ETH1_IP}/g' /etc/sysconfig/network-scripts/ifcfg-eth1;
    sed -i -e 's/IPADDR=.*/IPADDR=${COMPASS_CLONED_ETH2_IP}/g' /etc/sysconfig/network-scripts/ifcfg-eth2;
    reboot
"
exec_cmd_on_compass ${COMPASS_CORE_IP} $cmd
sleep 5
echo "done"

echo "wait for cloned compass-core reboot..."
wait_ok ${COMPASS_CLONED_ETH0_IP} 100
echo "done"

echo "boot initial compass-core and wait ok..."
virsh start compass
wait_ok ${COMPASS_CORE_IP} 100
echo "done"

echo "configure nfsserver and mount /var/ansible from initial compass core..."
cmd="
    sed -i '/\/var\/ansible/d' /etc/exports; \
    echo '/var/ansible *(rw,nohide,insecure,no_subtree_check,async,no_root_squash)' >> /etc/exports; \
    service rpcbind restart; \
    service nfs-server restart
"
exec_cmd_on_compass ${COMPASS_CORE_IP} $cmd

cmd="mount -t nfs -onfsvers=3 ${COMPASS_CORE_IP}:/var/ansible /var/ansible"
exec_cmd_on_compass ${COMPASS_CLONED_ETH0_IP} $cmd
echo "done"

echo "Clone ${COMPASS_CLONED_NAME} with: \
    eth0: ${COMPASS_CLONED_ETH0_IP} \
    eth1: ${COMPASS_CLONED_ETH1_IP} \
    eth2: ${COMPASS_CLONED_ETH2_IP} \
    done."

