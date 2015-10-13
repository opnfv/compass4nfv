if [ -d "/var/local/osd" ]; then
echo "clear /var/local/osd"
rm -r /var/local/osd/
umount /var/local/osd
rm -r /var/local/osd
fi

if [ ! -d "/ceph/images" ]; then
mkdir -p /ceph/images
fi

rm -f /ceph/images/ceph-volumes.img

if [ ! -f "/ceph/images/ceph-volumes.img" ]; then
echo "create ceph-volumes.img"
dd if=/dev/zero of=/ceph/images/ceph-volumes.img bs=1K seek=$(df / | awk '$3 ~ /[0-9]+/ { print $4 }') count=0 oflag=direct
sgdisk -g --clear /ceph/images/ceph-volumes.img
fi

#safe check
ps -ef |grep lvremove |awk '{print $2}' |xargs kill -9
ps -ef |grep vgremove |awk '{print $2}' |xargs kill -9
ps -ef |grep vgcreate |awk '{print $2}' |xargs kill -9
ps -ef |grep lvcreate |awk '{print $2}' |xargs kill -9

if [ -L "/dev/ceph-volumes/ceph0" ]; then
echo "remove lv vg"
lvremove -f /dev/ceph-volumes/ceph0
vgremove -f ceph-volumes
rm -r /dev/ceph-volumes
fi

losetup -d /dev/loop0

echo "vgcreate"
vgcreate -y ceph-volumes $(losetup --show -f /ceph/images/ceph-volumes.img)
echo "lvcreate"
lvcreate -l 100%FREE -nceph0 ceph-volumes
echo "mkfs"
mkfs.xfs -f /dev/ceph-volumes/ceph0

if [ ! -d "/var/local/osd" ]; then
echo "mount osd"
mkdir -p /var/local/osd
mount /dev/ceph-volumes/ceph0 /var/local/osd
fi

