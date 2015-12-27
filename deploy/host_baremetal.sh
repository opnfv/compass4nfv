function reboot_hosts() {
    if [ -z $POWER_MANAGE ]; then
        return
    fi
    $POWER_MANAGE
}

function get_host_macs() {
    machines=`echo $HOST_MACS | sed -e 's/,/'\',\''/g' -e 's/^/'\''/g' -e 's/$/'\''/g'`
    echo $machines
}
