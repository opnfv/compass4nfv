[[ ! -f /var/cinder.img ]] && dd if=/dev/zero of=/var/cinder.img bs=1 count=1 seek=$1
