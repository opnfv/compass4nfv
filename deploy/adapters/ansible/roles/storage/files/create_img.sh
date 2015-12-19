seek_num=`echo $1 | sed -e 's/.* //g'`
if [ ! -f /var/storage.img ]; then
  dd if=/dev/zero of=/var/storage.img bs=1 count=0 seek=$seek_num
fi
