if [ -d "/var/local/osd" ]; then
echo "clear /var/local/osd"
rm -r /var/local/osd/
umount /var/local/osd
rm -r /var/local/osd
fi

if [ ! -d "/ceph/images" ]; then
mkdir -p /ceph/images
fi

rm /ceph/images/ceph-volumes.img

if [ ! -f "/ceph/images/ceph-volumes.img" ]; then 
echo "create ceph-volumes.img"
dd if=/dev/zero of=/ceph/images/ceph-volumes.img bs=1M seek=12288 count=0 oflag=direct
sgdisk -g --clear /ceph/images/ceph-volumes.img
fi

if [ -L "/dev/ceph-volumes/ceph0" ]; then
echo "remove lv vg"
lvremove /dev/ceph-volumes/ceph0 
vgremove ceph-volumes
rm -r /dev/ceph-volumes
fi

losetup -d /dev/loop0

echo "vgcreate"
vgcreate ceph-volumes $(sudo losetup --show -f /ceph/images/ceph-volumes.img)
echo "lvcreate"
sudo lvcreate -L9G -nceph0 ceph-volumes
echo "mkfs"
mkfs.xfs -f /dev/ceph-volumes/ceph0

if [ ! -d "/var/local/osd" ]; then
echo "mount osd"
mkdir -p /var/local/osd
mount /dev/ceph-volumes/ceph0 /var/local/osd
fi

