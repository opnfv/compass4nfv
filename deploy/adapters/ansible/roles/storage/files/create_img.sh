if [[ ! -f /var/storage.img ]]; then
  dd if=/dev/zero of=/var/storage.img bs=1 count=0 seek=$1
fi
