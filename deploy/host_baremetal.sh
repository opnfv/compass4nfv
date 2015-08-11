function reboot_hosts() {
   cmd='for i in {14..18}; do /dev/shm/smm/usr/bin/smmset -l blade$i -d bootoption -v 1 0; echo Y | /dev/shm/smm/usr/bin/smmset -l blade$i -d frucontrol -v 0; done'
   /usr/bin/expect ${COMPASS_DIR}/deploy/remote_excute.exp ${SWITCH_IPS} 'root' 'Admin@7*24' "$cmd"
}

function get_host_macs() {
    local config_file=$WORK_DIR/installer/compass-install/install/group_vars/all
    local machines=`echo $HOST_MACS|sed 's/ /,/g'`

    echo "test: true" >> $config_file
    echo "pxe_boot_macs: [${machines}]" >> $config_file
    
    echo $machines
}
