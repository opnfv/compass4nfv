loop_dev=`losetup -a |grep "/var/cinder.img"|awk -F':' '{print $1}'`
if [[ -z $loop_dev ]]; then
  losetup -f /var/cinder.img
  echo "losetup "
else
  echo "not losetup"
fi

