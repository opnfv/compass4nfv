loop_dev=`losetup -a |grep "/var/storage.img"|awk -F':' '{print $1}'`
if [ -z $loop_dev ]; then
  losetup -f --show /var/storage.img
else
  echo $loop_dev
fi

